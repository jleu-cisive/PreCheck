
/* =============================================
 Author		: Shashank Bhoi    
 Requester	: Jennifer Cordova    
 Create date: 10/05/2023(mm/dd/yyyy)    
 Description: Creating a Stored procedure For #106802 New QReport called Education - Possible Transferred Record Found
 Execution	: EXEC [Precheck].dbo.QReport_Education_Possible_Transferred_Record_Found '01/01/2023','01/31/2023','2167:3115','0','0'
=============================================== */

CREATE PROCEDURE dbo.QReport_Education_Possible_Transferred_Record_Found 
@StartDate Datetime 
,@EndDate Datetime
,@CLNO Varchar(500)	='0'		       --(separated by colon, default 0)
,@AffiliateIDs Varchar(500)='0'	       --(separated by colon, default 0)
,@ReportNumber Varchar(500)='0'        --(default 0)
AS 
BEGIN
	SET NOCOUNT ON;

	IF @CLNO ='' OR @CLNO ='0'
		SET @CLNO=NULL

	IF @AffiliateIDs ='' OR @AffiliateIDs ='0'
		SET @AffiliateIDs=NULL

	IF @ReportNumber ='' OR @ReportNumber ='0'
		SET @ReportNumber=NULL

	--Drop table If Exists #tmp

	Create table #tmp (Apno BIGINT,EducatID BIGINT,R int, IsTrn INT)
	INSERT INTO #tmp
	Select A.Apno,E.EducatID,Row_Number() OVer (Partition By A.Apno ORDER BY A.APNO, TRY_CAST(E.To_A as Date) Desc) AS R,
	(Case When CHARINDEX('added from previous report', ISNULL(E.Priv_Notes,''))=0  Then 0 Else 1 End) AS IsTrn
	From	dbo.APPL		AS A 
			JOIN dbo.Client AS C ON A.CLNO=C.CLNO
			JOIN dbo.Educat AS E On A.Apno=E.Apno
	WHERE	A.APNO=ISNULL(@ReportNumber,A.APNO)
			AND (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':'))) 
			AND (@CLNO IS NULL OR C.CLNO IN (SELECT VALUE FROM fn_Split(@CLNO,':'))) 
			AND A.ApDate BETWEEN @StartDate AND @EndDate
	ORDER BY 
			A.APNO, TRY_CAST(E.To_A as Date) Desc

	--Drop table If Exists #CurEmpl
	Select Apno,EducatID 
	Into #CurEmpl
	From #tmp
	Where R=1

	--Drop table If Exists #LastVrf

	Select Apno,Max(R) As LastVrf
	Into #LastVrf
	From #tmp 
	Where IsTrn=1
	GROUP By Apno
 

	Select  A.APNO AS [Report Number],C.Clno AS [Client ID],C.Name AS [Client Name]
	,A.UserId AS CAM,A.Investigator,First +' '+Last As [Applicant Name],A.CreatedDate, A.OrigCompDate AS [Original Close Date]
	,A.ReopenDate AS [Reopen Date], A.compDate AS [Complete Date]
	--,E.School AS [School Name Ordered]
	,(Case When E1.School IS NULL Then REPLACE(REPLACE(REPLACE(E.School,char(9),' '), CHAR(13), ''), CHAR(10), '') Else REPLACE(REPLACE(REPLACE(E1.School,char(9),' '), CHAR(13), ''), CHAR(10), '') End ) AS [School Name Ordered]
	,(Case When E1.School IS NULL Then E.Degree_V  Else E1.Degree_V  End)  AS [Degree Type Ordered]
	,(Case When E1.School IS NULL Then E.Studies_V  Else E1.Studies_V  End) AS [Studies Ordered]
	,(Case When E1.School IS NULL Then E.To_V  Else E1.To_V  End) AS [Degree Date Ordered]
	,(Case When E1.School IS NULL Then E.State  Else E1.State  End) AS [School State]
	,(Case When E1.School IS NULL Then E.From_A  Else E1.From_A  End) [Education Start Date Ordered]
	,(Case When E1.School IS NULL Then E.To_A  Else E1.To_A  End) [Education End Date Ordered]
	,Case When E1.School IS NULL Then 
								Case WHEN E.IsIntl =0 THEN 'NO' ELSE 'YES' END 
								ELSE
								Case WHEN coalesce(E1.IsIntl,E.IsIntl) =0 THEN 'NO' ELSE 'YES' END
		END AS  International
	--,REPLACE(REPLACE(REPLACE(E.School,char(9),' '), CHAR(13), ''), CHAR(10), '') AS [School Name Ordered]
	--,E.Degree_V AS [Degree Type Ordered]
	--,E.Studies_V AS [Studies Ordered]
	--,E.To_V  AS [Degree Date Ordered]
	--,E.State AS [School State]
	--,(Case WHEN E1.IsIntl =0 THEN 'NO' ELSE 'YES' END ) AS  International
	--,E.From_A [Education Start Date Ordered]
	--,E.To_A [Education End Date Ordered]
	--,E.IsIntl AS E_IsIntl,E.EducatID,E1.IsIntl AS E1_IsIntl,E1.EducatID

	,REPLACE(REPLACE(REPLACE(E1.School,char(9),' '), CHAR(13), ''), CHAR(10), '') AS [School Name Previously Verified]
	,E1.Degree_V AS [Degree Type  Previously Verified]
	,E1.Studies_V AS [Studies Previously Verified]
	,E1.To_V AS [Degree Date Previously Verified]
	--,(Case WHEN E.IsHistoryRecord =0 THEN 'NO' ELSE 'YES' END ) AS Transferred
	,(Case When E1.School IS NULL Then 0 Else 1 End ) AS IsTransferred
	From	dbo.APPL			AS A
			JOIN dbo.Client C On A.Clno=C.Clno
			JOIN dbo.#CurEmpl t ON A.ApNo=t.Apno 
			JOIN dbo.Educat E ON E.EducatID=t.EducatID
			LEFT JOIN dbo.#LastVrf LV ON A.ApNo=LV.Apno 
			LEFT JOIN dbo.#tmp t1 ON LV.Apno=t1.Apno And LV.LastVrf=t1.R
			LEFT JOIN dbo.Educat E1 ON t1.EducatID=E1.EducatID
END 

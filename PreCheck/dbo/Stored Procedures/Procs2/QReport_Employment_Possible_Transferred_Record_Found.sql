-- =======================================================================  
-- Author: YSharma  
-- Create date: 09/29/2023  
-- Description: Creating a Stored procedure For #106803 New Qreport called Employment - Possible Transferred Record Found  
-- EXEC [dbo.QReport_Employment_Possible_Transferred_Record_Found ] '01/01/2023','01/31/2023','2167:3115','0','0'  
-- ========================================================================  

CREATE PROCEDURE dbo.QReport_Employment_Possible_Transferred_Record_Found 
@StartDate Datetime 
,@EndDate Datetime
,@CLNO Varchar(500)	='0'		       --(separated by colon, default 0)
,@AffiliateIDs Varchar(500)='0'	       --(separated by colon, default 0)
,@ReportNumber Varchar(500)='0'        --(default 0)
AS 
BEGIN

IF @CLNO ='' OR @CLNO ='0'
	BEGIN
		SET @CLNO=NULL
	END

IF @AffiliateIDs ='' OR @AffiliateIDs ='0'
	BEGIN
		SET @AffiliateIDs=NULL
	END

IF @ReportNumber ='' OR @ReportNumber ='0'
	BEGIN
		SET @ReportNumber=NULL
	END


DROP TABLE IF EXISTS #tmp
	CREATE TABLe #tmp (Apno BIGINT,EmplId BIGINT,R int, IsTrn INT)
	INSERT INTO #tmp (Apno ,EmplId ,R , IsTrn )
	SELECT A.Apno,E.EmplId,
	Row_Number() OVer (Partition By A.Apno ORDER BY A.APNO, TRY_CAST(E.From_A as Date) Desc) AS R,
	(Case When CHARINDEX('added from previous report', ISNULL(E.Priv_Notes,''))=0  Then 0 Else 1 End) AS IsTrn
	FROM APPL A 
	INNER JOIN Client C ON A.CLNO=C.CLNO
	INNER JOIN Empl E On A.Apno=E.Apno
	WHERE 
	A.APNO=ISNULL(@ReportNumber,A.APNO)
	AND (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':'))) 
	AND (@CLNO IS NULL OR C.CLNO IN (SELECT VALUE FROM fn_Split(@CLNO,':'))) 
	AND A.ApDate BETWEEN @StartDate AND @EndDate
	--A.Apno IN  (7612835,7613142)  
	ORDER BY A.APNO, TRY_CAST(E.To_A as Date) Desc

DROP TABLE IF EXISTS #CurEmpl
	SELECT Apno,EmplId 
	INTO #CurEmpl
	FROM #tmp
	WHERE R=1

DROP TABLE IF EXISTS #LastVrf
	SELECT Apno,Max(R) As LastVrf
	INTO #LastVrf
	FROM #tmp 
	WHERE IsTrn=1
	GROUP BY Apno


	SELECT  A.APNO AS [Report Number],C.Clno AS [Client ID],Name AS [Client Name]
	,A.UserId AS CAM,A.Investigator,First +' '+Last As [Applicant Name],A.CreatedDate, A.OrigCompDate,A.ReopenDate, A.compDate AS CompleteDate
	,(Case When E1.Employer IS NULL Then E.Employer Else E1.Employer End ) AS [Employer Name Ordered]
	,(Case When E1.Employer IS NULL Then E.From_A Else E1.From_A End )  As [Employment Start Date Ordered]
	,(Case When E1.Employer IS NULL Then E.To_A  Else E1.To_A  End ) AS [Employment End Date Ordered]
	,(Case WHEN E.IsIntl =0 THEN 'NO' ELSE 'YES' END ) AS  International
	,E1.Employer AS [Employer Name Previously Verified]
	,E1.From_A AS [Employment Start Date Previously Verified]
	,E1.To_A AS [Employment End Date Previously Verified]
	,(Case When E1.Employer IS NULL Then 0 Else 1 End ) AS IsTransferred
	From Appl A
	INNER JOIN Client C On A.Clno=C.Clno
	INNER JOIN #CurEmpl CE ON A.ApNo=CE.Apno 
	INNER JOIN Empl E ON CE.EmplId=E.EmplID
	LEFT JOIN #LastVrf LV ON A.ApNo=LV.Apno 
	LEFT JOIN #tmp t ON LV.Apno=t.Apno And LV.LastVrf=t.R
	LEFT JOIN Empl E1 ON t.EmplId=E1.EmplID
	ORDER BY A.Apno

END
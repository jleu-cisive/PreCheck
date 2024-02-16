
---*************************************************************************
---Created by Prasanna on 03/12/2018 HDT30425	
-- Requester - Dana Sangerhausen
-- Exec [dbo].[EmploymentVerificationEffortsDetail] '11/01/2018', '11/30/2018', 0,0

---*************************************************************************

/* Modified By: Sunil Mandal A
-- Modified Date: 07/01/2022
-- Description: Ticketno-53763 
Modify existing q-reports that have affiliate ids in their search parameters
Details: 
Change search parameters for the Affiliate Id field
     * search by multiple affiliate ids (ex 4:297)
     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates
     * multiple affiliates to be separated by a colon  
Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0)
*/
---Testing
/*


Exec [dbo].[EmploymentVerificationEffortsDetail] '11/01/2021', '11/05/2021', 4,0
Exec [dbo].[EmploymentVerificationEffortsDetail] '11/01/2021', '11/05/2021', '4:30:177',0

*/
CREATE PROCEDURE [dbo].[EmploymentVerificationEffortsDetail] 
	@StartDate DateTime,
	@EndDate DateTime,
	--@AffiliateID int,
	@AffiliateIDs varchar(MAX) = '0',  --code added by Sunil Mandal for ticket id -53763
	@IsOneHR bit = 0
AS
BEGIN

	--code added by Sunil Mandal for ticket id -53763 starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END
     --code added by Sunil Mandal for ticket id -53763 Ends	


	IF OBJECT_ID('tempdb..#EffortDetails') IS NOT NULL
		DROP TABLE #EffortDetails

	CREATE TABLE #EffortDetails
	(
		EmplID int NOT NULL,
		Report# INT NOT NULL,
		EmployerName VARCHAR(100),
		Affiliate VARCHAR(100),
		VerificationStatus VARCHAR(50),
		[Investigator Name] nvarchar(100), 
		[Date Closed] DATETIME,
		InvestigatorAssigned DATETIME,
		IsOneHR bit,
		[Private Notes] VARCHAR(max),
		[Public Notes] VARCHAR(max)
	)

	CREATE TABLE #tmp
	(
		EmplID int NOT NULL,
		[Date Closed] DATETIME
	)

	CREATE CLUSTERED INDEX IX_tmp_effortDetails ON #EffortDetails(EmplID)
	CREATE CLUSTERED INDEX IX_tmp_tmp ON #tmp(EmplID)

	INSERT INTO #EffortDetails
	SELECT  E.EmplID, E.APNO AS Report#, e.employer AS EmployerName, REPLACE(REPLACE(RA.Affiliate, CHAR(10),';'),CHAR(13),';') AS Affiliate, 
			s.[Description] AS VerificationStatus, U.[Name] AS [Investigator Name], 
			C.ChangeDate AS [Date Closed] , E.InvestigatorAssigned, ISNULL(F.IsOneHR,0) AS IsOneHR, E.Priv_Notes AS [Private Notes], E.Pub_Notes AS [ Public Notes]
	FROM dbo.ChangeLog AS C(nolock) 
	INNER JOIN EMPL AS E(NOLOCK) ON C.ID = E.EmplID
	INNER JOIN Appl AS A(NOLOCK) ON E.APNO = A.APNO
	INNER JOIN Client AS Cl(NOLOCK) ON A.CLNO =Cl.CLNO
	LEFT OUTER JOIN [HEVN].[dbo].Facility AS F(NOLOCK) ON Cl.CLNO = F.FacilityCLNO
	LEFT OUTER JOIN dbo.refAffiliate AS RA WITH (NOLOCK) ON Cl.AffiliateID = RA.AffiliateID
	INNER JOIN USERS AS U(NOLOCK) ON (CASE WHEN LEN(LTRIM(RTRIM(C.UserID))) <=8 THEN LTRIM(RTRIM(C.USERID)) ELSE SUBSTRING (LTRIM(RTRIM(C.UserID)) ,1 ,LEN(LTRIM(RTRIM(C.UserID))) -5) END) = U.UserID --AND U.Empl = 1 and U.[Disabled] = 0	
	INNER JOIN SectStat AS S(NOLOCK) ON E.SectStat = S.Code
	where TableName like 'Empl.SectStat%'
	  AND c.NewValue NOT IN ('0','9')
	  AND E.SectStat NOT IN ('0','9')
	  AND c.ChangeDate BETWEEN @StartDate AND dateadd(s,-1,dateadd(d,1,@EndDate))
	  AND E.isOnReport=1 	
	 --  AND Cl.AffiliateID = IIF(@AffiliateID = 0,RA.AffiliateID, @AffiliateID)  --code added by Sunil Mandal for ticket id -53763
	 AND (@AffiliateIDs IS NULL OR Cl.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':'))) --code added by Sunil Mandal for ticket id -53763
	  AND ISNULL(F.IsOneHR,0) = ISNULL(@IsOneHR, 0)
	
	INSERT INTO #tmp
	SELECT tcl.EmplID, MAX(tcl.[Date Closed]) AS [Date Closed] 
	FROM #EffortDetails tcl 
	GROUP BY tcl.EmplID

	SELECT DISTINCT tcl.Report#, tcl.EmployerName, tcl.Affiliate, tcl.IsOneHR, tcl.VerificationStatus, tcl.[Investigator Name],y.[# of Efforts],tcl.[Date Closed], [dbo].[ElapsedBusinessDays_2](tcl.InvestigatorAssigned,t.[Date Closed]) AS [Total Number of Days],
	tcl.[Private Notes], tcl.[Public Notes] 
	FROM #EffortDetails tcl(nolock)
	INNER JOIN #tmp t(nolock) ON tcl.EmplID = t.EmplID
	INNER JOIN (SELECT ID, count(ID) [# of Efforts] 
				FROM changelog cl(nolock) 
				WHERE cl.TableName LIKE 'Empl.web_status%' AND cl.NewValue NOT IN('33') AND cl.OldValue NOT IN('33')
				GROUP BY ID
			   ) AS y ON tcl.emplid = y.ID
	ORDER BY tcl.[Investigator Name]

	DROP TABLE #EffortDetails
	DROP TABLE #tmp

END

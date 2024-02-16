-- =============================================
-- Author:	
-- Modified By: Radhika Dereddy
-- Modified date: 01/07/2019
-- Description:	Change the inline query to Stored Procedure
-- Modified Reason : Dana -  Please include all accounts (active and inactive) in output and also regardless of whether they had activity during the date parameters, or not.
-- If they did not have activity during the dates entered, the Count should be 0. So the list of clients displayed should be independent of whether they were active, during those dates. 
-- The output should include every client as of the day that we execute the qreport, and then the count displayed should be tied to the date parameters.
-- EXEC [ReportsReceivedSummary] '01/01/2019', '01/11/2019'
-- Added a new column CAM to the procedure on 01/28/2018 by Radhika Dereddy
-- Modified by Radhika Dereddy 05/30/2019 to change the date format for the date columns

-- Modified By: Vairavan A 
-- Modified date: 30/01/2023
--Ticket no   :  79819
--Description : Add "Accounting System Group" to Existing QReport: "Reports Received Summary"
--Exec  [dbo].[ReportsReceivedSummary] '01/01/2019','01/01/2019'
-- =============================================
CREATE PROCEDURE [dbo].[ReportsReceivedSummary]
	@StartDate DateTime,
	@EndDate DateTime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	CREATE TABLE #tmpAllClients
	(
		[CLNO] [int] NOT NULL,
		[ClientName] [varchar](100) NULL,
		[Affiliate] [varchar](50) NULL,
		[CAM] [varchar](8) NULL,
		[ClientType] [varchar](50) NOT NULL,
		[IsInactive][varchar](10) NOT NULL,
		[FirstAppDate][datetime] NULL,
		[LastAppDate][datetime] NULL,
		[Accounting System Group]  varchar(200) NULL--Code added for Ticket no:  79819 by vairavan
	) 

	CREATE TABLE #tmpAvailableClients
	(
		[CLNO] [int] NOT NULL,
		[ClientName] [varchar](100) NULL,
		[Affiliate] [varchar](50) NULL,
		[CAM] [varchar](8) NULL,
		[NumberofReports] int NOT NULL,
		[ClientType] [varchar](50) NOT NULL,
		[IsInactive][varchar](10) NOT NULL,
		[FirstAppDate][datetime] NULL,
		[LastAppDate][datetime] NULL,
		[Accounting System Group]  varchar(200) NULL--Code added for Ticket no:  79819 by vairavan
	) 

	CREATE TABLE #tmpFinalClientsList
	(
		[CLNO] [int] NOT NULL,
		[ClientName] [varchar](100) NULL,
		[Affiliate] [varchar](50) NULL,
		[CAM] [varchar](8) NULL,
		[NumberofReports] int NOT NULL,
		[ClientType] [varchar](50) NOT NULL,
		[IsInactive][varchar](10) NOT NULL,
		--[AutoOrderEnabled] [varchar](10) NOT NULL,
		[FirstAppDate][datetime] NULL,
		[LastAppDate][datetime] NULL,
		[Accounting System Group]  varchar(200) NULL--Code added for Ticket no:  79819 by vairavan
	) 
	

	INSERT INTO #tmpAllClients
	Select c.CLNO  as CLNO, c.Name as ClientName, r.Affiliate, C.CAM as CAM, rc.ClientType, 
	(Case when c.IsInActive = 0 then 'False' else 'True' end )as IsInactive, min(a.Apdate) as 'FirstAppDate',Max(a.apdate) as 'LastAppDate',
	c.[Accounting System Grouping]--Code added for Ticket no:  79819 by vairavan
	From Appl a(NOLOCK)
	inner join Client C(NOLOCK) on a.CLno = c.CLno
	inner join refClientType rc(NOLOCK) on c.ClientTypeID = rc.ClientTypeID
	inner join refAffiliate as r(NOLOCK) on C.AffiliateID = r.AffiliateID
	Group by C.CLNO, C.Name,  rc.ClientType,  r.Affiliate, c.IsInactive, C.CAM,c.[Accounting System Grouping]


	--select * from #tmpAllClients

	INSERT INTO #tmpAvailableClients
	Select	t.CLNO, t.ClientName, t.Affiliate, t.CAM,
			Case when Count(a.APNO) > 0 then Count(a.APNO) else 0 end as NumberofReports,
			t.ClientType, t.IsInactive, t.FirstAppDate,t.LastAppDate,
			t.[Accounting System Group]--Code added for Ticket no:  79819 by vairavan
	from Appl a(nolock)
	INNER JOIN #tmpAllClients t on A.CLNO = T.CLNO
	Where (a.Apdate BETWEEN @StartDate AND DATEADD(d,1,@EndDate)) 
	Group by t.CLNO, t.ClientName,  t.ClientType, t.CAM,  t.Affiliate, t.IsInactive, t.FirstAppDate,t.LastAppDate,t.[Accounting System Group]
	Order by CLNO


	--select * from #tmpAvailableClients

	INSERT INTO  #tmpFinalClientsList
	SELECT CLNO, ClientName, Affiliate, ISNULL(CAM,''), NumberofReports, ClientType, IsInactive, FirstAppDate, LastAppDate,
	     [Accounting System Group] --Code added for Ticket no:  79819 by vairavan
	FROM 
	(
	SELECT X.CLNO, X.ClientName, X.Affiliate, X.CAM AS CAM, X.NumberofReports, X.ClientType, X.IsInactive, X.FirstAppDate, X.LastAppDate,
		   X.[Accounting System Group]--Code added for Ticket no:  79819 by vairavan
	FROM #tmpAvailableClients AS X
	UNION ALL
	SELECT t.CLNO, t.ClientName, t.Affiliate, t.CAM AS CAM, 0 AS NumberofReports, t.ClientType, t.IsInactive, t.FirstAppDate, t.LastAppDate,
		   t.[Accounting System Group]--Code added for Ticket no:  79819 by vairavan
	FROM #tmpAllClients t
	WHERE t.CLNO NOT IN (SELECT X.CLNO FROM #tmpAvailableClients AS X)
	) AS Y
	GROUP BY Y.CLNO, Y.ClientName,  Y.Affiliate, Y.CAM,Y.NumberofReports,Y.ClientType, Y.IsInactive, Y.FirstAppDate,Y.LastAppDate,Y.[Accounting System Group]
	ORDER BY Y.CLNO

	--select * from #tmpFinalClientsList

	SELECT CLNO, ClientName, Affiliate, CAM, NumberofReports, ClientType, IsInactive, FirstAppDate, LastAppDate,
		   [Accounting System Group]--Code added for Ticket no:  79819 by vairavan
		INTO #tmpAutoOrderEnabledClientsList
	FROM
	(
	SELECT R.CLNO, R.ClientName,R. Affiliate, R.CAM AS CAM, R.NumberofReports, R.ClientType, R.IsInactive, R.FirstAppDate, R.LastAppDate,
		   [Accounting System Group]--Code added for Ticket no:  79819 by vairavan
	FROM #tmpFinalClientsList as R
	 UNION ALL	
	SELECT '100000', 'Total' as ClientName,'', '' AS CAM, Sum(F.NumberofReports),'','','','',
		   '' --Code added for Ticket no:  79819 by vairavan
	FROM #tmpFinalClientsList as F
	) A
	ORDER BY A.CLNO 

	SELECT	t.CLNO, t.ClientName, t.Affiliate,
			[Accounting System Group],--Code added for Ticket no:  79819 by vairavan
			t.CAM, t.NumberofReports, t.ClientType, t.IsInactive,  
			(CASE WHEN C.[Value] = 'False' THEN 'False' ELSE 'True' END ) AS [Auto Order Enabled],			
			FORMAT(t.FirstAppDate,'MM/dd/yyyy') as 'FirstAppDate', FORMAT(t.LastAppDate, 'MM/dd/yyyy hh:mm:tt') as 'LastAppDate'
	FROM #tmpAutoOrderEnabledClientsList AS t
	LEFT OUTER JOIN ClientConfiguration AS C ON T.CLNO = C.CLNO AND C.ConfigurationKey = 'AUTOORDER'
	ORDER BY T.CLNO 
	--SELECT * FROM #tmpAutoOrderEnabledClientsList AS T ORDER BY T.CLNO 

	DROP TABLE #tmpAllClients
	DROP TABLE #tmpAvailableClients
	DROP TABLE #tmpFinalClientsList
	DROP TABLE #tmpAutoOrderEnabledClientsList
END

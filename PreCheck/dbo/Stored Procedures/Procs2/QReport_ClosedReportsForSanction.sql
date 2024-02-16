-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 07/27/2021
-- Description:	Closed Reports for Sanction
-- EXEC [QReport_ClosedReportsForSanction] '07/23/2021','07/23/2021'
-- =============================================
CREATE PROCEDURE [dbo].[QReport_ClosedReportsForSanction]
	-- Add the parameters for the stored procedure here
@StartDate datetime,
@EndDate datetime

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#tmpSanction') IS NOT NULL DROP TABLE #tmpSanction
	IF OBJECT_ID('tempdb..#tmpSSNSanction') IS NOT NULL DROP TABLE #tmpSSNSanction
	IF OBJECT_ID('tempdb..#tempClosedCountSanction') IS NOT NULL DROP TABLE #tempClosedCountSanction

    -- Insert statements for procedure here
	SELECT  A.CLNO AS [Client ID], 
			C.Name AS [Client Name],
			RA.Affiliate,
			A.Investigator, 
			A.APNO AS [Report Number],
			A.SSN,
			E.Report,
			A.First AS [First Name], 
			A.Last AS [Last Name], 
			dbo.elapsedbusinessdays_2(A.CreatedDate, A.CompDate) AS Turnaround,  
			dbo.elapsedbusinessdays_2(A.ReopenDate, A.CompDate) AS [ReOpen Turnaround], 
			dbo.elapsedbusinessdays_2(E.CreatedDate, E.Last_Updated) AS [Component TAT], 
			S.[Description] AS [Status], 
			format(A.ApDate,'MM/dd/yyyy hh:mm tt') AS [Received Date], 
			format(A.OrigCompDate,'MM/dd/yyyy hh:mm tt') AS[OriginalClose],
			format(A.CompDate,'MM/dd/yyyy hh:mm tt') AS [Close Date], 
			A.UserID AS CAM,
			CASE WHEN E.IsHidden = 0 THEN 'False' ELSE 'True' END AS [Is Hidden Report]
		INTO #tmpSanction
	FROM dbo.Appl AS A(NOLOCK)
	INNER JOIN dbo.MedInteg AS E(NOLOCK) ON A.APNO = E.APNO
	INNER JOIN dbo.SectStat AS S(NOLOCK) ON E.SectStat = S.CODE
	INNER JOIN dbo.Client AS C(NOLOCK) ON A.CLNO = C.CLNO
	INNER JOIN refAffiliate AS RA(NOLOCK) ON C.AffiliateID = RA.AffiliateID
	WHERE 
		  A.OrigCompDate >= @StartDate  
	  AND A.OrigCompDate < DATEADD(DAY, 1, @EndDate)
	  AND E.SectStat NOT IN ( '9','0','H','R')
	  AND E.IsHidden = 0
	ORDER BY A.CLNO, A.APNO


	SELECT  A.SSN, COUNT(*) NoOfReports 
		into #tmpSSNSanction
	FROM dbo.Appl AS A WITH(NOLOCK) 
	INNER JOIN #tmpSanction AS O ON A.SSN = O.SSN
	GROUP BY A.SSN
	HAVING COUNT(*) > 1

	SELECT  
			 [Client ID], [Client Name], 
			 [Report Number], Report,
			 [First Name], [Last Name], 
			 [Status],
			 [Received Date],
			 [OriginalClose],[Close Date]		
	INTO #tempClosedCountSanction
	FROM #tmpSanction AS O
	LEFT OUTER JOIN #tmpSSNSanction AS S ON O.SSN = S.SSN



	SELECT * FROM #tempClosedCountSanction
	UNION ALL
	SELECT '', 'Total Closed Reports',Count( [Report Number]),'','','','','','',''
	FROM #tempClosedCountSanction

END

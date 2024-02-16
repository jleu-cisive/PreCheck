-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 07/14/2021
-- Description:	Closed Reports for Employment
-- EXEC [QReport_ClosedReportsForEmployment] '07/23/2021','07/23/2021'
-- Commenting the ISOneHR column from the QReport as per Brian Silver on 07/26/2021 by Radhika Dereddy
-- =============================================
CREATE PROCEDURE [dbo].[QReport_ClosedReportsForEmployment]
	-- Add the parameters for the stored procedure here
@StartDate datetime,
@EndDate datetime,
@CLNO int,
@AffiliateID int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF OBJECT_ID('tempdb..#tmpOverseas') IS NOT NULL DROP TABLE #tmpOverseas
	IF OBJECT_ID('tempdb..#tmpSSN') IS NOT NULL DROP TABLE #tmpSSN
	IF OBJECT_ID('tempdb..#TempCLosedCountEmp') IS NOT NULL DROP TABLE #TempCLosedCountEmp
	


	SELECT  A.CLNO AS [Client ID], 
			C.Name AS [Client Name],
			RA.Affiliate,
			A.Investigator, 
			A.APNO AS [Report Number],
			A.SSN,
			E.Employer AS Employer, 
			E.city AS [Emp City],
			E.[state] AS [Emp State],
			A.First AS [First Name], 
			A.Last AS [Last Name], 
			CASE WHEN E.IsIntl IS NULL THEN 'NO' WHEN E.IsIntl = 0 THEN 'NO' ELSE 'YES' END AS [International/Overseas], 
			dbo.elapsedbusinessdays_2(A.CreatedDate, A.CompDate) AS Turnaround,  
			dbo.elapsedbusinessdays_2(A.ReopenDate, A.CompDate) AS [ReOpen Turnaround], 
			dbo.elapsedbusinessdays_2(E.CreatedDate, E.Last_Updated) AS [Component TAT],
			S.[Description] AS [Status], 
			isnull(sss.SectSubStatus, '') as [SubStatus], 
			format(A.ApDate,'MM/dd/yyyy hh:mm tt') AS [Received Date], 
			format(A.OrigCompDate,'MM/dd/yyyy hh:mm tt') AS[OriginalClose],
			format(A.CompDate,'MM/dd/yyyy hh:mm tt') AS [Close Date], 
			A.UserID AS CAM,
			e.Investigator AS [Investigator1], 
			CASE WHEN E.IsHidden = 0 THEN 'False' ELSE 'True' END AS [Is Hidden Report],
			CASE WHEN e.IsOnReport = 0 THEN 'False' ELSE 'True' END AS [Is On Report],
			E.Pub_Notes [Public Notes],
			E.PRIV_NOTES AS [Private Notes]
		INTO #tmpOverseas
	FROM dbo.Appl AS A(NOLOCK)
	INNER JOIN dbo.Empl AS E(NOLOCK) ON A.APNO = E.APNO
	INNER JOIN dbo.SectStat AS S(NOLOCK) ON E.SectStat = S.CODE
	INNER JOIN dbo.Client AS C(NOLOCK) ON A.CLNO = C.CLNO
	INNER JOIN refAffiliate AS RA(NOLOCK) ON C.AffiliateID = RA.AffiliateID
	Left join dbo.SectSubStatus sss (nolock) on e.SectStat = sss.SectStatusCode and e.SectSubStatusID = sss.SectSubStatusID and sss.ApplSectionID =1
	WHERE 
		  A.OrigCompDate >= @StartDate  
	  AND A.OrigCompDate < DATEADD(DAY, 1, @EndDate)
	  AND E.SectStat NOT IN ( '9','0','H','R')
	  AND C.CLNO = IIF(@CLNO=0,C.CLNO,@CLNO)
	  AND C.AffiliateID = IIF(@AffiliateID=0,C.AffiliateID,@AffiliateID) 
	  AND E.IsHidden = 0
	  AND E.IsOnReport = 1
	ORDER BY A.CLNO, A.APNO


	SELECT  A.SSN, COUNT(*) NoOfReports 
		into #tmpSSN
	FROM dbo.Appl AS A WITH(NOLOCK) 
	INNER JOIN #tmpOverseas AS O ON A.SSN = O.SSN
	GROUP BY A.SSN
	HAVING COUNT(*) > 1


	SELECT [Client ID], [Client Name], [Report Number], Employer, 
		   [Emp City], [Emp State], [First Name], [Last Name], 
			[Status], [SubStatus],[Received Date],
			[OriginalClose],[Close Date]
		INTO #TempCLosedCountEmp	 
	FROM #tmpOverseas AS O
	LEFT OUTER JOIN #tmpSSN AS S ON O.SSN = S.SSN

	SELECT * FROM #TempCLosedCountEmp
	UNION ALL
	SELECT '', 'Total Closed Reports',Count( [Report Number]),'','','','','','','','','',''
	FROM #TempCLosedCountEmp

END

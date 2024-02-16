-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 07/14/2021
-- Description:	Closed Reports for References
-- EXEC [QReport_ClosedReportsForReferences] '07/01/2021','07/13/2021',0,0
-- Commenting the ISOneHR column from the QReport as per Brian Silver on 07/26/2021 by Radhika Dereddy
-- =============================================
CREATE PROCEDURE [dbo].[QReport_ClosedReportsForReferences]
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

	IF OBJECT_ID('tempdb..#tmpOverseas') IS NOT NULL DROP TABLE #tmpOverseas
	IF OBJECT_ID('tempdb..#tmpSSN') IS NOT NULL DROP TABLE #tmpSSN
	IF OBJECT_ID('tempdb..#tempClosedCount') IS NOT NULL DROP TABLE #tempClosedCount

    -- Insert statements for procedure here
	SELECT  A.CLNO AS [Client ID], 
			C.Name AS [Client Name],
			RA.Affiliate,
			--CASE WHEN F.IsOneHR = 1 THEN 'True' WHEN F.IsOneHR = 0 THEN 'False' WHEN F.IsOneHR IS Null THEN 'N/A' END AS [IsOneHR], 
			A.Investigator, 
			A.APNO AS [Report Number],
			A.SSN,
			E.Name, 
			A.First AS [First Name], 
			A.Last AS [Last Name], 
			dbo.elapsedbusinessdays_2(A.CreatedDate, A.CompDate) AS Turnaround,  
			dbo.elapsedbusinessdays_2(A.ReopenDate, A.CompDate) AS [ReOpen Turnaround], 
			dbo.elapsedbusinessdays_2(E.CreatedDate, E.Last_Updated) AS [Component TAT], 
			S.[Description] AS [Status], sss.SectSubStatus as [SubStatus],
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
	INNER JOIN dbo.PersRef AS E(NOLOCK) ON A.APNO = E.APNO
	INNER JOIN dbo.SectStat AS S(NOLOCK) ON E.SectStat = S.CODE
	INNER JOIN dbo.Client AS C(NOLOCK) ON A.CLNO = C.CLNO
	INNER JOIN refAffiliate AS RA(NOLOCK) ON C.AffiliateID = RA.AffiliateID
	LEFT JOIN dbo.SectSubStatus sss (nolock) on e.SectStat = sss.SectStatusCode and e.SectSubStatusID = sss.SectSubStatusID and sss.ApplSectionID =3
	WHERE A.OrigCompDate >= @StartDate  
	  AND A.OrigCompDate < DATEADD(DAY, 1, @EndDate)
	  AND C.CLNO = IIF(@CLNO=0,C.CLNO,@CLNO)
	  AND C.AffiliateID = IIF(@AffiliateID=0,C.AffiliateID,@AffiliateID) 
	  AND E.SectStat NOT IN ( '9','0','H','R')
	  AND E.IsHidden = 0
	  AND E.IsOnReport = 1
	ORDER BY A.CLNO, A.APNO


	SELECT  A.SSN, COUNT(*) NoOfReports 
		into #tmpSSN
	FROM dbo.Appl AS A WITH(NOLOCK) 
	INNER JOIN #tmpOverseas AS O ON A.SSN = O.SSN
	GROUP BY A.SSN
	HAVING COUNT(*) > 1

	SELECT  
			 [Client ID], [Client Name], 
			--Affiliate, O.IsOneHR, Investigator,
			 [Report Number], Name, 
			 [First Name], [Last Name], 
			 --Turnaround,[ReOpen Turnaround],[Component TAT],
			 [Status],[SubStatus],
			 [Received Date],
			 [OriginalClose],[Close Date]
			 --,CAM,[Investigator1],
			 --[Is Hidden Report],[Is On Report]
			 --[Public Notes],[Private Notes]
	INTO #tempClosedCount
	FROM #tmpOverseas AS O
	LEFT OUTER JOIN #tmpSSN AS S ON O.SSN = S.SSN



	SELECT * FROM #tempClosedCount
	UNION ALL
	SELECT '', 'Total Closed Reports',Count( [Report Number]),'','','','','','','',''
	FROM #tempClosedCount

END

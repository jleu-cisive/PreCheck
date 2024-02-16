-- =============================================
-- Author:		DEEPAK VODETHELA	
-- Create date: 09/11/2017
-- Description:	QReport that identifies the last component completed prior to the background check report being closed
-- Execution: Last_Section_Completed_Detail '1/1/2019','1/1/2019',0,4
--			  Last_Section_Completed_Detail '08/01/2017','08/31/2017',0,177
--			  Last_Section_Completed_Detail '08/01/2017','08/31/2017',12829,0
--			  Last_Section_Completed_Detail '08/01/2017','08/31/2017',8507,30
--Modified By Amy Liu on 05/14/2018: HDT32781: using reportDate and [report closed] column to get [report TAT] instead of [Component Close Date] and [Date Report Closed] column
--Modified By Amy Liu on 07/19/2018: HDT36348: Another request from Brian Silver says the report just hangs
--EXEC [dbo].[Last_Section_Completed_Detail] '06/01/2018','06/30/2018',0,29
-- =============================================
Create PROCEDURE [dbo].[Last_Section_Completed_Detail_Humera]
(
	-- Add the parameters for the stored procedure here
	@StartDate DATETIME,
	@EndDate DATETIME,
	@Clno INT,
	@AffiliateID INT
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	--DECLARE 	@StartDate DATETIME='09/08/2017',
	--			@EndDate DATETIME='09/11/2017',
	--			@Clno INT=0,
	--			@AffiliateID INT=0

		IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
		  DROP TABLE #tmp
		IF OBJECT_ID('tempdb..#tmpEmployment') IS NOT NULL
		  DROP TABLE #tmpEmployment
		IF OBJECT_ID('tempdb..#tmpEducation') IS NOT NULL
		  DROP TABLE #tmpEducation
		IF OBJECT_ID('tempdb..#tmpPersonalReference') IS NOT NULL
		  DROP TABLE #tmpPersonalReference
		IF OBJECT_ID('tempdb..#tmpCrim') IS NOT NULL
		  DROP TABLE #tmpCrim
		IF OBJECT_ID('tempdb..#tmpComponents') IS NOT NULL
		  DROP TABLE #tmpComponents
		IF OBJECT_ID('tempdb..#tmpMaxCloseDate') IS NOT NULL
		  DROP TABLE #tmpMaxCloseDate
		IF OBJECT_ID('tempdb..#tmpFinalClosedDateForComponent') IS NOT NULL
		  DROP TABLE #tmpFinalClosedDateForComponent

	SELECT APNO, A.CLNO, C.Name AS ClientName,RA.AffiliateID, RA.Affiliate, A.First AS [Applicant First Name], A.Last AS [Applicant Last Name], ApDate, CompDate [Date Report Closed], A.ReopenDate
	--Modified by Humera Ahmed to add report/component Re-Open Date
		INTO #tmp
	FROM Appl(NOLOCK) AS A
	INNER JOIN Client AS C(NOLOCK) ON A.CLNO = C.CLNO
	LEFT JOIN refAffiliate AS RA WITH (NOLOCK) ON isnull(C.AffiliateID,0) = RA.AffiliateID
	WHERE ApStatus = 'F' 
	  AND ApDate BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(D,1,@EndDate))
	  AND (isnull(@clno, 0)=0 OR a.clno=@Clno)
	  AND (isnull(@AffiliateID,0)=0 OR ra.AffiliateID = @AffiliateID)

  SELECT 'Employment' AS ComponentType, E.APNO, MAX(C.ChangeDate) OVER (PARTITION BY E.Apno) AS [DateClosed] INTO #tmpEmployment 
  FROM ChangeLog AS C(NOLOCK) 
  INNER JOIN Empl AS E(NOLOCK) ON C.ID = E.EmplID
  INNER JOIN  #tmp t with(nolock) ON E.Apno	= t.apno
  WHERE C.ChangeDate >=t.ApDate
  AND TableName = 'Empl.SectStat' 
  AND NewValue IN ('2','3','4','5','6','7','A','B') AND E.IsOnReport = 1  	 
  ORDER BY C.ChangeDate DESC
  --SELECT * FROM #tmpEmployment
  
  SELECT 'Education' AS ComponentType, E.APNO, MAX(C.ChangeDate) OVER (PARTITION BY E.Apno) AS [DateClosed] INTO #tmpEducation 
  FROM ChangeLog AS C(NOLOCK) 
  INNER JOIN Educat AS E(NOLOCK) ON C.ID = E.Educatid 
  INNER JOIN #tmp t ON e.APNO	= t.APNO	
  WHERE C.ChangeDate >= t.apdate
  AND TableName = 'Educat.SectStat' 
  AND NewValue IN ('2','3','4','5','6','7','A','B') AND E.IsOnReport = 1 
  ORDER BY C.ChangeDate DESC
  --SELECT * FROM #tmpEducation

  SELECT 'Personal Reference' AS ComponentType, P.APNO, MAX(C.ChangeDate) OVER (PARTITION BY P.Apno) AS [DateClosed] INTO #tmpPersonalReference 
  FROM ChangeLog AS C(NOLOCK) 
  INNER JOIN PersRef AS P(NOLOCK) ON C.ID = P.PersRefID 
  INNER JOIN #tmp t with(nolock) ON p.APNO	= t.APNO	
  WHERE C.ChangeDate >= t.ApDate     
  AND TableName = 'PersRef.SectStat' 
  AND NewValue IN ('2','3','4','5','6','7','A','B') AND P.IsOnReport = 1 

  ORDER BY C.ChangeDate DESC
  --SELECT * FROM #tmpPersonalReference

  SELECT 'Crim' AS ComponentType, X.APNO, MAX(C.ChangeDate) OVER (PARTITION BY X.Apno) AS [DateClosed] INTO #tmpCrim 
  FROM ChangeLog AS C(NOLOCK) 
  INNER JOIN Crim AS X(NOLOCK) ON C.ID = X.CrimID 
  INNER JOIN #tmp t with(nolock) ON x.APNO	= t.APNO	
  WHERE C.ChangeDate >=t.apdate 
  AND TableName = 'Crim.Clear' 
  AND NewValue IN ('T','F','P') AND X.IsHidden = 0   
  ORDER BY C.ChangeDate DESC
  --SELECT * FROM #tmpCrim

  SELECT ComponentType, Apno,[DateClosed]
	INTO #tmpComponents
  FROM 
  (
  SELECT DISTINCT * FROM #tmpEmployment
  UNION ALL
  SELECT DISTINCT * FROM #tmpEducation
  UNION ALL
  SELECT DISTINCT * FROM #tmpPersonalReference
  UNION ALL
  SELECT DISTINCT * FROM #tmpCrim
  ) AS Y

  --SELECT * FROM #tmpComponents ORDER BY Apno ASC, [DateClosed] DESC

  SELECT distinct apno, MAX(DateClosed)  AS [DateClosed]	INTO #tmpMaxCloseDate
  FROM #tmpComponents 
  GROUP BY APNO
  ORDER BY Apno ASC

  --SELECT * FROM #tmpMaxCloseDate ORDER BY Apno ASC, [DateClosed] DESC

  SELECT C.ComponentType, CD.*
	INTO #tmpFinalClosedDateForComponent
  FROM #tmpMaxCloseDate AS CD
  INNER JOIN #tmpComponents AS C ON CD.DateClosed = C.DateClosed
  ORDER BY Apno ASC, [DateClosed] DESC

  --SELECT * FROM #tmpFinalClosedDateForComponent ORDER BY Apno ASC, [DateClosed] DESC
  --SELECT * FROM #tmp

  SELECT T.APNO AS [Report Number], T.ApDate AS [Report Date],T.CLNO, T.ClientName, 
  isnull(T.AffiliateID,'') AS AffiliateID, REPLACE(REPLACE(isnull(T.Affiliate,''), CHAR(10),';'),CHAR(13),';') AS Affiliate, T.[Applicant First Name],T.[Applicant Last Name],
		 F.ComponentType AS [Last Item Type to Close],T.ReopenDate AS [Component Re-Open Date], F.DateClosed [Component Close Date], T.[Date Report Closed], 
		 [dbo].[ElapsedBusinessDays_2](T.ApDate,T.[Date Report Closed]) [Report TAT] 
  FROM #tmpFinalClosedDateForComponent AS F
  INNER JOIN #tmp AS T ON F.Apno = T.APNO
  ORDER BY T.ApDate ASC, [DateClosed] DESC

IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
  DROP TABLE #tmp
IF OBJECT_ID('tempdb..#tmpEmployment') IS NOT NULL
  DROP TABLE #tmpEmployment
IF OBJECT_ID('tempdb..#tmpEducation') IS NOT NULL
  DROP TABLE #tmpEducation
IF OBJECT_ID('tempdb..#tmpPersonalReference') IS NOT NULL
  DROP TABLE #tmpPersonalReference
IF OBJECT_ID('tempdb..#tmpCrim') IS NOT NULL
  DROP TABLE #tmpCrim
IF OBJECT_ID('tempdb..#tmpComponents') IS NOT NULL
  DROP TABLE #tmpComponents
IF OBJECT_ID('tempdb..#tmpMaxCloseDate') IS NOT NULL
  DROP TABLE #tmpMaxCloseDate
IF OBJECT_ID('tempdb..#tmpFinalClosedDateForComponent') IS NOT NULL
  DROP TABLE #tmpFinalClosedDateForComponent

SET TRANSACTION ISOLATION LEVEL READ COMMITTED		 

SET NOCOUNT OFF	
END

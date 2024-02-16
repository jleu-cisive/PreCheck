-- =============================================
-- Author:		DEEPAK VODETHELA	
-- Create date: 09/11/2017
-- Description:	QReport that identifies the last component completed prior to the background check report being closed
-- Execution: Last_Section_Completed_Detail '09/08/2017','09/11/2017',0,0
--			  Last_Section_Completed_Detail '08/01/2017','08/31/2017',0,177
--			  Last_Section_Completed_Detail '08/01/2017','08/31/2017',12829,0
--			  Last_Section_Completed_Detail '08/01/2017','08/31/2017',8507,30
--Modified By Amy Liu on 05/14/2018: HDT32781: using reportDate and [report closed] column to get [report TAT] instead of [Component Close Date] and [Date Report Closed] column
--Modified By Amy Liu on 07/19/2018: HDT36348: Another request from Brian Silver says the report just hangs
--Modified By Abhijit Awari on 07/01/2022: HDT3562: To add two columns (Original Report TAT) and Elapsed Time of TBF (Hours) and exclude start date from original closure date check.
--Modified By Abhijit Awari on 07/25/2022: HDT57737: To add license and crim.status tables.
--EXEC [dbo].[Last_Section_Completed_Detail] '08/01/2020','08/31/2020',0,4
/* Modified By: Vairavan A
-- Modified Date: 07/05/2022
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
EXEC Last_Section_Completed_Detail '03/01/2020','06/25/2020',0,'0'
EXEC Last_Section_Completed_Detail '03/01/2020','06/25/2020',0,'4'
EXEC Last_Section_Completed_Detail '03/01/2020','06/25/2020',0,'4:8'
*/
-- =============================================
CREATE PROCEDURE [dbo].[Last_Section_Completed_Detail]
(
	-- Add the parameters for the stored procedure here
	@StartDate DATETIME,
	@EndDate DATETIME,
	@Clno INT,
 -- @AffiliateID int--code commented by vairavan for ticket id -53763
  @AffiliateIDs varchar(MAX) = '0'--code added by vairavan for ticket id -53763
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

		--code added by vairavan for ticket id -53763 starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END
	--code added by vairavan for ticket id -53763 ends

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
		IF OBJECT_ID('tempdb..#tmpLic') IS NOT NULL
		  DROP TABLE #tmpLic -- Added  By Abhijit Awari on 07/25/2022 for HDT57737
		IF OBJECT_ID('tempdb..#tmpComponents') IS NOT NULL
		  DROP TABLE #tmpComponents
		IF OBJECT_ID('tempdb..#tmpMaxCloseDate') IS NOT NULL
		  DROP TABLE #tmpMaxCloseDate
		IF OBJECT_ID('tempdb..#tmpFinalClosedDateForComponent') IS NOT NULL
		  DROP TABLE #tmpFinalClosedDateForComponent

	SELECT APNO, A.CLNO, C.Name AS ClientName,RA.AffiliateID, RA.Affiliate, A.First AS [Applicant First Name], A.Last AS [Applicant Last Name], ApDate, CompDate [Date Report Closed], A.ReopenDate, A.OrigCompDate
	--Modified by Humera Ahmed to add report/component Re-Open Date
		INTO #tmp
	FROM Appl  AS A with(NOLOCK)
	INNER JOIN Client AS C with(NOLOCK) ON A.CLNO = C.CLNO
	LEFT JOIN refAffiliate AS RA WITH (NOLOCK) ON isnull(C.AffiliateID,0) = RA.AffiliateID
	WHERE ApStatus = 'F' 
	  AND cast(OrigCompDate as Date) BETWEEN DATEADD(d,1,@StartDate) AND @EndDate  --updated @StartDate to DATEADD(d,1,@StartDate) to exclude it by Abhijit Awari #3562
	  AND (isnull(@clno, 0)=0 OR a.clno=@Clno)
	  --AND (isnull(@AffiliateID,0)=0 OR ra.AffiliateID = @AffiliateID)--code commented by vairavan for ticket id -53763
	    and (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763

  SELECT 'Employment' AS ComponentType, E.APNO,E.IsIntl AS [IsIntl], MAX(C.ChangeDate) OVER (PARTITION BY E.Apno) AS [DateClosed] INTO #tmpEmployment 
  FROM ChangeLog AS C with(NOLOCK) 
  INNER JOIN Empl AS E with(NOLOCK) ON C.ID = E.EmplID
  INNER JOIN  #tmp t with(nolock) ON E.Apno	= t.apno
  WHERE C.ChangeDate >=t.ApDate
  AND TableName = 'Empl.SectStat' 
  AND NewValue IN ('2','3','4','5','6','7','A','B') AND E.IsOnReport = 1  	 
  ORDER BY C.ChangeDate DESC
  --SELECT * FROM #tmpEmployment
  
  SELECT 'Education' AS ComponentType, E.APNO,E.IsIntl AS [IsIntl], MAX(C.ChangeDate) OVER (PARTITION BY E.Apno) AS [DateClosed] INTO #tmpEducation 
  FROM ChangeLog AS C with(NOLOCK) 
  INNER JOIN Educat AS E with(NOLOCK) ON C.ID = E.Educatid 
  INNER JOIN #tmp t with(NOLOCK) ON e.APNO	= t.APNO	
  WHERE C.ChangeDate >= t.apdate
  AND TableName = 'Educat.SectStat' 
  AND NewValue IN ('2','3','4','5','6','7','A','B') AND E.IsOnReport = 1 
  ORDER BY C.ChangeDate DESC
  --SELECT * FROM #tmpEducation

  SELECT 'Personal Reference' AS ComponentType, P.APNO, NULL AS [IsIntl], MAX(C.ChangeDate) OVER (PARTITION BY P.Apno) AS [DateClosed] INTO #tmpPersonalReference 
  FROM ChangeLog AS C with(NOLOCK) 
  INNER JOIN PersRef AS P with(NOLOCK) ON C.ID = P.PersRefID 
  INNER JOIN #tmp t with(nolock) ON p.APNO	= t.APNO	
  WHERE C.ChangeDate >= t.ApDate     
  AND TableName = 'PersRef.SectStat' 
  AND NewValue IN ('2','3','4','5','6','7','A','B') AND P.IsOnReport = 1 

  ORDER BY C.ChangeDate DESC
  --SELECT * FROM #tmpPersonalReference

  SELECT 'Crim' AS ComponentType, X.APNO, NULL AS [IsIntl], MAX(C.ChangeDate) OVER (PARTITION BY X.Apno) AS [DateClosed] INTO #tmpCrim 
  FROM ChangeLog AS C with(NOLOCK) 
  INNER JOIN Crim AS X with(NOLOCK) ON C.ID = X.CrimID 
  INNER JOIN #tmp t with(nolock) ON x.APNO	= t.APNO	
  WHERE C.ChangeDate >=t.apdate 
  AND (TableName = 'Crim.Clear'  or TableName = 'Crim.Status')-- Added  By Abhijit Awari on 07/25/2022 for HDT57737
  AND NewValue IN ('T','F','P') AND X.IsHidden = 0   
  ORDER BY C.ChangeDate DESC
  --SELECT * FROM #tmpCrim

  -- Added  By Abhijit Awari on 07/25/2022 for HDT57737
  SELECT 'License' AS ComponentType, X.APNO, NULL AS [IsIntl], MAX(C.ChangeDate) OVER (PARTITION BY X.Apno) AS [DateClosed] INTO #tmpLic 
  FROM ChangeLog AS C with(NOLOCK) 
  INNER JOIN ProfLic AS X with(NOLOCK) ON C.ID = X.ProfLicID 
  INNER JOIN #tmp t with(nolock) ON x.APNO	= t.APNO	
  WHERE C.ChangeDate >=t.apdate 

  SELECT ComponentType, Apno,[IsIntl],[DateClosed]
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
  UNION ALL
  SELECT DISTINCT * FROM #tmpLic-- Added  By Abhijit Awari on 07/25/2022 for HDT57737
  ) AS Y

  --SELECT * FROM #tmpComponents ORDER BY Apno ASC, [DateClosed] DESC

  SELECT distinct apno, MAX(DateClosed)  AS [DateClosed]	INTO #tmpMaxCloseDate
  FROM #tmpComponents 
  GROUP BY APNO
  ORDER BY Apno ASC

  --SELECT * FROM #tmpMaxCloseDate ORDER BY Apno ASC, [DateClosed] DESC

  SELECT C.ComponentType, C.IsIntl, CD.*
	INTO #tmpFinalClosedDateForComponent
  FROM #tmpMaxCloseDate AS CD
  INNER JOIN #tmpComponents AS C ON CD.DateClosed = C.DateClosed
  ORDER BY Apno ASC, [DateClosed] DESC

  --SELECT * FROM #tmpFinalClosedDateForComponent ORDER BY Apno ASC, [DateClosed] DESC
  --SELECT * FROM #tmp

  SELECT T.APNO AS [Report Number], T.ApDate AS [Report Date],T.CLNO, T.ClientName, 
  isnull(T.AffiliateID,'') AS AffiliateID, REPLACE(REPLACE(isnull(T.Affiliate,''), CHAR(10),';'),CHAR(13),';') AS Affiliate, T.[Applicant First Name],T.[Applicant Last Name],
		 F.ComponentType AS [Last Item Type to Close],CASE WHEN F.IsIntl IS NULL THEN '' WHEN F.IsIntl = 0 THEN 'NO' ELSE 'YES' END AS [Is International],T.ReopenDate AS [Component Re-Open Date], F.DateClosed [Component Close Date], T.[Date Report Closed], 
		 [dbo].[ElapsedBusinessDays_2](T.ApDate,T.[Date Report Closed]) [Report TAT] 
		 ,[dbo].[ElapsedBusinessDays_2](T.Apdate, T.OrigCompDate) [Original Report TAT] --uncommented by Abhijit Awari #3562
		 ,[dbo].[ElapsedBusinessHours_2](F.DateClosed,T.[Date Report Closed]) [ElapsedHoursOnTBF]  --uncommented by Abhijit Awari #3562
  FROM #tmpFinalClosedDateForComponent AS F
  INNER JOIN #tmp AS T ON F.Apno = T.APNO
  ORDER BY T.ApDate ASC, [DateClosed] DESC


SET TRANSACTION ISOLATION LEVEL READ COMMITTED		 

SET NOCOUNT OFF	
END

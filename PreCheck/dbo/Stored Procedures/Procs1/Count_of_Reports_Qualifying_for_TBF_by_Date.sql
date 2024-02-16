-- =============================================    
-- Author: Mainak Bhadra    
-- Requester: Kerri Saldaña  
-- Create date: 09/28/2022    
-- Description: To find out Count of Reports Qualifying for TBF by Date    
-- Execution: EXEC [dbo].[Count_of_Reports_Qualifying_for_TBF_by_Date_rollback] '8/8/2022','8/8/2022'
-- =============================================    

create PROCEDURE [dbo].[Count_of_Reports_Qualifying_for_TBF_by_Date] 
(
@StartDate DATETIME,
@EndDate DATETIME
)

AS
BEGIN

		--DECLARE @StartDate DATETIME = '8/8/2022',
		--@EndDate DATETIME = '8/8/2022';

		SET NOCOUNT ON;
		IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
			DROP TABLE #tmp;
		IF OBJECT_ID('tempdb..#tmpEmployment') IS NOT NULL
			DROP TABLE #tmpEmployment;
		IF OBJECT_ID('tempdb..#tmpEmployment1') IS NOT NULL
			DROP TABLE #tmpEmployment1;
		IF OBJECT_ID('tempdb..#tmpEducation') IS NOT NULL
			DROP TABLE #tmpEducation;
		IF OBJECT_ID('tempdb..#tmpEducation1') IS NOT NULL
			DROP TABLE #tmpEducation1;
		IF OBJECT_ID('tempdb..#tmpPersonalReference') IS NOT NULL
			DROP TABLE #tmpPersonalReference;
		IF OBJECT_ID('tempdb..#tmpPersonalReference1') IS NOT NULL
			DROP TABLE #tmpPersonalReference1;
		IF OBJECT_ID('tempdb..#tmpCrim') IS NOT NULL
			DROP TABLE #tmpCrim;
		IF OBJECT_ID('tempdb..#tmpCrim1') IS NOT NULL
			DROP TABLE #tmpCrim1;
		IF OBJECT_ID('tempdb..#tmpLic') IS NOT NULL
			DROP TABLE #tmpLic; -- Added  By Abhijit Awari on 07/25/2022 for HDT57737  
		IF OBJECT_ID('tempdb..#tmpComponents') IS NOT NULL
			DROP TABLE #tmpComponents;
		IF OBJECT_ID('tempdb..#tmpMaxCloseDate') IS NOT NULL
			DROP TABLE #tmpMaxCloseDate;
		IF OBJECT_ID('tempdb..#tmpFinalClosedDateForComponent') IS NOT NULL
			DROP TABLE #tmpFinalClosedDateForComponent;

		SELECT A.APNO,
			   A.ApDate,
			   A.UserID AS ClientCAM,
			   A.CompDate [Date Report Closed]
		INTO #tmp
		FROM dbo.Appl AS A WITH (NOLOCK)
			INNER JOIN dbo.Client AS C WITH (NOLOCK)
				ON A.CLNO = C.CLNO
			LEFT JOIN dbo.refAffiliate AS RA WITH (NOLOCK)
				ON ISNULL(C.AffiliateID, 0) = RA.AffiliateID
		WHERE A.ApStatus = 'F'
			  AND CAST(OrigCompDate AS DATE)
			  BETWEEN @StartDate AND @EndDate;


		-- Employment Section
		SELECT E.Apno,
			   C.ChangeDate,
			   C.HEVNMgmtChangeLogID
		INTO #tmpEmployment1
		FROM dbo.ChangeLog AS C WITH (NOLOCK)
			INNER JOIN dbo.Empl AS E WITH (NOLOCK)
				ON C.ID = E.EmplID
			INNER JOIN #tmp t WITH (NOLOCK)
				ON E.Apno = t.APNO
		WHERE C.ChangeDate >= t.ApDate
			  AND C.TableName = 'Empl.SectStat'
			  AND E.IsOnReport = 1;


		SELECT 'Employment' AS ComponentType,
			   t.APNO,
			   MAX(t.ChangeDate) AS [DateClosed]
		INTO #tmpEmployment
		FROM #tmpEmployment1 t
			JOIN dbo.ChangeLog AS C WITH (INDEX (PK_ChangeLog_2018),NOLOCK)
				ON C.HEVNMgmtChangeLogID = t.HEVNMgmtChangeLogID
		WHERE C.NewValue IN ( '2', '3', '4', '5', '6', '7', 'A', 'B' )
		GROUP BY t.APNO;
		--SELECT * FROM #tmpEmployment  	

		-- Education Section
		SELECT E.APNO,
			   C.ChangeDate,C.HEVNMgmtChangeLogID
		INTO #tmpEducation1
		FROM dbo.ChangeLog AS C WITH (NOLOCK)
			INNER JOIN dbo.Educat AS E WITH (NOLOCK)
				ON C.ID = E.EducatID
			INNER JOIN #tmp t WITH (NOLOCK)
				ON E.APNO = t.APNO
		WHERE C.ChangeDate >= t.ApDate
			  AND C.TableName = 'Educat.SectStat'
			  AND E.IsOnReport = 1
		 

		SELECT 'Education' AS ComponentType,
			   t.APNO,
			   MAX(t.ChangeDate) AS [DateClosed]
		INTO #tmpEducation
		FROM #tmpEducation1 t
			INNER JOIN dbo.ChangeLog AS C WITH (INDEX (PK_ChangeLog_2018),NOLOCK) ON C.HEVNMgmtChangeLogID = t.HEVNMgmtChangeLogID
		WHERE C.NewValue IN ( '2', '3', '4', '5', '6', '7', 'A', 'B' )
		GROUP BY t.APNO;
		--SELECT * FROM #tmpEducation  


		-- Personal Reference Section
		SELECT  P.APNO,
			   C.ChangeDate,C.HEVNMgmtChangeLogID
		INTO #tmpPersonalReference1
		FROM dbo.ChangeLog AS C WITH (NOLOCK)
			INNER JOIN dbo.PersRef AS P WITH (NOLOCK)
				ON C.ID = P.PersRefID
			INNER JOIN #tmp t WITH (NOLOCK)
				ON P.APNO = t.APNO
		WHERE C.ChangeDate >= t.ApDate
			  AND C.TableName = 'PersRef.SectStat'
			  AND P.IsOnReport = 1

		SELECT 'Personal Reference' AS ComponentType,
			   t.APNO,
			   MAX(t.ChangeDate) AS [DateClosed]
		INTO #tmpPersonalReference
		FROM #tmpPersonalReference1 t
			INNER JOIN dbo.ChangeLog AS C WITH (INDEX (PK_ChangeLog_2018),NOLOCK) ON C.HEVNMgmtChangeLogID = t.HEVNMgmtChangeLogID
		WHERE C.NewValue IN ( '2', '3', '4', '5', '6', '7', 'A', 'B' )
		GROUP BY t.APNO;


		-- Crim Section
		SELECT X.APNO,
			   C.ChangeDate,
			   C.HEVNMgmtChangeLogID
		INTO #tmpCrim1
		FROM dbo.ChangeLog AS C WITH (NOLOCK)
			INNER JOIN dbo.Crim AS X WITH (NOLOCK)
				ON C.ID = X.CrimID
			INNER JOIN #tmp t WITH (NOLOCK)
				ON X.APNO = t.APNO
		WHERE C.ChangeDate >= t.ApDate
			  AND
			  (
				  C.TableName = 'Crim.Clear'
				  OR C.TableName = 'Crim.Status'
			  )
			  AND X.IsHidden = 0;


		SELECT 'Crim' AS ComponentType,
			   t.APNO,
			   MAX(t.ChangeDate) AS [DateClosed]
		INTO #tmpCrim
		FROM #tmpCrim1 t
			JOIN dbo.ChangeLog c WITH (INDEX (PK_ChangeLog_2018),NOLOCK)
				ON c.HEVNMgmtChangeLogID = t.HEVNMgmtChangeLogID
		WHERE c.NewValue IN ( 'T', 'F', 'P' )
		GROUP BY t.APNO;
		--SELECT * FROM #tmpCrim 


		-- License Section
		SELECT 'License' AS ComponentType,
			   X.Apno,
			   MAX(C.ChangeDate) AS [DateClosed]
		INTO #tmpLic
		FROM dbo.ChangeLog AS C WITH (NOLOCK)
			INNER JOIN dbo.ProfLic AS X WITH (NOLOCK)
				ON C.ID = X.ProfLicID
			INNER JOIN #tmp t WITH (NOLOCK)
				ON X.Apno = t.APNO
		WHERE C.ChangeDate >= t.ApDate
		GROUP BY X.Apno;





		SELECT ComponentType,
			   Apno,
			   [DateClosed]
		INTO #tmpComponents
		FROM
		(
			SELECT DISTINCT
				   *
			FROM #tmpEmployment
			UNION ALL
			SELECT DISTINCT
				   *
			FROM #tmpEducation
			UNION ALL
			SELECT DISTINCT
				   *
			FROM #tmpPersonalReference
			UNION ALL
			SELECT DISTINCT
				   *
			FROM #tmpCrim
			UNION ALL
			SELECT DISTINCT
				   *
			FROM #tmpLic
		) AS Y;



		SELECT DISTINCT
			   apno,
			   MAX(DateClosed) AS [DateClosed]
		INTO #tmpMaxCloseDate
		FROM #tmpComponents
		GROUP BY APNO
		ORDER BY Apno ASC;



		SELECT T.APNO AS [Report Number],
			   T.ClientCAM,
			   [dbo].[ElapsedBusinessHours_2](F.DateClosed, T.[Date Report Closed]) [ElapsedHoursOnTBF]
		FROM #tmpMaxCloseDate AS F
			INNER JOIN #tmp AS T
				ON F.APNO = T.APNO
		ORDER BY T.ApDate ASC,
				 [DateClosed] DESC;

		SET NOCOUNT OFF;

END
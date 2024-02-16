-- =============================================    
-- Author: Mainak Bhadra    
-- Requester: Kerri Saldaña  
-- Create date: 09/28/2022    
-- Description: To find out Count of Reports Qualifying for TBF by Date    
-- Execution: EXEC [dbo].[Count_of_Reports_Qualifying_for_TBF_by_Date_rollback] '8/8/2022','8/8/2022'
/* Modified By: Vairavan
-- Modified Date: 08/03/2023
-- Description: Ticketno - 101869 - Update Logic on QReport
    EXEC [dbo].[Count_of_Reports_Qualifying_for_TBF_by_Date_rollback_cpy] '07/01/2023','08/04/2023'
*/
-- =============================================    

CREATE PROCEDURE [dbo].[Count_of_Reports_Qualifying_for_TBF_by_Date_rollback] 
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
		IF OBJECT_ID('tempdb..#tmpCrim2') IS NOT NULL
			DROP TABLE #tmpCrim2;
		IF OBJECT_ID('tempdb..#tmpLic') IS NOT NULL
			DROP TABLE #tmpLic; -- Added  By Abhijit Awari on 07/25/2022 for HDT57737  
		IF OBJECT_ID('tempdb..#tmpLic1') IS NOT NULL
			DROP TABLE #tmpLic1; -- Added  By Abhijit Awari on 07/25/2022 for HDT57737  
		IF OBJECT_ID('tempdb..#tmpLic2') IS NOT NULL
			DROP TABLE #tmpLic2; -- Added  By Abhijit Awari on 07/25/2022 for HDT57737  
		IF OBJECT_ID('tempdb..#tmpComponents') IS NOT NULL
			DROP TABLE #tmpComponents;
		IF OBJECT_ID('tempdb..#tmpMaxCloseDate') IS NOT NULL
			DROP TABLE #tmpMaxCloseDate;
		IF OBJECT_ID('tempdb..#tmpFinalClosedDateForComponent') IS NOT NULL
			DROP TABLE #tmpFinalClosedDateForComponent;
		IF OBJECT_ID('tempdb..#CAM1End') IS NOT NULL
			DROP TABLE #CAM1End;	
		IF OBJECT_ID('tempdb..#tmpSanctions') IS NOT NULL
			DROP TABLE #tmpSanctions;	
		IF OBJECT_ID('tempdb..#ttmmp') IS NOT NULL
			DROP TABLE #ttmmp;	
		IF OBJECT_ID('tempdb..#tmpCrimVendorWebsite') IS NOT NULL
			DROP TABLE #tmpCrimVendorWebsite;	
  --code added for ticket no -101869 starts 

    CREATE TABLE #CAM1End
    (
        [APNO] [INT] NOT NULL,
        [CAM1EndDate] DATETIME NULL
    );

--code added for ticket no -101869 ends

		SELECT A.APNO,
			   A.ApDate,
			   A.UserID AS ClientCAM,
			   A.CompDate [Date Report Closed],
			   cast(NULL as datetime) AS [CAM1EndDate] --code added for ticket no -101869 ends
		INTO #tmp
		FROM dbo.Appl AS A WITH (NOLOCK)
			INNER JOIN dbo.Client AS C WITH (NOLOCK)
				ON A.CLNO = C.CLNO
			Inner JOIN dbo.refAffiliate AS RA WITH (NOLOCK)
				ON ISNULL(C.AffiliateID, 0) = RA.AffiliateID
		WHERE A.ApStatus = 'F'
		    AND A.CLNO NOT IN ( 2135, 3468 ) --code added for ticket no -101869
			  AND CAST(OrigCompDate AS DATE)
			  BETWEEN @StartDate  AND DATEADD(d, 1, @EndDate);

 --code added for ticket no -101869 starts
    INSERT INTO #tmp
    SELECT     A.APNO,
			   A.ApDate,
			   A.UserID AS ClientCAM,
			   A.CompDate [Date Report Closed],
			   cast(NULL as datetime) AS [CAM1EndDate] --code added for ticket no -101869 ends
    FROM dbo.Appl AS A WITH (NOLOCK)
        INNER JOIN dbo.Client AS C WITH (NOLOCK)
            ON A.CLNO = C.CLNO
      Inner JOIN dbo.refAffiliate AS RA WITH (NOLOCK)
				ON ISNULL(C.AffiliateID, 0) = RA.AffiliateID
    WHERE ApStatus = 'P'
          AND A.CLNO NOT IN ( 2135, 3468 )
          AND
          (
              A.UserID LIKE '%1'
              OR A.UserID LIKE 'QA%'
          )
          AND CAST(A.ApDate AS DATE)
          BETWEEN @StartDate AND DATEADD(d, 1, @EndDate)



		      --Index on temp tables
    CREATE CLUSTERED INDEX IX_tmp_01 ON #tmp (APNO);

    INSERT INTO #CAM1End
    (
        APNO,
        CAM1EndDate
    )
    SELECT A.APNO,
           MAX(cl.ChangeDate) AS [CAM1EndDate]
    FROM #tmp A
        INNER JOIN
        (
            SELECT ID,
                   ChangeDate
                   --OldValue,
                   --NewValue
            FROM dbo.ChangeLog with(nolock)
            WHERE TableName = 'Appl.UserID'
                  AND OldValue LIKE '%1'
        ) cl
            ON A.APNO = cl.ID
    GROUP BY A.APNO;



    UPDATE t
    SET t.CAM1EndDate = c1e.CAM1EndDate
    FROM #tmp t
        LEFT OUTER JOIN #CAM1End c1e
            ON c1e.APNO = t.APNO;


		-- Employment Section
		SELECT E.Apno,
			   C.ChangeDate,
			   C.HEVNMgmtChangeLogID,
			     ROW_NUMBER() OVER (PARTITION BY C.ID ORDER BY C.ChangeDate DESC) AS RowNumber
		INTO #tmpEmployment1
		FROM dbo.ChangeLog AS C WITH (NOLOCK)
			INNER JOIN dbo.Empl AS E WITH (NOLOCK)
				ON C.ID = E.EmplID
			INNER JOIN #tmp t WITH (NOLOCK)
				ON E.Apno = t.APNO
		WHERE  
				--C.ChangeDate >= t.ApDate
			 -- AND 
			  C.TableName = 'Empl.SectStat'
			  AND E.IsOnReport = 1
			    --code added for ticket no -101869  starts
			  and  C.ChangeDate < DATEADD(SECOND,3499,T.[Date Report Closed])
              AND C.ChangeDate
              BETWEEN DATEADD(MM, -4, @StartDate) AND CURRENT_TIMESTAMP ;
			    --code added for ticket no -101869  ends

	
	SELECT 'Employment' AS ComponentType,
			   t.APNO,
			  t.ChangeDate AS [DateClosed]
		INTO #tmpEmployment
		from #tmpEmployment1 t
		where t.RowNumber=1
	

		-- Education Section
		SELECT E.APNO,
			   C.ChangeDate,
			     ROW_NUMBER() OVER (PARTITION BY C.ID ORDER BY C.ChangeDate DESC) AS RowNumber
		INTO #tmpEducation1
		FROM dbo.ChangeLog AS C WITH (NOLOCK)
			INNER JOIN dbo.Educat AS E WITH (NOLOCK)
				ON C.ID = E.EducatID
			INNER JOIN #tmp t WITH (NOLOCK)
				ON E.APNO = t.APNO
		WHERE 
		C.TableName = 'Educat.SectStat'
		AND E.IsOnReport = 1
		  --code added for ticket no -101869  starts 
		AND C.ChangeDate < DATEADD(SECOND,3499,T.[Date Report Closed])
        AND C.ChangeDate
        BETWEEN DATEADD(MM, -4, @StartDate) AND CURRENT_TIMESTAMP
		  --code added for ticket no -101869 ends
		 
		SELECT 'Education' AS ComponentType,
			   t.APNO,
			  t.ChangeDate AS [DateClosed]
		INTO #tmpEducation
		from #tmpEducation1 t
		where t.RowNumber=1


		-- Personal Reference Section
		SELECT  P.APNO,
			   C.ChangeDate,
			      ROW_NUMBER() OVER (PARTITION BY C.ID ORDER BY C.ChangeDate DESC) AS RowNumber
		INTO #tmpPersonalReference1
		FROM dbo.ChangeLog AS C WITH (NOLOCK)
			INNER JOIN dbo.PersRef AS P WITH (NOLOCK)
				ON C.ID = P.PersRefID
			INNER JOIN #tmp t WITH (NOLOCK)
				ON P.APNO = t.APNO
		WHERE
			 C.TableName = 'PersRef.SectStat'
			  AND P.IsOnReport = 1
			    --code added for ticket no -101869 starts
			  AND C.ChangeDate
              BETWEEN DATEADD(MM, -4, @StartDate) AND CURRENT_TIMESTAMP
			    --code added for ticket no -101869  ends

		SELECT 'Personal Reference' AS ComponentType,
			   t.APNO,
			  t.ChangeDate AS [DateClosed]
		INTO #tmpPersonalReference
		from #tmpPersonalReference1 t
		where t.RowNumber=1


		  --code added for ticket no -101869  starts
		;
    WITH Sanctions
    AS (
		 SELECT 'Sanctions' AS ComponentType,
			   P.APNO,
			   p.ChangeDate AS [Last Updated Date],
			   ROW_NUMBER() OVER (PARTITION BY p.MedIntegLogID ORDER BY P.ChangeDate DESC) AS RowNumber
		FROM dbo.Appl T with(nolock)
			INNER JOIN dbo.MedIntegLog AS P WITH (NOLOCK)
				ON T.APNO = P.APNO
		WHERE  P.ChangeDate
					  BETWEEN DATEADD(MM, -4, @StartDate) AND CURRENT_TIMESTAMP)


    SELECT ComponentType,
           APNO,
           [Last Updated Date] as [DateClosed] 
	into #tmpSanctions
    FROM Sanctions
    WHERE RowNumber = 1
	  --code added for ticket no -101869 ends

	  

		

	select   x.apno, X.CrimID,t.[Date Report Closed]
	into #ttmmp
	from dbo.Crim AS X WITH (NOLOCK)
		INNER JOIN #tmp t WITH (NOLOCK)
		ON X.APNO = t.APNO
			AND X.IsHidden = 0
			  
	--SELECT t.APNO,
	--	C.ChangeDate,
	--	ROW_NUMBER() OVER (PARTITION BY C.ID ORDER BY c.ChangeDate DESC) AS RowNumber
	--INTO #tmpCrim1
	--FROM dbo.ChangeLog AS C WITH (NOLOCK)
	--	inner join
	--	#ttmmp t 
	--	on t.CrimID= c.ID
	--	WHERE c.TableName LIKE 'crim%' AND C.ChangeDate < DATEADD(SECOND,3499,T.[Date Report Closed])  

	 
	
	SELECT t.APNO,c.id,c.ChangeDate,t.[Date Report Closed]
	INTO #tmpCrim1
	FROM dbo.ChangeLog AS C WITH (NOLOCK)
	JOIN #ttmmp t ON t.CrimID= c.ID
	WHERE C.ChangeDate < DATEADD(SECOND,3499,t.[Date Report Closed]) 

	SELECT t.APNO,
		t.ChangeDate,
		ROW_NUMBER() OVER (PARTITION BY t.ID ORDER BY t.ChangeDate DESC) AS RowNumber
	INTO #tmpCrim2
	FROM #tmpCrim1 t 
	
	  
		SELECT distinct 'Crim' AS ComponentType,
			   t.APNO,
			  t.ChangeDate AS [DateClosed]
		INTO #tmpCrim
		from #tmpCrim2 t
		where t.RowNumber=1
		
		  --code added for ticket no -101869 starts
		 -- Get all the Crim records which were completed from Criminal Vendor Website
    ;
    WITH CrimVendorWebsite
    AS (SELECT DISTINCT
               'Criminal' AS ComponentType,
               L.APNO,
               L.EnteredDate AS [Last Updated Date],
               ROW_NUMBER() OVER (PARTITION BY L.APNO ORDER BY L.EnteredDate DESC) AS RowNumber
        FROM #tmp T
            INNER JOIN [dbo].[CriminalVendor_Log] AS L WITH (NOLOCK)
                ON T.APNO = L.APNO)

    SELECT ComponentType,
           APNO,
           [Last Updated Date] as [DateClosed] 
	 into #tmpCrimVendorWebsite
    FROM CrimVendorWebsite
    WHERE RowNumber = 1;
	  --code added for ticket no -101869 ends

	SELECT 'License' AS ComponentType,
               P.Apno,
			   c.id,
               C.ChangeDate
			   
               --ROW_NUMBER() OVER (PARTITION BY C.ID ORDER BY C.ChangeDate DESC) AS RowNumber
			INTO #tmpLic1
        FROM #tmp T
            INNER JOIN dbo.ProfLic AS P WITH (NOLOCK)
                ON T.APNO = P.Apno
				and P.IsOnReport = 1
            INNER JOIN dbo.ChangeLog AS C WITH (NOLOCK)
                ON C.ID = P.ProfLicID
				 where C.NewValue IN ( '2', '3', '4', '5', '1', '6', '7', '8', 'B', 'C', 'E', 'U' )
              AND C.ChangeDate BETWEEN DATEADD(MM, -4, @StartDate) AND CURRENT_TIMESTAMP	  
	

		SELECT 'License' AS ComponentType,
			T.Apno,
               t.ChangeDate [Last Updated Date],
               ROW_NUMBER() OVER (PARTITION BY t.ID ORDER BY t.ChangeDate DESC) AS RowNumber
			INTO #tmpLic2
        FROM #tmpLic1 T
            
 --;
 --   WITH License
 --   AS (SELECT 'License' AS ComponentType,
 --              P.Apno,
 --              C.ChangeDate AS [Last Updated Date],
 --              ROW_NUMBER() OVER (PARTITION BY C.ID ORDER BY C.ChangeDate DESC) AS RowNumber
 --       FROM #tmp T
 --           INNER JOIN dbo.ProfLic AS P WITH (NOLOCK)
 --               ON T.APNO = P.Apno
	--			and P.IsOnReport = 1
 --           INNER JOIN dbo.ChangeLog AS C WITH (NOLOCK)
 --               ON C.ID = P.ProfLicID
	--			 AND C.NewValue IN ( '2', '3', '4', '5', '1', '6', '7', '8', 'B', 'C', 'E', 'U' )
 --             AND C.ChangeDate BETWEEN DATEADD(MM, -4, @StartDate) AND CURRENT_TIMESTAMP)

    SELECT ComponentType,
           Apno,
           [Last Updated Date]
		   into #tmpLic
    FROM #tmpLic2
    WHERE RowNumber = 1;

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
			 --code added for ticket no -101869  starts
			UNION ALL
			SELECT DISTINCT
				   *
			FROM #tmpSanctions
			UNION ALL
			SELECT DISTINCT
				   *
			FROM #tmpCrimVendorWebsite
			 --code added for ticket no -101869 ends
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
			 --  [dbo].[ElapsedBusinessHours_2](F.DateClosed, T.[Date Report Closed]) [ElapsedHoursOnTBF]  --code commented for ticket no -101869 
			     CAST([dbo].[ElapsedBusinessDaysInDecimal](CASE WHEN ISNULL(T.CAM1EndDate, '1900-01-01') > F.[DateClosed] THEN T.CAM1EndDate 
		   ELSE F.[DateClosed] END, T.[Date Report Closed])*24 AS INT) 
		   AS ElapsedHoursOnTBF--#99338 New TBF logic
		FROM #tmpMaxCloseDate AS F
			INNER JOIN #tmp AS T
				ON F.APNO = T.APNO
		ORDER BY T.ApDate ASC,
				 [DateClosed] DESC;

		SET NOCOUNT OFF;

END

-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 05/11/2017
-- Description:	Elapsed Time on TBF Detail
-- Modified by:	DEEPAK VODETHELA	
-- Modified Date: 09/28/2017
-- Modified by:	Balaji Sankar -- To include Changelog date partition	
-- Modified Date: 03/02/2018 
-- Execution: EXEC Elapsed_Time_on_TBF_Detail '01/01/2018','01/31/2018', 4, ''
-- =============================================
CREATE PROCEDURE [dbo].[Elapsed_Time_on_TBF_Detail_Balaji]
	-- Add the parameters for the stored procedure here
	@StartDate date,
	@EndDate Date,	
    @AffiliateID int,
	@ClientList varchar(MAX) = NULL
AS
BEGIN

	SET ANSI_WARNINGS OFF 

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL  READ UNCOMMITTED

	IF(@ClientList = '' OR LOWER(@ClientList) = 'null') 
	BEGIN  
		SET @ClientList = NULL  
	END

	--DECLARE temp tables (helps to maintain the same plan regardless of stats change)
	CREATE TABLE #tmp(
		[APNO] [int] NOT NULL,
		[CLNO] [smallint] NOT NULL,
		[ClientName] [varchar](100) NULL,
		[Applicant First Name] [varchar](20) NOT NULL,
		[Applicant Last Name] [varchar](20) NOT NULL,
		[ApDate] [datetime] NULL,
		[CompDate] [datetime] NULL,
		[OrigCompDate] [datetime] NULL,
		[CAM] [varchar](8) NULL)

	CREATE TABLE #tmpAllRec(
		[ComponentType] [varchar](20) NOT NULL,
		[APNO] [int] NOT NULL,
		[Value] [varchar](250) NOT NULL,
		[User Who CLosed] [varchar](100) NULL,
		[DateClosed] [datetime] NULL)

	CREATE TABLE #tmpMaxCloseDate
	([APNO] [int] NOT NULL,
	[DateClosed] [datetime] NULL)

	CREATE TABLE #tmpFinalClosedDateForComponent(
		[ComponentType] [varchar](20) NOT NULL,
		[APNO] [int] NOT NULL,
		[Value] [varchar](250) NOT NULL,
		[User Who CLosed] [varchar](100) NULL,
		[DateClosed] [datetime] NULL)

		--Index on temp tables
	CREATE CLUSTERED INDEX IX_tmp_01 ON #tmp(APNO)
	CREATE CLUSTERED INDEX IX_tmp2_01 ON #tmpFinalClosedDateForComponent(APNO)
	CREATE CLUSTERED INDEX IX_tmp3_01 ON #tmpMaxCloseDate(APNO,DateClosed)

	-- Get all the "Finalized" reports
	INSERT INTO #tmp
	SELECT APNO, A.CLNO, C.Name AS ClientName, A.First AS [Applicant First Name], A.Last AS [Applicant Last Name], ApDate, CompDate, A.OrigCompDate, A.UserID AS CAM
	FROM dbo.Appl(NOLOCK) AS A
	INNER JOIN dbo.Client AS C(NOLOCK) ON A.CLNO = C.CLNO
	WHERE ApStatus = 'F' 
	  AND A.CLNO NOT IN (2135,3468)
	  --AND A.ApDate BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(D,1,@EndDate)) -- commented by schapyala and modified to use OrigCompDate based on Brian Silver Request HDT 29664
	  AND cast(OrigCompDate as Date) between @startDate and @EndDate

  --SELECT * FROM #tmp ORDER BY ApDate, APNO

  -- Get all the Employment records which were completed from the ChangeLog
  INSERT INTO  #tmpAllRec 
  SELECT 'Employmet' AS ComponentType, E.APNO, E.Employer AS [Value], C.UserID AS [User Who CLosed], MAX(C.ChangeDate) OVER (PARTITION BY E.Apno) AS [DateClosed] 
  FROM dbo.ChangeLog AS C(NOLOCK) INNER JOIN dbo.Empl AS E(NOLOCK) 
  ON C.ID = E.EmplID AND C.ChangeDate BETWEEN DATEADD(MM,-4, @StartDate) AND CURRENT_TIMESTAMP
  INNER JOIN #tmp T ON T.APNO = E.APNO 
  WHERE TableName = 'Empl.SectStat' 
  AND NewValue IN ('2','3','4','5','6','7','A','B') 
  AND E.IsOnReport = 1 
  
 -- Get all the Education records which were completed from the ChangeLog
  INSERT INTO  #tmpAllRec 
  SELECT 'Education' AS ComponentType, E.APNO, E.School AS [Value], C.UserID AS [User Who CLosed], MAX(C.ChangeDate) OVER (PARTITION BY E.Apno) AS [DateClosed] 
  FROM ChangeLog AS C(NOLOCK) INNER JOIN Educat AS E(NOLOCK) 
  ON C.ID = E.Educatid AND C.ChangeDate BETWEEN DATEADD(MM,-4, @StartDate) AND CURRENT_TIMESTAMP
  INNER JOIN #tmp T ON T.APNO = E.APNO 
  WHERE TableName = 'Educat.SectStat' AND NewValue IN ('2','3','4','5','6','7','A','B') AND E.IsOnReport = 1 
  
 -- Get all the Personal Reference records which were completed from the ChangeLog
  INSERT INTO  #tmpAllRec 	
  SELECT 'Personal Reference' AS ComponentType, P.APNO, P.Name AS [Value], C.UserID AS [User Who CLosed], MAX(C.ChangeDate) OVER (PARTITION BY P.Apno) AS [DateClosed] 
  FROM dbo.ChangeLog AS C(NOLOCK) INNER JOIN dbo.PersRef AS P(NOLOCK) 
  ON C.ID = P.PersRefID AND C.ChangeDate BETWEEN DATEADD(MM,-4, @StartDate) AND CURRENT_TIMESTAMP
  INNER JOIN #tmp T ON T.APNO = P.APNO 
  WHERE TableName = 'PersRef.SectStat' AND NewValue IN ('2','3','4','5','6','7','A','B') AND P.IsOnReport = 1 
  
 -- Get all the Crim records which were completed from the ChangeLog
  INSERT INTO  #tmpAllRec
  SELECT 'Crim' AS ComponentType, X.APNO, X.County AS [Value], C.UserID AS [User Who CLosed], MAX(C.ChangeDate) OVER (PARTITION BY X.Apno) AS [DateClosed] 
  FROM ChangeLog AS C(NOLOCK) INNER JOIN Crim AS X(NOLOCK) 
  ON C.ID = X.CrimID AND C.ChangeDate BETWEEN DATEADD(MM,-4, @StartDate) AND CURRENT_TIMESTAMP
  INNER JOIN #tmp T ON T.APNO = X.APNO 
  WHERE TableName = 'Crim.Clear' AND NewValue IN ('T','F','P') AND X.IsHidden = 0 
  
  --SELECT * FROM #tmpComponents ORDER BY Apno ASC, [DateClosed] DESC
  -- Get the Latest Updated date for each report#
  INSERT 	INTO #tmpMaxCloseDate
  SELECT APNO,
		 MAX(DateClosed) OVER (PARTITION BY APNO) AS [DateClosed]
  FROM #tmpAllRec 
  GROUP BY ComponentType, APNO, DateClosed
  
  --SELECT * FROM #tmpMaxCloseDate ORDER BY Apno ASC, [DateClosed] DESC
  -- Get everything into one place to display
  INSERT INTO #tmpFinalClosedDateForComponent (ComponentType, [Value],[User Who CLosed], APNO,[DateClosed])
  SELECT DISTINCT C.ComponentType, C.Value, C.[User Who CLosed], CD.*
  FROM #tmpMaxCloseDate AS CD
  INNER JOIN #tmpAllRec AS C ON CD.DateClosed = C.DateClosed AND CD.APNO = C.APNO
  
  --SELECT * FROM #tmpFinalClosedDateForComponent ORDER BY Apno ASC, [DateClosed] DESC

   SELECT T.CLNO, T.ClientName, T.APNO, T.ApDate, T.OrigCompDate, T.CompDate, T.[Applicant First Name],T.[Applicant Last Name], T.CAM, F.[User Who CLosed],
		 [dbo].[ElapsedBusinessDays_2](F.DateClosed,T.OrigCompDate) [ElapsedDaysOnTBF],
		 [dbo].[ElapsedBusinessHours_2](F.DateClosed,T.OrigCompDate) [ElapsedHoursOnTBF],
		 F.DateClosed AS [Last Updated Time on Section], F.ComponentType AS [Section], F.Value, 
		 REPLACE(REPLACE(RA.Affiliate, CHAR(10),';'),CHAR(13),';') AS Affiliate, RA.AffiliateID,dbo.elapsedbusinessdays_2( T.Apdate, T.Origcompdate ) TAT
  FROM #tmpFinalClosedDateForComponent AS F
  INNER JOIN #tmp AS T ON F.Apno = T.APNO
  INNER JOIN dbo.CLient C WITH(NOLOCK) ON T.CLNO = C.CLNO
  INNER JOIN dbo.refAffiliate AS RA WITH (NOLOCK) ON C.AffiliateID = RA.AffiliateID
  WHERE (@ClientList IS NULL OR T.CLNO in (SELECT value FROM fn_Split(@ClientList,':')))
	AND RA.AffiliateID = IIF(@AffiliateID = 0,RA.AffiliateID, @AffiliateID)
  ORDER BY T.ApDate ASC, [DateClosed] DESC

  DROP TABLE #tmp
  DROP TABLE #tmpAllRec
  DROP TABLE #tmpMaxCloseDate
  DROP TABLE #tmpFinalClosedDateForComponent


	/* --09/28/2017 - Commented by Deepak. We cannot use Credit, SanctionCheck and DL tables because the LastUpateDate will be updated even when the IsCamReviewed column. 
				-- The business was needing only closed statues to be considered. 

		-- Step1 - Get all the details from Appl table to a temp for a specified date range
		Select * into #tempAppl from APPL A WHERE (A.OrigCompDate >= @Startdate) AND (A.OrigCompDate <= @Enddate) --AND A.ApStatus = 'F'

		--Step 2 - Get all the Section names and Value which have the last updated date
	    SELECT Last_Updated , APNO,  SanctionID,  Section,Value into #TempSections
		FROM (
				(SELECT  Last_Updated, APNO , EmplID as SanctionID, 'Empl' Section, Employer 'Value' FROM dbo.Empl WITH(NOLOCK) WHERE SectStat NOT IN ('0','9') AND IsOnReport = 1 and APNO in (select APNO from #tempAppl))
					UNION ALL
				(SELECT  Last_Updated, APNO, EducatID as SanctionID, 'Educat' Section, School 'Value' FROM dbo.Educat WITH(NOLOCK) WHERE SectStat NOT IN ('0','9') AND IsOnReport = 1 and APNO in (select APNO from #tempAppl))
					UNION ALL
				(SELECT Last_Updated, APNO, PersRefID as SanctionID, 'PersRef' Section, Name 'Value' FROM dbo.PersRef WITH(NOLOCK) WHERE SectStat NOT IN ('0','9') AND IsOnReport = 1 and APNO in (select APNO from #tempAppl))
					UNION ALL
				(SELECT  Last_Updated, APNO, ProfLicID as SanctionID, 'ProfLic' Section, Lic_Type 'Value' FROM dbo.ProfLic WITH(NOLOCK) WHERE SectStat NOT IN ('0','9') AND IsOnReport = 1 and APNO in (select APNO from #tempAppl))
					UNION ALL
				(SELECT  Last_Updated, APNO , Apno as SanctionID, 'PID' Section,'PID' as 'Value' FROM dbo.Credit WITH(NOLOCK) WHERE SectStat NOT IN ('0','9') and reptype ='S' and APNO in (select APNO from #tempAppl))
					UNION ALL
				(SELECT  Last_Updated, APNO , Apno as SanctionID, 'Credit' Section,'Credit' as 'Value' FROM dbo.Credit WITH(NOLOCK) WHERE SectStat NOT IN ('0','9') and reptype ='C' and APNO in (select APNO from #tempAppl))
					UNION ALL
				(SELECT  Last_Updated, APNO, Apno as SanctionID, 'Sanction Check' Section,'Sanction Check' as 'Value' FROM dbo.MedInteg WITH(NOLOCK) WHERE SectStat NOT IN ('0','9')  and APNO in (select APNO from #tempAppl))
					UNION ALL
				(SELECT  Last_Updated, APNO, Apno as SanctionID, 'DL' Section ,'MVR' as 'Value' FROM dbo.DL WITH(NOLOCK) WHERE SectStat NOT IN ('0','9') and APNO in (select APNO from #tempAppl))
					UNION ALL
				(SELECT  Last_Updated, APNO, CrimID as SanctionID, 'Crim' Section,County 'Value' FROM dbo.Crim  WITH(NOLOCK) WHERE ISNULL(Clear, '') NOT IN ('','R','M','O', 'V','W','X','E','N','I','Q','Z') AND ishidden = 0 and APNO in (select APNO from #tempAppl))
		) AS X 	WHERE Last_Updated < CURRENT_TIMESTAMP 


		--Step 3 - Get the max of last updated date and apno from Sections into a temp table
		SELECT MAX(Last_Updated) AS Last_Updated, APNO into #tempMaxdate
		FROM #TempSections GROUP BY APNO


		--Step 4 - Get all the details into a temp table from Sections and Max Date joining on apno and last updated date.
		Select T.* into #tempLastmodifiedsection from #TempSections t INNER JOIN #tempMaxdate T1 ON t.apno = t1.apno AND T.Last_Updated = T1.Last_Updated ORDER BY apno

		--Step 5 - Get the Elapsed Days from the Last Updated Date 
		SELECT C.CLNO,  C.Name AS ClientName,  A.APNO, A.ApDate, A.OrigCompDate,A.CompDate, A.First, A.Last, A.UserID as CAM, A.Investigator AS 'User Who CLosed',
		dbo.elapsedbusinessdays_2( Y.Last_Updated, A.Origcompdate) as ElapsedDaysOnTBF, 
		Y.Last_updated as 'Last Updated Time on Section',Section,Value, rf.Affiliate, C.AffiliateID
		INTO #ElapsedTimeOnTBFDetail
		FROM #tempAppl A  WITH(NOLOCK)
		INNER JOIN dbo.Client C WITH(NOLOCK)ON A.CLNO = C.CLNO
		INNER JOIN dbo.refAffiliate rf WITH(NOLOCK) ON C.AffiliateID = rf.AffiliateID
		LEFT JOIN 	#tempLastmodifiedsection  Y ON Y.APNO = A.APNO		
		WHERE		 
		C.AffiliateID = IIF(@AffiliateID=0,C.AffiliateID,@AffiliateID)
		and A.CLNO not in (3468)
		AND (@ClientList IS NULL OR A.CLNO in (SELECT value FROM fn_Split(@ClientList,':')))

		--Step 6 - Final result 
		Select * from #ElapsedTimeOnTBFDetail Order by 1 ASC

		--Step 7 - Drop all the temp tables
		DROP TABLE #tempAppl
		DROP TABLE #TempSections
		DROP TABLE #tempMaxdate
		DROP TABLE #tempLastmodifiedsection
		DROP TABLE #ElapsedTimeOnTBFDetail
		*/
End

-- =============================================
-- Author:		Deepak Vodethela
-- Create date: 04/05/2018
-- Description:	Q report which will track applications completed by date range and by CAM which will show whether or not the app was In Progress Reviewed and whether or not the app was closed by Auto Close.
-- Execution: EXEC IPR_And_AutoClose_Audit_Report '01/01/2018','01/31/2018', 0, NULL,NULL
--			  EXEC IPR_And_AutoClose_Audit_Report '01/01/2018','01/31/2018',0,'12305:6122:7519:5762:10576:9929',NULL
--			  EXEC IPR_And_AutoClose_Audit_Report '01/01/2018','01/31/2018',0,'12305:6122:7519:5762:10576:9929','PSisson'
-- =============================================

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
Execution:
EXEC IPR_And_AutoClose_Audit_Report '01/01/2018','01/31/2018', '4', NULL,NULL
EXEC IPR_And_AutoClose_Audit_Report '01/01/2018','01/31/2018',4,'12305:6122:7519:5762:10576:9929',NULL
EXEC IPR_And_AutoClose_Audit_Report '01/01/2018','01/31/2018',0,'12305:6122:7519:5762:10576:9929','PSisson'

*/


CREATE PROCEDURE [dbo].[IPR_And_AutoClose_Audit_Report]  
	-- Add the parameters for the stored procedure here
	@StartDate date,
	@EndDate Date,	
    -- @AffiliateID int, --code added by Sunil Mandal for ticket id -53763
	@AffiliateIDs varchar(MAX) = '0',  --code added by Sunil Mandal for ticket id -53763
	@ClientList varchar(MAX) = NULL,
	@CAM varchar(8) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--code added by Sunil Mandal for ticket id -53763 starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END
     --code added by Sunil Mandal for ticket id -53763 Ends	

    -- Insert statements for procedure here
SET TRANSACTION ISOLATION LEVEL  READ UNCOMMITTED

	IF(@ClientList = '' OR LOWER(@ClientList) = 'null') 
	BEGIN  
		SET @ClientList = NULL  
	END

	--DECLARE temp tables (helps to maintain the same plan regardless of stats change)
	CREATE TABLE #tmp(
		[APNO] [int] NOT NULL,
		[ApDate] [datetime] NULL,
		[CLNO] [smallint] NOT NULL,
		[ClientName] [varchar](100) NULL,
		[OrigCompDate] [datetime] NULL,
		[CAM] [varchar](8) NULL,
		[InProgressReviewed] BIT)

	CREATE TABLE #tmpAllRec(
		[ComponentType] [varchar](20) NOT NULL,
		[APNO] [int] NOT NULL,
		[DateClosed] [datetime] NULL)

	CREATE TABLE #tmpMaxCloseDate
	([APNO] [int] NOT NULL,
	[DateClosed] [datetime] NULL)

	CREATE TABLE #tmpFinalClosedDateForComponent(
		[ComponentType] [varchar](20) NOT NULL,
		[APNO] [int] NOT NULL,
		[DateClosed] [datetime] NULL)

		--Index on temp tables
	CREATE CLUSTERED INDEX IX_tmp_01 ON #tmp(APNO)
	CREATE CLUSTERED INDEX IX_tmp2_01 ON #tmpFinalClosedDateForComponent(APNO)
	CREATE CLUSTERED INDEX IX_tmp3_01 ON #tmpMaxCloseDate(APNO,DateClosed)

	-- Get all the "Finalized" reports
	INSERT INTO #tmp
	SELECT APNO, ApDate, A.CLNO, C.Name AS ClientName, A.OrigCompDate, A.UserID AS CAM, InProgressReviewed
	FROM dbo.Appl(NOLOCK) AS A
	INNER JOIN dbo.Client AS C(NOLOCK) ON A.CLNO = C.CLNO
	WHERE ApStatus = 'F' 
	  AND A.CLNO NOT IN (2135,3468)
	  AND CAST(OrigCompDate AS DATE) BETWEEN @startDate AND @EndDate

	--SELECT * FROM #tmp ORDER BY ApDate, APNO

	-- Get all the Employment records which were completed from the ChangeLog
	INSERT INTO  #tmpAllRec 
	SELECT 'Employmet' AS ComponentType, E.APNO, MAX(C.ChangeDate) OVER (PARTITION BY E.Apno) AS [DateClosed] 
	FROM dbo.ChangeLog AS C(NOLOCK) INNER JOIN dbo.Empl AS E(NOLOCK) 
	ON C.ID = E.EmplID AND C.ChangeDate BETWEEN DATEADD(MM,-4, @StartDate) AND CURRENT_TIMESTAMP
	INNER JOIN #tmp T ON T.APNO = E.APNO 
	WHERE TableName = 'Empl.SectStat' 
 	  AND NewValue IN ('2','3','4','5','6','7','A','B') 
	  AND E.IsOnReport = 1 
  
	-- Get all the Education records which were completed from the ChangeLog
	INSERT INTO  #tmpAllRec 
	SELECT 'Education' AS ComponentType, E.APNO, MAX(C.ChangeDate) OVER (PARTITION BY E.Apno) AS [DateClosed] 
	FROM ChangeLog AS C(NOLOCK) INNER JOIN Educat AS E(NOLOCK) 
	ON C.ID = E.Educatid AND C.ChangeDate BETWEEN DATEADD(MM,-4, @StartDate) AND CURRENT_TIMESTAMP
	INNER JOIN #tmp T ON T.APNO = E.APNO 
	WHERE TableName = 'Educat.SectStat' AND NewValue IN ('2','3','4','5','6','7','A','B') AND E.IsOnReport = 1 
  
	-- Get all the Personal Reference records which were completed from the ChangeLog
	INSERT INTO  #tmpAllRec 	
	SELECT 'Personal Reference' AS ComponentType, P.APNO, MAX(C.ChangeDate) OVER (PARTITION BY P.Apno) AS [DateClosed] 
	FROM dbo.ChangeLog AS C(NOLOCK) INNER JOIN dbo.PersRef AS P(NOLOCK) 
	ON C.ID = P.PersRefID AND C.ChangeDate BETWEEN DATEADD(MM,-4, @StartDate) AND CURRENT_TIMESTAMP
	INNER JOIN #tmp T ON T.APNO = P.APNO 
	WHERE TableName = 'PersRef.SectStat' AND NewValue IN ('2','3','4','5','6','7','A','B') AND P.IsOnReport = 1 
  
	-- Get all the Crim records which were completed from the ChangeLog
	INSERT INTO  #tmpAllRec
	SELECT 'Crim' AS ComponentType, X.APNO, MAX(C.ChangeDate) OVER (PARTITION BY X.Apno) AS [DateClosed] 
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
	INSERT INTO #tmpFinalClosedDateForComponent (ComponentType, APNO, [DateClosed])
	SELECT DISTINCT C.ComponentType, CD.*
	FROM #tmpMaxCloseDate AS CD
	INNER JOIN #tmpAllRec AS C ON CD.DateClosed = C.DateClosed AND CD.APNO = C.APNO

	SELECT	T.CLNO, T.ClientName, RA.Affiliate, T.APNO, T.ApDate, F.DateClosed, T.OrigCompDate, T.CAM, [dbo].[ElapsedBusinessHours_2](F.DateClosed,T.OrigCompDate) AS [ElapsedHoursOnTBF],
			[dbo].[ElapsedBusinessDays_2](F.DateClosed,T.OrigCompDate) [TAT],
			CASE WHEN T.InProgressReviewed = 0 THEN 'False' ELSE 'True' END AS InProgressReviewed,
			CASE WHEN AACL.ClosedOn IS NULL THEN 'False' ELSE 'True' END AS AutoClosed 
	FROM #tmpFinalClosedDateForComponent AS F
	INNER JOIN #tmp AS T ON F.Apno = T.APNO
	LEFT OUTER JOIN dbo.ApplAutoCloseLog AS AACL(NOLOCK) ON T.APNO = AACL.Apno
	INNER JOIN dbo.Client AS C(NOLOCK) ON T.Clno = C.Clno
	INNER JOIN dbo.refAffiliate AS RA(NOLOCK) ON RA.AffiliateID = C.AffiliateID
	WHERE T.CLNO NOT IN (3468,2135)
	  AND CAST(T.OrigCompDate AS DATE) BETWEEN @StartDate AND @EndDate
	  --AND A.ApDate BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(D,1,@EndDate))
	  AND (@ClientList IS NULL OR T.CLNO in (SELECT VALUE FROM fn_Split(@ClientList,':')))
	  -- AND RA.AffiliateID = IIF(@AffiliateID = 0,RA.AffiliateID, @AffiliateID) -code added by Sunil Mandal for ticket id -53763
	  AND (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':'))) --code added by Sunil Mandal for ticket id -53763
	  AND (@CAM IS NULL OR T.CAM = @CAM)
	ORDER BY T.APNO

  DROP TABLE #tmp
  DROP TABLE #tmpAllRec
  DROP TABLE #tmpMaxCloseDate
  DROP TABLE #tmpFinalClosedDateForComponent



	/* VD-04/05/2018 - Commented
	SELECT	A.CLNO, C.Name AS [ClientName], RA.Affiliate, A.APNO, A.ApDate,A.OrigCompDate, A.UserID AS CAM, [dbo].[ElapsedBusinessHours_2](A.ApDate,A.OrigCompDate) [ElapsedHoursOnTBF],
			CASE WHEN A.InProgressReviewed = 0 THEN 'False' ELSE 'True' END AS InProgressReviewed,
			CASE WHEN AACL.ClosedOn IS NULL THEN 'False' ELSE 'True' END AS AutoClosed 
	FROM dbo.Appl AS A(NOLOCK)
	LEFT OUTER JOIN dbo.ApplAutoCloseLog AS AACL(NOLOCK) ON A.APNO = AACL.Apno
	INNER JOIN dbo.Client AS C(NOLOCK) ON A.Clno = C.Clno
	INNER JOIN dbo.refAffiliate AS RA(NOLOCK) ON RA.AffiliateID = C.AffiliateID
	WHERE A.ApStatus = 'F'
	  AND A.CLNO NOT IN (3468,2135)
	  AND CAST(A.OrigCompDate AS DATE) BETWEEN @StartDate AND @EndDate
	  --AND A.ApDate BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(D,1,@EndDate))
	  AND (@ClientList IS NULL OR A.CLNO in (SELECT VALUE FROM fn_Split(@ClientList,':')))
	  AND RA.AffiliateID = IIF(@AffiliateID = 0,RA.AffiliateID, @AffiliateID)
	  AND (@CAM IS NULL OR A.UserID = @CAM)
	  */


END

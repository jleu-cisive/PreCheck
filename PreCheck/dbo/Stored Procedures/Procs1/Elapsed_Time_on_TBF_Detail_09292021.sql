-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 05/11/2017
-- Description:	Elapsed Time on TBF Detail
-- Modified by:	DEEPAK VODETHELA	
-- Modified Date: 09/28/2017
-- Modified by: Radhika Dereddy on 07/13/2018
-- Modified Reason: Adding the License Section to the Qreport as requested by Brian Silver HDT#35917
-- Modified By: Deepak Vodethela
-- Modified date: 07/17/2018
-- Modified Reason: Added Crim's Last_Updated date when ChangeLog returns NULL.
-- Modified By: Deepak Vodethela
-- Modified date: 08/14/2019
-- Modified Reason: Use the final status date/time for edu, emp, lic and reference, but use the last updated date for crims. And also ignore any changes made by CAM.
-- Execution: EXEC Elapsed_Time_on_TBF_Detail '08/01/2019','08/12/2019', 0, '2331'
-- =============================================
CREATE PROCEDURE [dbo].[Elapsed_Time_on_TBF_Detail_09292021]
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
		[CAM] [varchar](8) NULL,
		[Pos_Sought] [varchar](100) NULL) --By HAhmed on 10/15/2018 - Added the column Position sought per HDT# 41417

	CREATE TABLE #tmpAllRec(
		[ComponentType] [varchar](20) NOT NULL,
		[APNO] [int] NOT NULL,
		[Value] [varchar](250) NOT NULL,
		[User Who CLosed] [varchar](100) NULL,
		[Last Updated Date] [datetime] NULL)

	CREATE TABLE #tmpFinalClosedDateForComponent(
		[ComponentType] [varchar](20) NOT NULL,
		[APNO] [int] NOT NULL,
		[Value] [varchar](250) NOT NULL,
		[User Who CLosed] [varchar](100) NULL,
		[Last Updated Date] [datetime] NULL)

		--Index on temp tables
	CREATE CLUSTERED INDEX IX_tmp_01 ON #tmp(APNO)
	CREATE CLUSTERED INDEX IX_tmp2_01 ON #tmpFinalClosedDateForComponent(APNO)

	-- Get all the "Finalized" reports
	INSERT INTO #tmp
	SELECT APNO, A.CLNO, C.Name AS ClientName, A.First AS [Applicant First Name], A.Last AS [Applicant Last Name], ApDate, CompDate, A.OrigCompDate, A.UserID AS CAM,
	A.Pos_Sought --By HAhmed on 10/15/2018 - Added the column Position sought per HDT# 41417
	FROM dbo.Appl(NOLOCK) AS A
	INNER JOIN dbo.Client AS C(NOLOCK) ON A.CLNO = C.CLNO
	WHERE ApStatus = 'F' 
	  AND A.CLNO NOT IN (2135,3468)
	  --AND A.ApDate BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(D,1,@EndDate)) -- commented by schapyala and modified to use OrigCompDate based on Brian Silver Request HDT 29664
	  AND cast(OrigCompDate as Date) BETWEEN @StartDate AND DATEADD(d,1,@EndDate)--between @startDate and @EndDate
	  --AND A.APNO IN (4705281 )
	--SELECT * FROM #tmp ORDER BY ApDate, APNO

	-- Get all the Employment records which were completed from the ChangeLog
	;WITH Employment AS
	(
		SELECT 'Employment' AS ComponentType, E.APNO, E.Employer AS [Value],
				(CASE WHEN CHARINDEX('-', C.UserID) = 0 THEN C.UserID ELSE LEFT(C.UserID, CHARINDEX('-', C.UserID) - 1) END) AS [User Who CLosed], 
				C.ChangeDate AS [Last Updated Date],
				ROW_NUMBER() OVER (PARTITION BY C.ID ORDER BY C.ChangeDate DESC) AS RowNumber
		FROM dbo.ChangeLog AS C(NOLOCK) 
		INNER JOIN dbo.Empl AS E(NOLOCK) ON C.ID = E.EmplID
		INNER JOIN #tmp T ON T.APNO = E.APNO 
		WHERE E.IsOnReport = 1 
		  AND C.NewValue IN ('2','3','4','5')
		  AND (CASE WHEN CHARINDEX('-', C.UserID) = 0 THEN C.UserID ELSE LEFT(C.UserID, CHARINDEX('-', C.UserID) - 1) END) NOT IN (SELECT U.UserID FROM USERS U WHERE U.CAM = 1)
		  AND C.ChangeDate BETWEEN DATEADD(MM,-4, @StartDate) AND CURRENT_TIMESTAMP
	)
	INSERT INTO #tmpAllRec
	SELECT ComponentType, APNO, [Value], [User Who CLosed] , [Last Updated Date]
	FROM Employment
	WHERE RowNumber = 1
  
	--SELECT * FROM #tmpAllRec --WHERE APNO =4131121

	-- Get all the Education records which were completed from the ChangeLog
	;WITH Education AS
	(
		SELECT 'Education' AS ComponentType, E.APNO, E.School AS [Value], 
				(CASE WHEN CHARINDEX('-', C.UserID) = 0 THEN C.UserID ELSE LEFT(C.UserID, CHARINDEX('-', C.UserID) - 1) END) AS [User Who CLosed], 
				C.ChangeDate AS [Last Updated Date],
				ROW_NUMBER() OVER (PARTITION BY C.ID ORDER BY C.ChangeDate DESC) AS RowNumber
		FROM ChangeLog AS C(NOLOCK) 
		INNER JOIN Educat AS E(NOLOCK) ON C.ID = E.Educatid --AND C.ChangeDate BETWEEN DATEADD(MM,-4, @StartDate) AND CURRENT_TIMESTAMP
		INNER JOIN #tmp T ON T.APNO = E.APNO 
		WHERE E.IsOnReport = 1 
		  AND C.NewValue IN ('2','3','4','5')
		  AND (CASE WHEN CHARINDEX('-', C.UserID) = 0 THEN C.UserID ELSE LEFT(C.UserID, CHARINDEX('-', C.UserID) - 1) END) NOT IN (SELECT U.UserID FROM USERS U WHERE U.CAM = 1)
		  AND C.ChangeDate BETWEEN DATEADD(MM,-4, @StartDate) AND CURRENT_TIMESTAMP
	)
	INSERT INTO #tmpAllRec
	SELECT ComponentType, APNO, [Value], [User Who CLosed] , [Last Updated Date]
	FROM Education
	WHERE RowNumber = 1
  
	-- Get all the Personal Reference records which were completed from the ChangeLog
	;WITH PersonalReference AS
	(
		SELECT 'Personal Reference' AS ComponentType, P.APNO, P.Name AS [Value], 
				(CASE WHEN CHARINDEX('-', C.UserID) = 0 THEN C.UserID ELSE LEFT(C.UserID, CHARINDEX('-', C.UserID) - 1) END) AS [User Who CLosed], 
				C.ChangeDate AS [Last Updated Date],
				ROW_NUMBER() OVER (PARTITION BY C.ID ORDER BY C.ChangeDate DESC) AS RowNumber 
		FROM dbo.ChangeLog AS C(NOLOCK)
		INNER JOIN dbo.PersRef AS P(NOLOCK) ON C.ID = P.PersRefID --AND C.ChangeDate BETWEEN DATEADD(MM,-4, @StartDate) AND CURRENT_TIMESTAMP
		INNER JOIN #tmp T ON T.APNO = P.APNO 
		WHERE P.IsOnReport = 1 
		  AND C.NewValue IN ('2','3','4','5')
		  AND (CASE WHEN CHARINDEX('-', C.UserID) = 0 THEN C.UserID ELSE LEFT(C.UserID, CHARINDEX('-', C.UserID) - 1) END) NOT IN (SELECT U.UserID FROM USERS U WHERE U.CAM = 1)
		  AND C.ChangeDate BETWEEN DATEADD(MM,-4, @StartDate) AND CURRENT_TIMESTAMP
	)
	INSERT INTO #tmpAllRec
	SELECT ComponentType, APNO, [Value], [User Who CLosed] , [Last Updated Date]
	FROM PersonalReference
	WHERE RowNumber = 1

	-- Get all the License records which were completed from the ChangeLog
	;WITH License AS
	(
		SELECT 'License' AS ComponentType, P.APNO, P.Lic_Type AS [Value], 
				(CASE WHEN CHARINDEX('-', C.UserID) = 0 THEN C.UserID ELSE LEFT(C.UserID, CHARINDEX('-', C.UserID) - 1) END) AS [User Who CLosed], 
				C.ChangeDate AS [Last Updated Date],
				ROW_NUMBER() OVER (PARTITION BY C.ID ORDER BY C.ChangeDate DESC) AS RowNumber 
		FROM dbo.ChangeLog AS C(NOLOCK) 
		INNER JOIN dbo.ProfLic AS P(NOLOCK)  ON C.ID = P.ProfLicID --AND C.ChangeDate BETWEEN DATEADD(MM,-4, @StartDate) AND CURRENT_TIMESTAMP
		INNER JOIN #tmp T ON T.APNO = P.APNO 
		WHERE P.IsOnReport = 1 
		  AND C.NewValue IN ('2','3','4','5')
		  AND (CASE WHEN CHARINDEX('-', C.UserID) = 0 THEN C.UserID ELSE LEFT(C.UserID, CHARINDEX('-', C.UserID) - 1) END) NOT IN (SELECT U.UserID FROM USERS U WHERE U.CAM = 1)
		  AND C.ChangeDate BETWEEN DATEADD(MM,-4, @StartDate) AND CURRENT_TIMESTAMP
	)
	INSERT INTO #tmpAllRec
	SELECT ComponentType, APNO, [Value], [User Who CLosed] , [Last Updated Date]
	FROM License
	WHERE RowNumber = 1
    
	-- Get all the Crim records which were completed from the ChangeLog
	--;WITH Criminal AS
	--(
	--	SELECT 'Criminal' AS ComponentType, X.APNO, X.CrimID, X.County AS [Value], C.UserID AS [User Who CLosed], X.Last_Updated AS [Last Updated Date],
	--			ROW_NUMBER() OVER (PARTITION BY C.ID ORDER BY C.ChangeDate DESC) AS RowNumber 
	--	FROM Crim AS X(NOLOCK)
	--	INNER JOIN ChangeLog AS C(NOLOCK) ON X.CrimID = C.ID --AND C.ChangeDate BETWEEN DATEADD(MM,-4, @StartDate) AND CURRENT_TIMESTAMP
	--	INNER JOIN #tmp T ON T.APNO = X.APNO 
	--	WHERE X.IsHidden = 0 
	--	  AND C.ChangeDate BETWEEN DATEADD(MM,-4, @StartDate) AND CURRENT_TIMESTAMP
	--)
	--INSERT INTO #tmpAllRec
	--SELECT ComponentType, APNO, [Value], [User Who CLosed] , [Last Updated Date]
	--FROM Criminal
	--WHERE RowNumber = 1
	
	;WITH Criminal AS
	(
		SELECT DISTINCT 'Criminal' AS ComponentType, X.APNO, X.CrimID, X.County AS [Value], 
				(CASE WHEN CHARINDEX('-', C.UserID) = 0 THEN C.UserID ELSE LEFT(C.UserID, CHARINDEX('-', C.UserID) - 1) END) AS [User Who CLosed], 
				(CASE WHEN X.CNTY_NO = 2480 THEN C.ChangeDate ELSE X.Last_Updated END) AS [Last Updated Date],
				ROW_NUMBER() OVER (PARTITION BY C.ID ORDER BY C.ChangeDate DESC) AS RowNumber 
		FROM Crim AS X(NOLOCK)
		INNER JOIN ChangeLog AS C(NOLOCK) ON X.CrimID = C.ID  --AND C.ChangeDate BETWEEN DATEADD(MM,-4, @StartDate) AND CURRENT_TIMESTAMP
		INNER JOIN #tmp T ON T.APNO = X.APNO 
		WHERE X.IsHidden = 0 
		  AND (CASE WHEN CHARINDEX('-', C.UserID) = 0 THEN C.UserID ELSE LEFT(C.UserID, CHARINDEX('-', C.UserID) - 1) END) NOT IN (SELECT U.UserID FROM USERS U WHERE U.CAM = 1)
	)
	INSERT INTO #tmpAllRec
	SELECT ComponentType, APNO, [Value], [User Who CLosed] , [Last Updated Date]
	FROM Criminal
	WHERE RowNumber = 1

	-- Get all the Crim records which were completed from Criminal Vendor Website
	;WITH CrimVendorWebsite AS
	(
		SELECT DISTINCT 'Criminal' AS ComponentType, L.APNO, L.County AS [Value], '' AS [User Who CLosed], L.EnteredDate AS [Last Updated Date],
				ROW_NUMBER() OVER (PARTITION BY L.APNO ORDER BY L.EnteredDate DESC) AS RowNumber 
		FROM [dbo].[CriminalVendor_Log] AS L
		INNER JOIN #tmp T ON T.APNO = L.APNO
	)
	INSERT INTO #tmpAllRec
	SELECT ComponentType, APNO, [Value], [User Who CLosed] , [Last Updated Date]
	FROM CrimVendorWebsite
	WHERE RowNumber = 1
  
	-- Get all the Crim records which were completed from Web Service Vendors
	--;WITH WebServiceVendors AS
	--(
	--	SELECT DISTINCT 'Criminal' AS ComponentType, C.APNO, C.County AS [Value], 'WebService' AS [User Who CLosed], irl.LogDate AS [Last Updated Date],
	--			ROW_NUMBER() OVER (PARTITION BY c.APNO ORDER BY irl.LogDate DESC) AS RowNumber 
	--	FROM dbo.IRIS_ResultLog AS irl(nolock)
	--	INNER JOIN Crim AS C ON irl.CrimID = C.CrimID AND C.deliverymethod = 'WEB SERVICE'
	--	INNER JOIN #tmp T ON T.APNO = C.APNO
	--)
	--INSERT INTO #tmpAllRec
	--SELECT ComponentType, APNO, [Value], [User Who CLosed] , [Last Updated Date]
	--FROM WebServiceVendors
	--WHERE RowNumber = 1
  
	--SELECT * FROM #tmpAllRec

	-- Get the Latest Updated date for each report#
	;WITH FinalClosedDateForComponent AS
	(
		SELECT  ComponentType, APNO, [Value],[User Who CLosed],	[Last Updated Date],
				ROW_NUMBER() OVER (PARTITION BY APNO ORDER BY [Last Updated Date] DESC) AS RowNumber 
		FROM #tmpAllRec 
	)
	INSERT INTO #tmpFinalClosedDateForComponent
	SELECT ComponentType, APNO, [Value],[User Who CLosed],	[Last Updated Date]
	FROM FinalClosedDateForComponent
	WHERE RowNumber = 1

	--SELECT * FROM #tmpFinalClosedDateForComponent ORDER BY Apno 

	-- Get everything into one place to display
	SELECT T.CLNO, T.ClientName, T.APNO, CONVERT(VARCHAR(20), T.ApDate, 120) AS ApDate, 
			CONVERT(VARCHAR(20), T.OrigCompDate, 120) AS OrigCompDate, 
			CONVERT(VARCHAR(20), T.CompDate, 120) AS CompDate, T.[Applicant First Name],T.[Applicant Last Name],
			T.Pos_Sought as [Position Sought], --By HAhmed on 10/15/2018 - Added the column Position sought per HDT# 41417
			 T.CAM, F.[User Who CLosed],
			--[dbo].[ElapsedBusinessDays_2](T.CompDate, F.[Last Updated Date]) [ElapsedDaysOnTBF],
			--[dbo].[ElapsedBusinessHours_2](T.CompDate,F.[Last Updated Date]) [ElapsedHoursOnTBF],
			[dbo].[ElapsedBusinessDays_2](F.[Last Updated Date],T.CompDate) [ElapsedDaysOnTBF],
			[dbo].[ElapsedBusinessHours_2](F.[Last Updated Date],T.CompDate) [ElapsedHoursOnTBF],
			CONVERT(VARCHAR(20), F.[Last Updated Date], 120) AS [Last Updated Time on Section], F.ComponentType AS [Last Section Completed], F.Value, 
			REPLACE(REPLACE(RA.Affiliate, CHAR(10),';'),CHAR(13),';') AS Affiliate, RA.AffiliateID,dbo.elapsedbusinessdays_2( T.Apdate, T.Origcompdate ) TAT
	FROM #tmpFinalClosedDateForComponent AS F
	INNER JOIN #tmp AS T ON F.Apno = T.APNO
	INNER JOIN dbo.CLient C WITH(NOLOCK) ON T.CLNO = C.CLNO
	INNER JOIN dbo.refAffiliate AS RA WITH (NOLOCK) ON C.AffiliateID = RA.AffiliateID
	WHERE (@ClientList IS NULL OR T.CLNO in (SELECT value FROM fn_Split(@ClientList,':')))
	 AND RA.AffiliateID = IIF(@AffiliateID = 0,RA.AffiliateID, @AffiliateID)
	ORDER BY T.ApDate ASC, [Last Updated Date] DESC

  DROP TABLE #tmp
  DROP TABLE #tmpAllRec
  DROP TABLE #tmpFinalClosedDateForComponent

End
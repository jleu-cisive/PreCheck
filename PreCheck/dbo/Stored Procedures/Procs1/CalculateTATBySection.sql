-- Alter Procedure CalculateTATBySection
-- =============================================
-- Author:		DEEPAK VODETHELA
-- Create date: 03/26/2018
-- Description:	The Service to calculate Actual Turnaround Time for Client / Employment / Education / Public Records
-- Execution: EXEC [CalculateTATBySection]
-- =============================================
CREATE PROCEDURE [dbo].[CalculateTATBySection] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @StartDate datetime, @EndDate datetime 
	SELECT @StartDate = CAST([MainDB].[dbo].[fnGetEstimatedBusinessDate_2](CURRENT_TIMESTAMP,-10) AS DATE), @EndDate = CAST(CURRENT_TIMESTAMP AS DATE)
	--SELECT @StartDate AS StartDate, @EndDate AS EndDate

	-- Specific to MVR to Calculate 30 business days
	DECLARE @MVRStartDate datetime, @MVREndDate datetime 
	SELECT @MVRStartDate = CAST([MainDB].[dbo].[fnGetEstimatedBusinessDate_2](CURRENT_TIMESTAMP,-30) AS DATE), @MVREndDate = CAST(CURRENT_TIMESTAMP AS DATE)
	--SELECT @MVRStartDate AS MVRStartDate, @MVREndDate AS MVREndDate

	-- CLIENT TAT
	DECLARE @tmpReportsForCLNO TABLE 
	(
		CLNO INT,
		[TurnAroundTime] INT,
		NoOfReportsByClno INT
	)

	INSERT INTO @tmpReportsForCLNO
	SELECT DISTINCT CLNO, dbo.ElapsedBusinessDays_2(CAST(ApDate AS DATE), CAST(OrigCompDate AS DATE)) AS [TurnAroundTime],
			COUNT(APNO) OVER (PARTITION BY CLNO) AS 'NoOfReportsByClno'
	FROM Appl (NOLOCK)
	WHERE ApDate BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(D,1,@EndDate)) 
	  AND ApStatus IN ('W','F')
	--AND CLNO IN (SELECT CLNO FROM dbo.ClientConfiguration(NOLOCK) WHERE ConfigurationKey = 'Client_Avg_TAT_Display_In_Client_Access' AND [Value] = 'True')
	GROUP BY CLNO, CAST(ApDate AS DATE), CAST(OrigCompDate AS DATE), APNO
	
	--SELECT * FROM @tmpReportsForCLNO ORDER BY CLNO, [TurnAroundTime]

	/*
	SELECT	CLNO, 
			CAST(((SUM([TurnAroundTime])*1.0)/(NoOfReportsByClno)) AS NUMERIC(5,2)) AS 'ActualTAT_ASIS', 
			CEILING(CAST(((SUM([TurnAroundTime])*1.0)/(NoOfReportsByClno)) AS NUMERIC(5,2))) AS 'ActualTAT_TOBE'
	FROM @tmpReportsForCLNO 
	GROUP BY CLNO, NoOfReportsByClno
	ORDER BY CLNO
	*/
/****************************************************************************************************************************************************************************************************/

	-- EMPLOYMENT

	DECLARE @tmpEmplReportsByTAT TABLE 
	(
		[TurnAroundTime] INT,
		NoOfReportsByTAT INT
	)

	INSERT INTO @tmpEmplReportsByTAT ([TurnAroundTime], NoOfReportsByTAT)
	SELECT	DISTINCT dbo.elapsedbusinessdays_2(CAST(E.CreatedDate AS DATE), CAST(E.Last_Updated AS DATE)) AS TurnAroundTime,
			COUNT(APNO) OVER (PARTITION BY dbo.elapsedbusinessdays_2(CAST(E.CreatedDate AS DATE), CAST(E.Last_Updated AS DATE))) AS 'NoOfReportsByTAT'
	FROM Empl AS E(NOLOCK)
	WHERE E.IsHidden = 0
	  AND E.IsOnReport = 1
	  AND E.SectStat in ('2','3','4','5')
	  AND E.CreatedDate BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(D,1,@EndDate)) 

	--EXEC [dbo].[TurnaroundTimeForEmployment] '2017-10-17 00:00:00.000','2017-10-31 00:00:00.000'
	--SELECT * FROM @tmpEmplReportsByTAT ORDER BY [TurnAroundTime]
	/*
	SELECT  'Employment' AS SectionType,
			CAST(SUM(([TurnAroundTime] + 1) * (NoOfReportsByTAT)) AS NUMERIC(16,2)) AS [Product],  
			CAST(SUM(NoOfReportsByTAT) AS NUMERIC(16,2)) AS CountOfNoOfReportsByTAT,
			(CAST(SUM(([TurnAroundTime] + 1) * (NoOfReportsByTAT)) AS NUMERIC(16,2)) / CAST(SUM(NoOfReportsByTAT) AS NUMERIC(16,2))) - 1 AS [ETA_AsIs],
			(CEILING(CAST(SUM(([TurnAroundTime] + 1) * (NoOfReportsByTAT)) AS NUMERIC(16,2)) / CAST(SUM(NoOfReportsByTAT) AS NUMERIC(16,2))) - 1) AS [ETA_ToBe]
	FROM @tmpEmplReportsByTAT
	*/
/****************************************************************************************************************************************************************************************************/
	-- EDUCATION

	DECLARE @tmpEducatReportsByTAT TABLE 
	(
		[TurnAroundTime] INT,
		NoOfReportsByTAT INT
	)

	INSERT INTO @tmpEducatReportsByTAT ([TurnAroundTime], NoOfReportsByTAT)
	SELECT	DISTINCT dbo.elapsedbusinessdays_2(CAST(E.CreatedDate AS DATE), CAST(E.Last_Updated AS DATE)) AS TurnAroundTime,
			COUNT(APNO) OVER (PARTITION BY dbo.elapsedbusinessdays_2(CAST(E.CreatedDate AS DATE), CAST(E.Last_Updated AS DATE))) AS 'NoOfReportsByTAT'
	FROM Educat AS E(NOLOCK)
	WHERE E.IsHidden = 0
	  AND E.IsOnReport = 1
	  AND E.SectStat in ('2','3','4','5')
	  AND E.CreatedDate >= @StartDate
	  AND E.Last_Updated < DATEADD(S,-1,DATEADD(D,1,@EndDate))

	--EXEC [dbo].[TurnaroundTimeForEducation] '2017-10-17 00:00:00.000','2017-10-31 00:00:00.000'
	--SELECT * FROM @tmpEducatReportsByTAT ORDER BY [TurnAroundTime]
	/*
	SELECT  'Education' AS SectionType,
			CAST(SUM(([TurnAroundTime] + 1) * (NoOfReportsByTAT)) AS NUMERIC(16,2)) AS [Product],  
			CAST(SUM(NoOfReportsByTAT) AS NUMERIC(16,2)) AS CountOfNoOfReportsByTAT,
			(CAST(SUM(([TurnAroundTime] + 1) * (NoOfReportsByTAT)) AS NUMERIC(16,2)) / CAST(SUM(NoOfReportsByTAT) AS NUMERIC(16,2))) - 1 AS [ETA_AsIs],
			(CEILING(CAST(SUM(([TurnAroundTime] + 1) * (NoOfReportsByTAT)) AS NUMERIC(16,2)) / CAST(SUM(NoOfReportsByTAT) AS NUMERIC(16,2))) - 1) AS [ETA_ToBe]
	FROM @tmpEducatReportsByTAT
	*/
/****************************************************************************************************************************************************************************************************/
	-- PROFESSIONAL LICENSE 
	
	DECLARE @tmpProfLicReportsByTAT TABLE 
	(
		[TurnAroundTime] INT,
		NoOfReportsByTAT INT
	)

	INSERT INTO @tmpProfLicReportsByTAT ([TurnAroundTime], NoOfReportsByTAT)
	SELECT	DISTINCT dbo.elapsedbusinessdays_2(CAST(E.CreatedDate AS DATE), CAST(E.Last_Updated AS DATE)) AS TurnAroundTime,
			COUNT(APNO) OVER (PARTITION BY dbo.elapsedbusinessdays_2(CAST(E.CreatedDate AS DATE), CAST(E.Last_Updated AS DATE))) AS 'NoOfReportsByTAT'
	FROM ProfLic AS E(NOLOCK)
	WHERE E.SectStat NOT IN ('9')
	  AND E.CreatedDate >= @StartDate 
	  AND E.Last_updated < @EndDate 	
	
	/* VD: 04/18/2018 - Commented the below logic to match the existing "TurnaroundTimeForLicenses" QReport
	--WHERE E.IsHidden = 0
	--  AND E.IsOnReport = 1
	--  AND E.SectStat in ('2','3','4','5')
	--  AND E.CreatedDate BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(D,1,@EndDate)) 
	*/
	--EXEC [dbo].[TurnaroundTimeForEmployment] '2017-10-17 00:00:00.000','2017-10-31 00:00:00.000'
	--SELECT * FROM @tmpProfLicReportsByTAT ORDER BY [TurnAroundTime]
	/*
	SELECT  'ProfLicense' AS SectionType,
			CAST(SUM(([TurnAroundTime] + 1) * (NoOfReportsByTAT)) AS NUMERIC(16,2)) AS [Product],  
			CAST(SUM(NoOfReportsByTAT) AS NUMERIC(16,2)) AS CountOfNoOfReportsByTAT,
			(CAST(SUM(([TurnAroundTime] + 1) * (NoOfReportsByTAT)) AS NUMERIC(16,2)) / CAST(SUM(NoOfReportsByTAT) AS NUMERIC(16,2))) - 1 AS [ETA_AsIs],
			(CEILING(CAST(SUM(([TurnAroundTime] + 1) * (NoOfReportsByTAT)) AS NUMERIC(16,2)) / CAST(SUM(NoOfReportsByTAT) AS NUMERIC(16,2))) - 1) AS [ETA_ToBe]
	FROM @tmpProfLicReportsByTAT
	*/

/****************************************************************************************************************************************************************************************************/
-- MVR

	DECLARE @tmpMVRReportsByTAT TABLE 
	(
		[TurnAroundTime] INT,
		[DLState] VARCHAR(2),
		NoOfReportsByTAT INT
	)

	INSERT INTO @tmpMVRReportsByTAT ([TurnAroundTime], DLState, NoOfReportsByTAT)
	SELECT	DISTINCT dbo.elapsedbusinessdays_2(CAST(M.CreatedDate AS DATE), CAST(M.Last_Updated AS DATE)) AS TurnAroundTime,
			[DL_State] AS [DLState],
			COUNT(M.APNO) OVER (PARTITION BY dbo.elapsedbusinessdays(CAST(M.CreatedDate AS DATE), CAST(M.Last_Updated AS DATE)),[DL_State]) AS 'NoOfReportsByTAT'
	FROM DL AS M(NOLOCK)
	INNER JOIN dbo.Appl AS A(nolock) ON M.APNO = A.APNO
	WHERE M.IsHidden = 0
	  AND M.SectStat in ('2','3','4','5')
	  AND M.CreatedDate BETWEEN @MVRStartDate AND DATEADD(S,-1,DATEADD(D,1,@MVREndDate)) 

	--EXEC [dbo].[TurnaroundTimeForEmployment] '2017-10-17 00:00:00.000','2017-10-31 00:00:00.000'
	--SELECT * FROM @tmpMVRReportsByTAT ORDER BY [TurnAroundTime]
	/*
	SELECT  'MVR' AS SectionType,
			CAST(SUM(([TurnAroundTime] + 1) * (NoOfReportsByTAT)) AS NUMERIC(16,2)) AS [Product],  
			CAST(SUM(NoOfReportsByTAT) AS NUMERIC(16,2)) AS CountOfNoOfReportsByTAT,
			(CAST(SUM(([TurnAroundTime] + 1) * (NoOfReportsByTAT)) AS NUMERIC(16,2)) / CAST(SUM(NoOfReportsByTAT) AS NUMERIC(16,2))) - 1 AS [ETA_AsIs],
			(CEILING(CAST(SUM(([TurnAroundTime] + 1) * (NoOfReportsByTAT)) AS NUMERIC(16,2)) / CAST(SUM(NoOfReportsByTAT) AS NUMERIC(16,2))) - 1) AS [ETA_ToBe]
	FROM @tmpMVRReportsByTAT
	*/

/****************************************************************************************************************************************************************************************************/

	-- PUBLIC RECORDS

	DECLARE @tmpPublicRecordsReportsByTAT TABLE 
	(
		[CNTY_NO] INT,
		[County] VARCHAR(40),
		[State] VARCHAR(25),
		[AverageDayETA_AsIs] DECIMAL(10,2),
		[AverageDayETA_ToBe] INT
	)

	--EXEC [dbo].[CountyAverageHoursDaysByDateRangeStateCounty] '2017-10-17 00:00:00.000', '2017-10-31 00:00:00.000', '', 'KY'

	INSERT INTO @tmpPublicRecordsReportsByTAT ([CNTY_NO], [County], [State], [AverageDayETA_AsIs], [AverageDayETA_ToBe])
	SELECT	DISTINCT cc.CNTY_NO,
			cc.county AS County, 
			cc.[State] AS [State],
			ISNULL(CONVERT(DECIMAL(10,2),p.Average/24), 0) AS [AverageDayETA_AsIs],
			CEILING(ISNULL(CONVERT(DECIMAL(10,2),p.Average/24), 0)) AS [AverageDayETA_ToBe]
	FROM dbo.TblCounties cc with (nolock) 
	LEFT JOIN (SELECT	ROUND((AVG(CONVERT(NUMERIC(7,2), 
						(dbo.GetBusinessDays(ISNULL(C.IrisOrdered,CONVERT(DATETIME, C.Ordered)),c.Last_Updated) + ((CASE WHEN DATEDIFF(hh,ISNULL(C.IrisOrdered,CONVERT(DATETIME, C.Ordered)),c.Last_Updated) < 24 THEN DATEDIFF(hh,ISNULL(IrisOrdered,CONVERT(DATETIME, C.Ordered)),c.Last_Updated) ELSE 0 END)/24.0)))) * 24),0) AS Average,
						c.cnty_no
				FROM dbo.TblCounties AS cc WITH (NOLOCK) 
				LEFT OUTER JOIN Crim AS c WITH (NOLOCK) on cc.cnty_no = c.cnty_no
				WHERE ISNULL(C.IrisOrdered,CONVERT(DATETIME, CASE WHEN ISDATE(C.Ordered) = 1 THEN C.Ordered ELSE NULL END)) BETWEEN CONVERT(DATE, CONVERT(VARCHAR(20), @StartDate, 103) , 103) AND DATEADD(S,-1,DATEADD(D,1,@EndDate))  -- CONVERT(DATE, CONVERT(VARCHAR(20), DATEADD(S,-1,DATEADD(D,1,@EndDate)), 103),103)
				  AND ISDATE(C.Ordered) = 1
				GROUP BY c.cnty_no) p ON p.cnty_no = cc.cnty_no
	LEFT JOIN [dbo].[Iris_Researcher_Charges] AS ic on ic.cnty_no = cc.cnty_no
	LEFT JOIN [dbo].[Iris_Researchers] AS r on ic.researcher_id = r.R_id
	WHERE ic.researcher_default = 'Yes' 
	  AND ISNULL(cc.County, '') <> ''

	--SELECT * FROM @tmpPublicRecordsReportsByTAT --WHERE [STATE] = 'KY'

/****************************************************************************************************************************************************************************************************/
	-- Begin - Service
	-- Begin - Service
	BEGIN TRY  
			-- Begin Transaction
			BEGIN TRAN
			-- Truncate Table
			TRUNCATE TABLE [ApplSectionsTAT]

			-- Insert Data into the Main Table
			INSERT INTO [dbo].ApplSectionsTAT
					([ApplSectionID]
					,[KeyID]
					,[TAT]
					,[DLState])
			SELECT SectionType, KeyID, [TAT], [DLState]
			FROM (
				SELECT	11 AS SectionType,
						CLNO AS KeyID,
						CAST(((SUM([TurnAroundTime])*1.0)/(NoOfReportsByClno)) AS NUMERIC(5,2)) AS [TAT],
						NULL AS [DLState]
				FROM @tmpReportsForCLNO 
				GROUP BY CLNO, NoOfReportsByClno
				UNION ALL
				SELECT  1 AS SectionType,
						0 AS KeyID,
						(CEILING(CAST(SUM(([TurnAroundTime] + 1) * (NoOfReportsByTAT)) AS NUMERIC(16,2)) / CAST(SUM(NoOfReportsByTAT) AS NUMERIC(16,2))) - 1) AS [TAT],
						NULL AS [DLState]
				FROM @tmpEmplReportsByTAT
				UNION ALL
				SELECT  2,
						0 AS KeyID,
						(CEILING(CAST(SUM(([TurnAroundTime] + 1) * (NoOfReportsByTAT)) AS NUMERIC(16,2)) / CAST(SUM(NoOfReportsByTAT) AS NUMERIC(16,2))) - 1) AS [TAT],
						NULL AS [DLState]
				FROM @tmpEducatReportsByTAT
				UNION ALL
				SELECT  4,
						0 AS KeyID,
						(CEILING(CAST(SUM(([TurnAroundTime] + 1) * (NoOfReportsByTAT)) AS NUMERIC(16,2)) / CAST(SUM(NoOfReportsByTAT) AS NUMERIC(16,2))) - 1) AS [TAT],
						NULL AS [DLState]
				FROM @tmpProfLicReportsByTAT
				UNION ALL
				SELECT	5 AS SectionType,
						[CNTY_NO] AS KeyID,
						[AverageDayETA_ToBe] AS [TAT],
						NULL AS [DLState]
				FROM @tmpPublicRecordsReportsByTAT
				UNION ALL
				SELECT  6,
						0 AS KeyID,
						(CEILING(CAST(SUM(([TurnAroundTime] + 1) * (NoOfReportsByTAT)) AS NUMERIC(16,2)) / CAST(SUM(NoOfReportsByTAT) AS NUMERIC(16,2))) - 1) AS [TAT],
						[DLState]
				FROM @tmpMVRReportsByTAT
				GROUP BY [DLState]
				) AS Y

		-- Save Transaction
		COMMIT TRAN

			 INSERT INTO [dbo].[ApplSectionsTATHistory]
				   ([ApplSectionID]
				   ,[KeyID]
				   ,[TAT]
				   ,[DLState]
				   ,[CreatedDate]
				   ,[CreatedBy]
				   ,[UpdateDate]
				   ,[UpdatedBy])
			SELECT [ApplSectionID]
					,[KeyID]
					,[TAT]
					,[DLState]
					,[CreatedDate]
					,[CreatedBy]
					,[UpdateDate]
					,[UpdatedBy]
				FROM [dbo].[ApplSectionsTAT]


		END TRY
	BEGIN CATCH  
		SELECT  
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  

		-- Rollback Transaction
		ROLLBACK TRAN;

	END CATCH

	/*
	SELECT * FROM [dbo].[ApplSectionsTAT]
	SELECT * FROM [dbo].[ApplSectionsTATHistory] ORDER BY CreatedDate DESC
	*/

	/*
	TRUNCATE TABLE [dbo].[ApplSectionsTAT]
	TRUNCATE TABLE [dbo].[ApplSectionsTATHistory]
	*/
END

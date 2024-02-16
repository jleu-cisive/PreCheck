-- =============================================
-- Author:		Simenc, Jeff
-- Create date: 06/22/2021
-- Description:	This stored procedure will delete records older than the retention period for each table listed below.  This will be done on a weekly? basis.
--		
--				Table Name											Retention Period
--				PrecheckServiceLog									1 Year
--				DataXtract_Logging									1 Year
--				OCHS_ResultsLog										1 Month
--				ChangeLog											3 Years
--				iris_ws_log_data									1 Month
--				Integration_CallbackLogging							3 Months
--				PositiveIDResponseLog								1 Month
--				Log													1 Year for Exceptions/3 Months for all other

--
-- Modified Date :			12/6/2022
-- Modified By :			J. Simenc
-- Change Descriptiion :	Retention period for DataXtractLogging changed from 3 months to 1 year
--
-- =============================================
CREATE PROCEDURE [dbo].[usp_PreCheck_LogTable_Purge]
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Declare the variable for the cuttoffdate and counter variable
    DECLARE @cuttoffdate AS DATETIME;
    DECLARE @rcount AS INT;

	-- Temp table to store record id's to delete
    CREATE TABLE #PurgeRecordIds
    (
        [PurgeID] bigint NOT NULL
    );
    CREATE CLUSTERED INDEX IX_TEMPPID ON #PurgeRecordIds (PurgeID ASC);


    -- Purge the PrecheckServiceLog table.  
    -- Delete all records older than 1 year based on the ServiceDate field
    SET @cuttoffdate = DATEADD(yyyy, -1, GETDATE());
	set @rcount = 1;

    WHILE @rcount > 0
    BEGIN

        -- Get top 500 PrecheckServiceLogId's from the PrecheckServiceLog table.
        INSERT INTO #PurgeRecordIds
        SELECT TOP (500)
               cc.PrecheckServiceLogId
        FROM dbo.PrecheckServiceLog cc WITH (NOLOCK)
        WHERE cc.ServiceDate < @cuttoffdate;

        --delete PrecheckServiceLog
		DELETE cc
        FROM dbo.PrecheckServiceLog cc
        JOIN #PurgeRecordIds p
                    ON p.PurgeID = cc.PrecheckServiceLogId;

        SET @rcount = @@ROWCOUNT;

        TRUNCATE TABLE #PurgeRecordIDs;

    END;

    TRUNCATE TABLE #PurgeRecordIds;



    -- Purge the DataXtract_Logging table.  
    -- Delete all records older than 3 Months based on the DateLogRequest field
    SET @cuttoffdate = DATEADD(yyyy, -1, GETDATE());
	SET @rcount = 1;

    WHILE @rcount > 0
    BEGIN

        -- Get top 1,000 DataXtract_LoggingId's from the DataXtract_Logging table.
        INSERT INTO #PurgeRecordIds
        SELECT TOP (1000)
               cc.DataXtract_LoggingId
        FROM dbo.DataXtract_Logging cc WITH (NOLOCK)
        WHERE cc.DateLogRequest < @cuttoffdate;

        --delete DataXtract_Logging
        DELETE cc
        FROM dbo.DataXtract_Logging cc
                JOIN #PurgeRecordIds p
                    ON p.PurgeID = cc.DataXtract_LoggingId;

        SET @rcount = @@ROWCOUNT;


        TRUNCATE TABLE #PurgeRecordIDs;

    END;

    TRUNCATE TABLE #PurgeRecordIds;




    -- Purge the OCHS_ResultsLog table.  
    -- Delete all records older than 1 months based on the LastUpdated field
    SET @cuttoffdate = DATEADD(mm, -1, GETDATE());
    SET @rcount = 1

    WHILE @rcount > 0
    BEGIN
		
		-- Get top 100 ID's from the OCHS_ResultsLog table.
        INSERT INTO #PurgeRecordIds
        SELECT TOP (100)
               cc.ID
        FROM dbo.OCHS_ResultsLog cc WITH (NOLOCK)
        WHERE cc.LastUpdated < @cuttoffdate;

        --delete OCHS_ResultsLog
        DELETE cc
        FROM dbo.OCHS_ResultsLog cc
            JOIN #PurgeRecordIds p
                ON p.PurgeID = cc.ID;

        SET @rcount = @@ROWCOUNT;


        TRUNCATE TABLE #PurgeRecordIds;

    END;

    TRUNCATE TABLE #PurgeRecordIds;



  
	--	Purge the ChangeLog table.  
	-- Delete all records older than 3 Years based on the ChangeDate field
	SET @cuttoffdate = DATEADD(yyyy,-3,GETDATE());
	SET @rcount = 1
	
	WHILE @rcount > 0
	BEGIN

		-- Get top 1000 HEVNMgmtChangeLogID's from the ChangeLog table.
		INSERT INTO #PurgeRecordIds
		SELECT TOP (1000) cc.HEVNMgmtChangeLogID FROM dbo.ChangeLog cc WITH(NOLOCK) 
		WHERE  cc.ChangeDate < @cuttoffdate

		
		DELETE cc
		FROM dbo.ChangeLog cc JOIN #PurgeRecordIds p ON p.PurgeID = cc.HEVNMgmtChangeLogID

		SET @rcount = @@ROWCOUNT
		
		TRUNCATE TABLE #PurgeRecordIDs

	END

	TRUNCATE TABLE #PurgeRecordIds;



    -- Purge the Integration_CallbackLogging table.  
    -- Delete all records older than 3 Months based on the CallbackDate field
    --SET @cuttoffdate = DATEADD(mm,-3,GETDATE());


    --WHILE EXISTS (SELECT (1) FROM dbo.Integration_CallbackLogging cc WITH(NOLOCK) WHERE cc.CallbackDate < @cuttoffdate)
    --BEGIN

    --	-- Get top 10,000 CallbackLogId's from the Integration_CallbackLogging table.
    --	INSERT INTO #PurgeRecordIds
    --	SELECT TOP (10000) cc.CallbackLogId FROM dbo.Integration_CallbackLogging cc WITH(NOLOCK) WHERE  cc.CallbackDate < @cuttoffdate

    --	--delete Integration_CallbackLogging
    --	SET @rcount = 1
    --	WHILE @rcount > 0
    --	BEGIN

    --		DELETE TOP(1000) dbo.Integration_CallbackLogging
    --		FROM dbo.Integration_CallbackLogging cc JOIN #PurgeRecordIds p ON p.PurgeID = cc.CallbackLogId

    --		SET @rcount = @@ROWCOUNT

    --	END	

    --	TRUNCATE TABLE #PurgeReocordIDs

    --END



    -- Purge the PositiveIDResponseLog table.  
    -- Delete all records older than 1 months based on the SearchDate field
    --SET @cuttoffdate = DATEADD(mm,-1,GETDATE());


    --WHILE EXISTS (SELECT (1) FROM dbo.PositiveIDResponseLog cc WITH(NOLOCK) WHERE cc.SearchDate < @cuttoffdate)
    --BEGIN

    --	-- Get top 10,000 ResponseID's from the PositiveIDResponseLog table.
    --	INSERT INTO #PurgeRecordIds
    --	SELECT TOP (10000) cc.ResponseID FROM dbo.PositiveIDResponseLog cc WITH(NOLOCK) WHERE  cc.SearchDate < @cuttoffdate

    --	--delete PositiveIDResponseLog
    --	SET @rcount = 1
    --	WHILE @rcount > 0
    --	BEGIN

    --		DELETE TOP(1000) dbo.PositiveIDResponseLog
    --		FROM dbo.PositiveIDResponseLog cc JOIN #PurgeRecordIds p ON p.PurgeID = cc.ResponseID

    --		SET @rcount = @@ROWCOUNT

    --	END	

    --	TRUNCATE TABLE #PurgeReocordIDs

    --END



    -- Purge the log table for non-exceptions.  
    -- Delete all records older than 3 months based on the Datea field for non-exceptions
    --SET @cuttoffdate = DATEADD(mm,-3,GETDATE());


    --WHILE EXISTS (SELECT (1) FROM dbo.log cc WITH(NOLOCK) WHERE cc.Date < @cuttoffdate and cc.Exception = '')
    --BEGIN

    --	-- Get top 10,000 ID's from the log table.
    --	INSERT INTO #PurgeRecordIds
    --	SELECT TOP (10000) cc.id FROM dbo.Log cc WITH(NOLOCK) WHERE  cc.Date < @cuttoffdate and cc.Exception = ''

    --	--delete log
    --	SET @rcount = 1
    --	WHILE @rcount > 0
    --	BEGIN

    --		DELETE TOP(1000) dbo.Log
    --		FROM dbo.Log cc JOIN #PurgeRecordIds p ON p.PurgeID = cc.Id

    --		SET @rcount = @@ROWCOUNT

    --	END	

    --	TRUNCATE TABLE #PurgeReocordIDs

    --END



    -- Purge the log table for exceptions.  
    -- Delete all records older than 1 year based on the Date field for exceptions
    --SET @cuttoffdate = DATEADD(yyyy,-1,GETDATE());


    --WHILE EXISTS (SELECT (1) FROM dbo.log cc WITH(NOLOCK) WHERE cc.Date < @cuttoffdate and cc.Exception <> '')
    --BEGIN

    --	-- Get top 10,000 ID's from the log table.
    --	INSERT INTO #PurgeRecordIds
    --	SELECT TOP (10000) cc.id FROM dbo.Log cc WITH(NOLOCK) WHERE  cc.Date < @cuttoffdate and cc.Exception <> ''

    --	--delete log
    --	SET @rcount = 1
    --	WHILE @rcount > 0
    --	BEGIN

    --		DELETE TOP(1000) dbo.Log
    --		FROM dbo.Log cc JOIN #PurgeRecordIds p ON p.PurgeID = cc.Id

    --		SET @rcount = @@ROWCOUNT

    --	END	

    --	TRUNCATE TABLE #PurgeReocordIDs

    --END




END;
-- =============================================
-- Author:		Simenc, Jeff
-- Create date: 06/22/2021
-- Description:	This stored procedure will delete records older than the retention period for each table listed below.  This will be done on a weekly? basis.
--		
--				Table Name											Retention Period
--				Integration_Verification_Transaction				8 Year
--				Integration_OrderMgmt_Request						8 Year
--				OCHS_PDFReports										8 Year
-- =============================================
CREATE PROCEDURE [dbo].[usp_PreCheck_TransactionTable_Purge] 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON	

	-- Declare the variable for the cuttoffdate and counter variable
	DECLARE @cuttoffdate AS DATETIME;
	DECLARE @rcount AS INT; 


	-- Temp table to store record id's to delete
	CREATE TABLE #PurgeRecordIds (
			[PurgeID] int NOT NULL
	);
	CREATE NONCLUSTERED INDEX IX_PID ON #PurgeRecordIds
	(
			PurgeID ASC
	);




	-- Purge the Integration_Verification_Transaction table.  
	-- Delete all records older than 8 year based on the CreatedDate field
	SET @cuttoffdate = DATEADD(yyyy,-8,GETDATE());
	set @rcount = 1

	WHILE @rcount > 0 
	BEGIN

		-- Get top 10 VerficationTransactionId's from the Integration_Verification_Transaction table.
		INSERT INTO #PurgeRecordIds
		SELECT TOP (10) cc.VerficationTransactionId FROM dbo.Integration_Verification_Transaction cc WITH(NOLOCK) WHERE  cc.CreatedDate < @cuttoffdate

		--delete Integration_Verification_Transaction
		DELETE cc
		FROM dbo.Integration_Verification_Transaction cc JOIN #PurgeRecordIds p ON p.PurgeID = cc.VerficationTransactionId

		SET @rcount = @@ROWCOUNT
		
		TRUNCATE TABLE #PurgeRecordIds

	END

	TRUNCATE TABLE #PurgeRecordIds


	
	-- Purge the Integration_OrderMgmt_Request table.  
	-- Delete all records older than 8 year based on the RequestDate field
	SET @cuttoffdate = DATEADD(yyyy,-8,GETDATE());
	set @rcount = 1

	WHILE @rcount > 0 
	BEGIN

		-- Get top 100 RequestId's from the Integration_OrderMgmt_Request table.
		INSERT INTO #PurgeRecordIds
		SELECT TOP (100) cc.RequestID FROM dbo.Integration_OrderMgmt_Request cc WITH(NOLOCK) WHERE  cc.RequestDate < @cuttoffdate

		--delete Integration_Verification_Transaction
		DELETE cc
		FROM dbo.Integration_OrderMgmt_Request cc JOIN #PurgeRecordIds p ON p.PurgeID = cc.RequestID

		SET @rcount = @@ROWCOUNT
		
		TRUNCATE TABLE #PurgeRecordIds

	END

	TRUNCATE TABLE #PurgeRecordIds




	-- Purge the OCHS_PDFReports table.  
	-- Delete all records older than 8 year based on the AddedOn field
	SET @cuttoffdate = DATEADD(yyyy,-8,GETDATE());
	set @rcount = 1

	WHILE @rcount > 0 
	BEGIN

		-- Get top 100 ID's from the Integration_OrderMgmt_Request table.
		INSERT INTO #PurgeRecordIds
		SELECT TOP (100) cc.ID FROM dbo.OCHS_PDFReports cc WITH(NOLOCK) WHERE  cc.AddedOn < @cuttoffdate

		--delete Integration_Verification_Transaction
		DELETE cc
		FROM dbo.OCHS_PDFReports cc JOIN #PurgeRecordIds p ON p.PurgeID = cc.ID

		SET @rcount = @@ROWCOUNT
		
		TRUNCATE TABLE #PurgeRecordIds

	END

	TRUNCATE TABLE #PurgeRecordIds





	DROP TABLE #PurgeRecordIDs

END
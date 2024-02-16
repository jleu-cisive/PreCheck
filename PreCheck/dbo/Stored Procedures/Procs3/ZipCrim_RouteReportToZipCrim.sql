
CREATE PROCEDURE [dbo].[ZipCrim_RouteReportToZipCrim]
	@apno int, @isAutomated bit
AS
	DECLARE @noDiversionNote varchar(max) = 'ZipCrim Processed – no reason for diversion at that time';
	DECLARE @PidDiversionNote varchar(max) = 'ZipCrim Processed - Please review the Positive ID and apply the appropriate status';
	DECLARE @PidDiversionIsActive bit = 0;
	
	SELECT @PidDiversionIsActive = iif(cc.Value = 'TRUE', 1, 0) FROM dbo.ClientConfiguration cc 
	WHERE cc.CLNO= 0 AND cc.ConfigurationKey = 'ZIPCRIM_ALWAYS_ROUTE_TO_AI'
	
	IF (@PidDiversionIsActive = 1)
	BEGIN
		SET @isAutomated = 0;
		EXEC [dbo].[Win_Service_ApplAddPrivateNotes] @apno, @PidDiversionNote
	END

	IF NOT EXISTS(SELECT * FROM dbo.ZipCrimWorkOrders zcwo WHERE zcwo.APNO = @apno)
	BEGIN 
		INSERT INTO dbo.ZipCrimWorkOrders (APNO, refWorkOrderStatusID, IsAutomated)
		VALUES (@apno, 1, @isAutomated)
	END

	

	IF (@isAutomated = 1)
	BEGIN
		exec[dbo].[Win_Service_ApplAddPrivateNotes] @apno, @noDiversionNote
	END
	
	UPDATE dbo.Appl
	SET
		dbo.Appl.Investigator = 'ZIPCRIM',
		dbo.Appl.InUse = NULL,
		dbo.Appl.NeedsReview = substring(NeedsReview,1,1) + '3'
	WHERE dbo.Appl.APNO = @apno


-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 11/12/13
-- Description:	Updates the ServiceNextRunTime
-- =============================================
CREATE PROCEDURE [dbo].[UpdateServiceNextRunTime_BatchRebill] 
	-- Add the parameters for the stored procedure here
	@ServiceName varchar(50)
	
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	DECLARE @runDateTime Datetime
	DECLARE @nextRunDate Datetime
	DECLARE @nextRunTime Datetime

	SET @runDateTime = (SELECT ServiceNextRunTime FROM dbo.WinServiceSchedule WHERE ServiceName = @ServiceName)
	SET @nextRunDate = (SELECT DATEADD(MONTH, DATEDIFF(MONTH, 0 , @runDateTime), 0))
	SET @nextRunTime =  (SELECT DATEADD(HOUR, 3, @nextRunDate))

    -- Insert statements for procedure here
	UPDATE dbo.WinServiceSchedule SET ServiceNextRunTime = @nextRunTime WHERE ServiceName = @ServiceName

	
END


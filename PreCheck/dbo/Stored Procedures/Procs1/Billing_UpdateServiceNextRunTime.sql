
-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 11/12/13
-- Description:	Updates the ServiceNextRunTime
-- =============================================
CREATE PROCEDURE [dbo].[Billing_UpdateServiceNextRunTime] 
	-- Add the parameters for the stored procedure here
	@runTime datetime,
	@serverName varchar(50)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE dbo.WinServiceSchedule SET ServiceActive = 'True', ServiceNextRunTime = @runTime WHERE ServerName =@serverName and WinServiceScheduleID = 60
END


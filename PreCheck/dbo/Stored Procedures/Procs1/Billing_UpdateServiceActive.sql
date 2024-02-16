
-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 11/12/13
-- Description:	Update the ServiceActive to False
-- =============================================
CREATE PROCEDURE [dbo].[Billing_UpdateServiceActive] 
	-- Add the parameters for the stored procedure here
	@service bit,
	@serverName varchar(50)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE WinServiceSchedule SET ServiceActive=@service WHERE ServerName = @serverName and WinServiceScheduleID = 60
END



-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 11/12/13
-- Description:	Updates the ServiceNextRunTime
-- =============================================
CREATE PROCEDURE [dbo].[UpdateServiceNextRunTime] 
	-- Add the parameters for the stored procedure here
	@ServiceNextRunTime datetime,
	@ServiceName varchar(50)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE dbo.WinServiceSchedule SET ServiceActive = 'True', ServiceNextRunTime = @ServiceNextRunTime WHERE ServiceName =@ServiceName
END


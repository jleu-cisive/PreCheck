
-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 11/12/13
-- Description:	Checks the [UpdateWinServiceRunStatus]
-- =============================================
CREATE PROCEDURE [dbo].[UpdateWinServiceRunStatus] 
	-- Add the parameters for the stored procedure here
		@ServiceRunStatus bit,
		@ServiceRunDate dateTime,
		@ServiceName varchar(50) 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE dbo.WinServiceRunStatus SET ServiceRunStatus=@ServiceRunStatus, ServiceRunDate = @ServiceRunDate WHERE ServiceName = @ServiceName
END


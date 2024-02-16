
-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 11/12/13
-- Description:	Checks the [CheckWinServiceRunDate]
-- =============================================
CREATE PROCEDURE [dbo].[CheckWinServiceRunDate] 
	-- Add the parameters for the stored procedure here
		@ServiceName varchar(50),
		@ServiceRunDate dateTime output,
		@ServiceRunStatus bit output 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT @ServiceRunDate = ServiceRunDate, @ServiceRunStatus= ServiceRunStatus FROM dbo.WinServiceRunStatus WHERE ServiceName = @ServiceName
END


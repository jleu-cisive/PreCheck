-- =============================================
-- Author:		Doug DeGenaro
-- Create date: 1/3/2018
-- Description:	Reprocess stuck Mozenda jobs
-- =============================================
CREATE PROCEDURE dbo.AIMS_ReProcessByStatusUpdateId (
	-- Add the parameters for the stored procedure here
	@statusUpdateId int = 0)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF (@statusUpdateId > 0)
	BEGIN
		update dbo.AIMS_StatusUpdate 
		set IsProcessed=0,ProcessedDate=null
		where AIMS_StatusUpdateId = @statusUpdateId

		select AIMS_StatusUpdateId,IsProcessed,ProcessedDate from dbo.AIMS_StatusUpdate
		where AIMS_StatusUpdateId = @statusUpdateId 
	END

	
END

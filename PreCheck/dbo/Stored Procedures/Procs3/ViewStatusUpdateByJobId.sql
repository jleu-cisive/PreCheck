CREATE Procedure [dbo].[ViewStatusUpdateByJobId]

	@JobId int

	
AS
BEGIN
	
	SELECT * from dbo.AIMS_StatusUpdate where AimsJobItemId = @JobId

END
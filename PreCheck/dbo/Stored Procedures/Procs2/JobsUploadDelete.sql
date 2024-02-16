
CREATE PROCEDURE [dbo].JobsUploadDelete
(
	@Original_JobsUploadID int,
	@Original_Department varchar(50),
	@Original_FileName varchar(200),
	@Original_JobTitle varchar(200),
	@Original_URL varchar(200)
)
AS
	SET NOCOUNT OFF;
DELETE FROM dbo.JobsUpload WHERE (JobsUploadID = @Original_JobsUploadID) AND (Department = @Original_Department OR @Original_Department IS NULL AND Department IS NULL) AND (FileName = @Original_FileName OR @Original_FileName IS NULL AND FileName IS NULL) AND (JobTitle = @Original_JobTitle OR @Original_JobTitle IS NULL AND JobTitle IS NULL) AND (URL = @Original_URL OR @Original_URL IS NULL AND URL IS NULL)

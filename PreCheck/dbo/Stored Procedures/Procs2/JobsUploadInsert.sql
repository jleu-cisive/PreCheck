
CREATE PROCEDURE [dbo].JobsUploadInsert
(
	@Department varchar(50),
	@JobTitle varchar(200),
	@FileName varchar(200),
	@URL varchar(200)
)
AS
	SET NOCOUNT OFF;
INSERT INTO dbo.JobsUpload(Department, JobTitle, FileName, URL) VALUES (@Department, @JobTitle, @FileName, @URL);
	SELECT JobsUploadID, Department, JobTitle, FileName, URL FROM dbo.JobsUpload WHERE (JobsUploadID = @@IDENTITY)



CREATE PROCEDURE [dbo].[JobsUploadSelect]
AS
	SET NOCOUNT ON;
SELECT JobsUploadID, Department, JobTitle, FileName, URL FROM dbo.JobsUpload
 

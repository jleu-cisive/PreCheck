
CREATE PROCEDURE [dbo].FormJobsITInsert
(
	@Jobs text,
	@DepartmentID int
)
AS
	SET NOCOUNT OFF;
INSERT INTO dbo.MessageJobs(Jobs, DepartmentID) VALUES (@Jobs, @DepartmentID);
	SELECT MessageJobsID, Jobs, DepartmentID FROM dbo.MessageJobs WHERE (MessageJobsID = @@IDENTITY)


CREATE PROCEDURE [dbo].FormJobsITDelete
(
	@Original_MessageJobsID int,
	@Original_DepartmentID int
)
AS
	SET NOCOUNT OFF;
DELETE FROM dbo.MessageJobs WHERE (MessageJobsID = @Original_MessageJobsID) AND (DepartmentID = @Original_DepartmentID OR @Original_DepartmentID IS NULL AND DepartmentID IS NULL)

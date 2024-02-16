
CREATE PROCEDURE [dbo].FormJobsITSelect
AS
	SET NOCOUNT ON;
SELECT MessageJobsID, Jobs, DepartmentID FROM dbo.MessageJobs WHERE (DepartmentID = 1)

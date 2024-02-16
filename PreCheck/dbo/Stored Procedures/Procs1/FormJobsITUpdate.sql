
CREATE PROCEDURE [dbo].FormJobsITUpdate
(
	@Jobs text,
	@DepartmentID int,
	@Original_MessageJobsID int,
	@Original_DepartmentID int,
	@MessageJobsID int
)
AS
	SET NOCOUNT OFF;
UPDATE dbo.MessageJobs SET Jobs = @Jobs, DepartmentID = @DepartmentID WHERE (MessageJobsID = @Original_MessageJobsID) AND (DepartmentID = @Original_DepartmentID OR @Original_DepartmentID IS NULL AND DepartmentID IS NULL);
	SELECT MessageJobsID, Jobs, DepartmentID FROM dbo.MessageJobs WHERE (MessageJobsID = @MessageJobsID)

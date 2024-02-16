
CREATE PROCEDURE [dbo].FormTaskStatus2Update
(
	@TaskStatus varchar(50),
	@Original_refTaskStatusID int,
	@Original_TaskStatus varchar(50),
	@refTaskStatusID int
)
AS
	SET NOCOUNT OFF;
UPDATE dbo.refTaskStatus SET TaskStatus = @TaskStatus WHERE (refTaskStatusID = @Original_refTaskStatusID) AND (TaskStatus = @Original_TaskStatus);
	SELECT refTaskStatusID, TaskStatus FROM dbo.refTaskStatus WHERE (refTaskStatusID = @refTaskStatusID)

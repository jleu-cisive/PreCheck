
CREATE PROCEDURE [dbo].FormTaskStatus2Delete
(
	@Original_refTaskStatusID int,
	@Original_TaskStatus varchar(50)
)
AS
	SET NOCOUNT OFF;
DELETE FROM dbo.refTaskStatus WHERE (refTaskStatusID = @Original_refTaskStatusID) AND (TaskStatus = @Original_TaskStatus)

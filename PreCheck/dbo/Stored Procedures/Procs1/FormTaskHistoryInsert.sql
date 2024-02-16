CREATE PROCEDURE [dbo].FormTaskHistoryInsert
(
	@TaskHistoryID int,
	@TaskID int,
	@NewTaskStatusID int,
	@ChangedBy varchar(50),
	@ChangedDate datetime
)
AS
	SET NOCOUNT OFF;
INSERT INTO dbo.TaskHistory(TaskHistoryID, TaskID, NewTaskStatusID, ChangedBy, ChangedDate) VALUES (@TaskHistoryID, @TaskID, @NewTaskStatusID, @ChangedBy, @ChangedDate);
	SELECT TaskHistoryID, TaskID, NewTaskStatusID, ChangedBy, ChangedDate FROM dbo.TaskHistory WHERE (TaskHistoryID = @TaskHistoryID)
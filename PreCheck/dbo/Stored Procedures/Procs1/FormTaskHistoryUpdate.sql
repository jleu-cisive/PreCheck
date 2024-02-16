CREATE PROCEDURE [dbo].FormTaskHistoryUpdate
(
	@TaskHistoryID int,
	@TaskID int,
	@NewTaskStatusID int,
	@ChangedBy varchar(50),
	@ChangedDate datetime,
	@Original_TaskHistoryID int,
	@Original_ChangedBy varchar(50),
	@Original_ChangedDate datetime,
	@Original_NewTaskStatusID int,
	@Original_TaskID int
)
AS
	SET NOCOUNT OFF;
UPDATE dbo.TaskHistory SET TaskHistoryID = @TaskHistoryID, TaskID = @TaskID, NewTaskStatusID = @NewTaskStatusID, ChangedBy = @ChangedBy, ChangedDate = @ChangedDate WHERE (TaskHistoryID = @Original_TaskHistoryID) AND (ChangedBy = @Original_ChangedBy OR @Original_ChangedBy IS NULL AND ChangedBy IS NULL) AND (ChangedDate = @Original_ChangedDate) AND (NewTaskStatusID = @Original_NewTaskStatusID) AND (TaskID = @Original_TaskID);
	SELECT TaskHistoryID, TaskID, NewTaskStatusID, ChangedBy, ChangedDate FROM dbo.TaskHistory WHERE (TaskHistoryID = @TaskHistoryID)
CREATE PROCEDURE [dbo].FormTaskHistoryDelete
(
	@Original_TaskHistoryID int,
	@Original_ChangedBy varchar(50),
	@Original_ChangedDate datetime,
	@Original_NewTaskStatusID int,
	@Original_TaskID int
)
AS
	SET NOCOUNT OFF;
DELETE FROM dbo.TaskHistory WHERE (TaskHistoryID = @Original_TaskHistoryID) AND (ChangedBy = @Original_ChangedBy OR @Original_ChangedBy IS NULL AND ChangedBy IS NULL) AND (ChangedDate = @Original_ChangedDate) AND (NewTaskStatusID = @Original_NewTaskStatusID) AND (TaskID = @Original_TaskID)
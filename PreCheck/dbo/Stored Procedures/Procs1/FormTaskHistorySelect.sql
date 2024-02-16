CREATE PROCEDURE [dbo].FormTaskHistorySelect
AS
	SET NOCOUNT ON;
SELECT TaskHistoryID, TaskID, NewTaskStatusID, ChangedBy, ChangedDate FROM dbo.TaskHistory
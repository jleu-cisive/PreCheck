CREATE PROCEDURE [dbo].[FormTaskNewProjectDel] AS

DELETE FROM dbo.TaskQueueNew
		exec InUseTaskClear


CREATE PROCEDURE [dbo].[FormTaskQueueDel] AS

DELETE FROM dbo.TaskQueue
DELETE FROM dbo.TaskQueueNew
		exec InUseTaskClear
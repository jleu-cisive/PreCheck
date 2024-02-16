

CREATE PROCEDURE [dbo].[FormTaskNewProjectDelB4] AS

DELETE FROM dbo.TaskQueueNew
		exec InUseTaskClear

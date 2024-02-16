
CREATE PROCEDURE [dbo].FormTaskNewProjectSelect
AS
	SET NOCOUNT ON;
SELECT TOP 0 TaskQueueNewID, Name, Description, Notes, Structure, DeadLine, TaskTypeID, DeveloperID, StatusID, inUse, Client, ProjectTypeID, PriorityLevelID FROM dbo.TaskQueueNew

CREATE  PROCEDURE [dbo].[UpdateTaskDeadlineMet] AS
UPDATE    Task
SET              DeadLineMet = 'N'
FROM Task
WHERE     (NOT (DeadLine IS NULL)) AND (DeadLineMet IS NULL) AND (DeadLine < (GETDATE()-1))
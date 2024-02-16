
CREATE PROCEDURE [dbo].FormTaskPriorityLevelSelect
AS
	SET NOCOUNT ON;
SELECT TaskPriorityLevelID, TaskPriorityLevel, IsActive FROM dbo.refTaskPriorityLevel

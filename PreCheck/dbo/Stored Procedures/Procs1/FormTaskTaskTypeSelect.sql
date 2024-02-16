
CREATE PROCEDURE [dbo].FormTaskTaskTypeSelect
AS
	SET NOCOUNT ON;
SELECT refTaskTypeID, TaskType, IsActive FROM dbo.refTaskType

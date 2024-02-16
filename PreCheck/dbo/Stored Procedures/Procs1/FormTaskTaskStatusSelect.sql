CREATE  PROCEDURE [dbo].FormTaskTaskStatusSelect
AS
	SET NOCOUNT ON;
SELECT refTaskStatusID, displayOrder, TaskStatus, IsActive 
FROM dbo.refTaskStatus
ORDER BY DisplayOrder
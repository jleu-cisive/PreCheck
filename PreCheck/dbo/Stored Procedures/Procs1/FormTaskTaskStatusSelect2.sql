
CREATE PROCEDURE [dbo].FormTaskTaskStatusSelect2
AS
	SET NOCOUNT ON;
SELECT refTaskStatusID, TaskStatus, DisplayOrder FROM dbo.refTaskStatus WHERE (refTaskStatusID = 4) OR (refTaskStatusID = 5)


CREATE PROCEDURE [DBO].[FormTaskTaskStatusSelectn4]
AS
	SET NOCOUNT ON;
SELECT refTaskStatusID, TaskStatus, IsActive FROM dbo.refTaskStatus

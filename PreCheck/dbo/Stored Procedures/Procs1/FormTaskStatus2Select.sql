
CREATE PROCEDURE [dbo].FormTaskStatus2Select
AS
	SET NOCOUNT ON;
SELECT refTaskStatusID, TaskStatus FROM dbo.refTaskStatus

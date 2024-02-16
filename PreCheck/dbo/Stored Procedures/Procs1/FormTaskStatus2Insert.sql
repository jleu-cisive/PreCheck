
CREATE PROCEDURE [dbo].FormTaskStatus2Insert
(
	@TaskStatus varchar(50)
)
AS
	SET NOCOUNT OFF;
INSERT INTO dbo.refTaskStatus(TaskStatus) VALUES (@TaskStatus);
	SELECT refTaskStatusID, TaskStatus FROM dbo.refTaskStatus WHERE (refTaskStatusID = @@IDENTITY)

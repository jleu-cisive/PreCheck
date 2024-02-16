
CREATE PROCEDURE [DBO].FormTaskTaskStatusInsert
(
	@TaskStatus varchar(50),
	@IsActive bit
)
AS
	SET NOCOUNT OFF;
INSERT INTO dbo.refTaskStatus(TaskStatus, IsActive) VALUES (@TaskStatus, @IsActive);
	SELECT refTaskStatusID, TaskStatus, IsActive FROM dbo.refTaskStatus WHERE (refTaskStatusID = @@IDENTITY)

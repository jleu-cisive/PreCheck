
CREATE PROCEDURE [dbo].FormTaskPriorityLevelInsert
(
	@TaskPriorityLevel varchar(50),
	@IsActive bit
)
AS
	SET NOCOUNT OFF;
INSERT INTO dbo.refTaskPriorityLevel(TaskPriorityLevel, IsActive) VALUES (@TaskPriorityLevel, @IsActive);
	SELECT TaskPriorityLevelID, TaskPriorityLevel, IsActive FROM dbo.refTaskPriorityLevel WHERE (TaskPriorityLevelID = @@IDENTITY)

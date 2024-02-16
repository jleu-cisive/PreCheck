
CREATE PROCEDURE [dbo].FormTaskPriorityLevelUpdate
(
	@TaskPriorityLevel varchar(50),
	@IsActive bit,
	@Original_TaskPriorityLevelID int,
	@Original_IsActive bit,
	@Original_TaskPriorityLevel varchar(50),
	@TaskPriorityLevelID int
)
AS
	SET NOCOUNT OFF;
UPDATE dbo.refTaskPriorityLevel SET TaskPriorityLevel = @TaskPriorityLevel, IsActive = @IsActive WHERE (TaskPriorityLevelID = @Original_TaskPriorityLevelID) AND (IsActive = @Original_IsActive) AND (TaskPriorityLevel = @Original_TaskPriorityLevel OR @Original_TaskPriorityLevel IS NULL AND TaskPriorityLevel IS NULL);
	SELECT TaskPriorityLevelID, TaskPriorityLevel, IsActive FROM dbo.refTaskPriorityLevel WHERE (TaskPriorityLevelID = @TaskPriorityLevelID)


CREATE PROCEDURE [dbo].FormTaskPriorityLevelDelete
(
	@Original_TaskPriorityLevelID int,
	@Original_IsActive bit,
	@Original_TaskPriorityLevel varchar(50)
)
AS
	SET NOCOUNT OFF;
DELETE FROM dbo.refTaskPriorityLevel WHERE (TaskPriorityLevelID = @Original_TaskPriorityLevelID) AND (IsActive = @Original_IsActive) AND (TaskPriorityLevel = @Original_TaskPriorityLevel OR @Original_TaskPriorityLevel IS NULL AND TaskPriorityLevel IS NULL)

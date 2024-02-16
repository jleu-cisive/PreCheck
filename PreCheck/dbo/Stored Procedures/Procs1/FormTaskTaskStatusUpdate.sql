
CREATE PROCEDURE [DBO].FormTaskTaskStatusUpdate
(
	@TaskStatus varchar(50),
	@IsActive bit,
	@Original_refTaskStatusID int,
	@Original_IsActive bit,
	@Original_TaskStatus varchar(50),
	@refTaskStatusID int
)
AS
	SET NOCOUNT OFF;
UPDATE dbo.refTaskStatus SET TaskStatus = @TaskStatus, IsActive = @IsActive WHERE (refTaskStatusID = @Original_refTaskStatusID) AND (IsActive = @Original_IsActive OR @Original_IsActive IS NULL AND IsActive IS NULL) AND (TaskStatus = @Original_TaskStatus);
	SELECT refTaskStatusID, TaskStatus, IsActive FROM dbo.refTaskStatus WHERE (refTaskStatusID = @refTaskStatusID)

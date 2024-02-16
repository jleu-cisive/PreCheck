
CREATE PROCEDURE [dbo].FormTaskTaskStatusUpdate2
(
	@TaskStatus varchar(50),
	@DisplayOrder int,
	@Original_refTaskStatusID int,
	@Original_DisplayOrder int,
	@Original_TaskStatus varchar(50),
	@refTaskStatusID int
)
AS
	SET NOCOUNT OFF;
UPDATE dbo.refTaskStatus SET TaskStatus = @TaskStatus, DisplayOrder = @DisplayOrder WHERE (refTaskStatusID = @Original_refTaskStatusID) AND (DisplayOrder = @Original_DisplayOrder OR @Original_DisplayOrder IS NULL AND DisplayOrder IS NULL) AND (TaskStatus = @Original_TaskStatus);
	SELECT refTaskStatusID, TaskStatus, DisplayOrder FROM dbo.refTaskStatus WHERE (refTaskStatusID = @refTaskStatusID)


CREATE PROCEDURE [dbo].FormTaskTaskStatusDelete2
(
	@Original_refTaskStatusID int,
	@Original_DisplayOrder int,
	@Original_TaskStatus varchar(50)
)
AS
	SET NOCOUNT OFF;
DELETE FROM dbo.refTaskStatus WHERE (refTaskStatusID = @Original_refTaskStatusID) AND (DisplayOrder = @Original_DisplayOrder OR @Original_DisplayOrder IS NULL AND DisplayOrder IS NULL) AND (TaskStatus = @Original_TaskStatus)

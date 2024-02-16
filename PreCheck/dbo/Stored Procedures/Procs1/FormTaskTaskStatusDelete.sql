
CREATE PROCEDURE [DBO].FormTaskTaskStatusDelete
(
	@Original_refTaskStatusID int,
	@Original_IsActive bit,
	@Original_TaskStatus varchar(50)
)
AS
	SET NOCOUNT OFF;
DELETE FROM dbo.refTaskStatus WHERE (refTaskStatusID = @Original_refTaskStatusID) AND (IsActive = @Original_IsActive OR @Original_IsActive IS NULL AND IsActive IS NULL) AND (TaskStatus = @Original_TaskStatus)

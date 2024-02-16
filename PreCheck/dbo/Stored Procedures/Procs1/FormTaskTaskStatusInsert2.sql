
CREATE PROCEDURE [dbo].FormTaskTaskStatusInsert2
(
	@TaskStatus varchar(50),
	@DisplayOrder int
)
AS
	SET NOCOUNT OFF;
INSERT INTO dbo.refTaskStatus(TaskStatus, DisplayOrder) VALUES (@TaskStatus, @DisplayOrder);
	SELECT refTaskStatusID, TaskStatus, DisplayOrder FROM dbo.refTaskStatus WHERE (refTaskStatusID = @@IDENTITY)

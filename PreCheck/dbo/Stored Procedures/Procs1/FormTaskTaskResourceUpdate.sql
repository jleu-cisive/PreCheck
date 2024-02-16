
CREATE PROCEDURE [DBO].FormTaskTaskResourceUpdate
(
	@Name varchar(50),
	@IsActive bit,
	@email varchar(50),
	@Original_TaskResourceID int,
	@Original_email varchar(50),
	@Original_IsActive bit,
	@Original_Name varchar(50),
	@TaskResourceID int
)
AS
	SET NOCOUNT OFF;
UPDATE dbo.TaskResource SET Name = @Name, IsActive = @IsActive, email = @email  WHERE (TaskResourceID = @Original_TaskResourceID) AND (IsActive = @Original_IsActive)  AND (email = @Original_email) AND (Name = @Original_Name OR @Original_Name IS NULL AND Name IS NULL);
	SELECT TaskResourceID, Name, IsActive, email FROM dbo.TaskResource WHERE (TaskResourceID = @TaskResourceID)

CREATE PROCEDURE [DBO].FormTaskTaskResourceInsert
(
	@Name varchar(50),
	@IsActive bit,
	@email varchar(50)
)
AS
	SET NOCOUNT OFF;
INSERT INTO dbo.TaskResource(Name, IsActive, email) VALUES (@Name, @IsActive, @email);
	SELECT TaskResourceID, Name, IsActive, email FROM dbo.TaskResource WHERE (TaskResourceID = @@IDENTITY)
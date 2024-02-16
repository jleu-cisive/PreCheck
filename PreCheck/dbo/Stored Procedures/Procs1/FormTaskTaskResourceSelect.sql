

CREATE PROCEDURE [dbo].[FormTaskTaskResourceSelect]
AS
	SET NOCOUNT ON;
SELECT TaskResourceID, Name, IsActive, email FROM dbo.TaskResource WHERE IsActive=1

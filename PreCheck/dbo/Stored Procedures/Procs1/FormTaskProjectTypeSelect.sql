
CREATE PROCEDURE [dbo].FormTaskProjectTypeSelect
AS
	SET NOCOUNT ON;
SELECT refProjectTypeID, ProjectType FROM dbo.refTaskProjectType

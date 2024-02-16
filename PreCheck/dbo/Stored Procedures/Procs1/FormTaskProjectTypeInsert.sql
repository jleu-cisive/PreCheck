
CREATE PROCEDURE [dbo].FormTaskProjectTypeInsert
(
	@ProjectType char(50)
)
AS
	SET NOCOUNT OFF;
INSERT INTO dbo.refTaskProjectType(ProjectType) VALUES (@ProjectType);
	SELECT refProjectTypeID, ProjectType FROM dbo.refTaskProjectType WHERE (refProjectTypeID = @@IDENTITY)


CREATE PROCEDURE [dbo].FormTaskProjectTypeUpdate
(
	@ProjectType char(50),
	@Original_refProjectTypeID int,
	@Original_ProjectType char(50),
	@refProjectTypeID int
)
AS
	SET NOCOUNT OFF;
UPDATE dbo.refTaskProjectType SET ProjectType = @ProjectType WHERE (refProjectTypeID = @Original_refProjectTypeID) AND (ProjectType = @Original_ProjectType OR @Original_ProjectType IS NULL AND ProjectType IS NULL);
	SELECT refProjectTypeID, ProjectType FROM dbo.refTaskProjectType WHERE (refProjectTypeID = @refProjectTypeID)

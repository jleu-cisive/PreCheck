

CREATE PROCEDURE [dbo].FormTaskProjectTypeDelete
(
	@Original_refProjectTypeID int,
	@Original_ProjectType char(50)
)
AS
	SET NOCOUNT OFF;
DELETE FROM dbo.refTaskProjectType WHERE (refProjectTypeID = @Original_refProjectTypeID) AND (ProjectType = @Original_ProjectType OR @Original_ProjectType IS NULL AND ProjectType IS NULL)

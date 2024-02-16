CREATE PROCEDURE dbo.FormUserPermissionCopyFromTemplate
(@DestTemplateID varchar(8), @SrcTemplateID varchar(8))
AS
SET NOCOUNT ON

UPDATE 	dbo.Users
SET 	CanSetManager = U2.CanSetManager
	, CanEditPermission = U2.CanEditPermission
	, CanEditDroplist = U2.CanEditDroplist
	, CanEditCounties = U2.CanEditCounties
	, CanCreateNewUser = U2.CanCreateNewUser
	, empl = U2.empl
	, educat = U2.educat
	, persref = U2.persref
	, proflic = U2.proflic
	, csr = U2.csr
	, Criminal = U2.Criminal
FROM 	(SELECT TOP 1 CanSetManager, CanEditPermission, CanEditDroplist, CanCreateNewUser, CanEditCounties, Sales, empl, educat, persref, proflic, csr, criminal FROM dbo.Users WHERE UserID = @SrcTemplateID) AS U2
WHERE	dbo.Users.UserID = @DestTemplateID

DELETE FROM dbo.UserPermissionAccess WHERE UserID = @DestTemplateID
INSERT INTO dbo.UserPermissionAccess SELECT refPermissionID, @DestTemplateID, FormOrTabName FROM dbo.UserPermissionAccess WHERE UserID = @SrcTemplateID

SET NOCOUNT OFF

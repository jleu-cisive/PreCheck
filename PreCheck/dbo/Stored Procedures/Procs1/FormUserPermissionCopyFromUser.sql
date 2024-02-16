CREATE PROCEDURE dbo.FormUserPermissionCopyFromUser
(@DestUserID varchar(8), @SrcUserID varchar(8))
AS
SET NOCOUNT ON

UPDATE 	dbo.Users
SET 	CanSetManager = U2.CanSetManager
	, CanEditPermission = U2.CanEditPermission
	, CanEditDroplist = U2.CanEditDroplist
	, CanCreateNewUser = U2.CanCreateNewUser
	, ShowAllUsers = U2.ShowAllUsers
	, ManageUsers = U2.ManageUsers
	, CanEditCounties = U2.CanEditCounties
	, Investigator = U2.Investigator
	, Sales = U2.Sales
	, empl = U2.empl
	, educat = U2.educat
	, persref = U2.persref
	, proflic = U2.proflic
	, csr = U2.csr
	, criminal = U2.criminal
FROM 	(SELECT TOP 1 CanSetManager, CanEditPermission, CanEditDroplist, CanCreateNewUser, ShowAllUsers, ManageUsers, CanEditCounties, Investigator, Sales, empl, educat, persref, proflic, csr, criminal FROM dbo.Users WHERE UserID = @SrcUserID) AS U2
WHERE	dbo.Users.UserID = @DestUserID

DELETE FROM dbo.UserPermissionAccess WHERE UserID = @DestUserID
INSERT INTO dbo.UserPermissionAccess SELECT refPermissionID, @DestUserID, FormOrTabName FROM dbo.UserPermissionAccess WHERE UserID = @SrcUserID

SET NOCOUNT OFF

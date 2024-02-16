CREATE PROCEDURE dbo.FormUserPermissionGetPermissionAccess
(@UserID varchar(8), @ManagerID varchar(8))
AS
SET NOCOUNT ON
(
SELECT 	U1.refPermissionID
	, U1.FormOrTabName
	, ISNULL((SELECT TOP 1 U2.refPermissionID FROM dbo.UserPermissionAccess U2 WHERE U2.UserID = @ManagerID AND U2.FormOrTabName = U1.FormOrTabName), 1) AS HighestLevel
FROM 	dbo.UserPermissionAccess U1 
WHERE 	U1.UserID = @UserID

UNION

SELECT 	1 AS refPermissionID
	, FormOrTabName
	, refPermissionID AS HighestLevel 
FROM 	dbo.UserPermissionAccess 
WHERE 	UserID = @ManagerID
	AND FormOrTabName NOT IN (SELECT FormOrTabName FROM dbo.UserPermissionAccess WHERE UserID = @UserID)
	AND refPermissionID > 1
)
SET NOCOUNT OFF

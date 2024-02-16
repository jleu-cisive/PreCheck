CREATE PROCEDURE dbo.GetUserAccessPermission @Section varchar(50), @UserID varchar(8) AS

DECLARE @permission varchar(50)

If @Section='Task' 
	SELECT @permission=Permission FROM Users u JOIN refPermission p ON p.refPermissionID=u.TaskrefPermissionID WHERE UserID=@UserID
else -- for now, later must expand to section by section list, based of checkbox and security level
	SELECT @permission='EditPreferred' 

SELECT @permission
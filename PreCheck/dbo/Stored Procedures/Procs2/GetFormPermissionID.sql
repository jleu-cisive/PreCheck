CREATE PROCEDURE dbo.GetFormPermissionID
(@UserID varchar(8), @FormOrTabName varchar(50))
AS
SET NOCOUNT ON

IF EXISTS (SELECT * FROM dbo.SysObjects WHERE ID = OBJECT_ID('dbo.UserPermissionAccess') AND XTYPE = 'U')
  SELECT TOP 1 refPermissionID FROM dbo.UserPermissionAccess WHERE UserID = (SELECT TOP 1 TemplateID FROM dbo.Users WHERE UserID = @UserID) AND FormOrTabName = @FormOrTabName
ELSE
  SELECT 4 AS refPermissionID

SET NOCOUNT OFF

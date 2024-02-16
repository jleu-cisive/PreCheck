CREATE PROCEDURE dbo.FormUserPermissionUpdatePermissionAccess
(@UserID varchar(8), @FormOrTabName varchar(50), @refPermissionID int, @IsCascadeDown bit)
AS
SET NOCOUNT ON

IF @refPermissionID = 1
  DELETE FROM dbo.UserPermissionAccess WHERE FormOrTabName = @FormOrTabName AND UserID = @UserID
ELSE IF (SELECT COUNT(*) FROM dbo.UserPermissionAccess WHERE FormOrTabName = @FormOrTabName AND UserID = @UserID) = 0 AND @IsCascadeDown = 0
  INSERT INTO dbo.UserPermissionAccess SELECT @refPermissionID, @UserID, @FormOrTabName
ELSE
  UPDATE dbo.UserPermissionAccess SET refPermissionID = @refPermissionID WHERE FormOrTabName = @FormOrTabName AND UserID = @UserID

SET NOCOUNT OFF

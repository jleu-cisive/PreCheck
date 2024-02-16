-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetFormPermissionIDByApp]
	-- Add the parameters for the stored procedure here
	(@UserID varchar(8), @FormOrTabName varchar(50))
AS
SET NOCOUNT ON

IF EXISTS (SELECT * FROM dbo.SysObjects WHERE ID = OBJECT_ID('dbo.UserPermissionAccess') AND XTYPE = 'U')
  SELECT refPermissionID,FormOrTabName FROM dbo.UserPermissionAccess WHERE UserID = (SELECT TOP 1 TemplateID FROM dbo.Users WHERE UserID = @UserID) AND FormOrTabName like '%' + @FormOrTabName +'%'
ELSE
  SELECT 4 AS refPermissionID

SET NOCOUNT OFF
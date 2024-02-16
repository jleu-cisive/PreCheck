CREATE PROCEDURE [dbo].[GetClientConfigurationUsers]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Region Parameters
DECLARE @p0 Int = 4
DECLARE @p1 VarChar(1000) = 'FormClient'
DECLARE @p2 VarChar(1000) = 'IT'
-- EndRegion
SELECT DISTINCT [t1].[UserID], [t1].Department
FROM [UserPermissionAccess] AS [t0], [Users] AS [t1]
WHERE ([t0].[refPermissionID] = @p0) AND ([t0].[FormOrTabName] = @p1) AND (([t1].[TemplateID] = [t0].[UserID]) OR ([t1].[Department] = @p2))


END

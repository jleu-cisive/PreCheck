






CREATE VIEW [dbo].[vwClientPrivilege]
AS

SELECT Privilege.PrincipalId AS UserId -- PrincipalId
	,Principal.[username] AS UserName
	,Privilege.ResourceId AS ClientId --ResourceId
	,Principal.Email AS UserEmail
	,[Resource].[Name]  AS Client
	,[Resource].[WebOrderParentCLNO] AS [ParentClientId]
FROM [Security].[vwPrivilege] Privilege
INNER JOIN [dbo].[Client] [Resource]
	ON Privilege.ResourceId = [Resource].CLNO
INNER JOIN [dbo].[ClientContacts]  [Principal]
	ON Privilege.PrincipalId = Principal.[ContactID]
WHERE [PrincipalTypeId] = 1
AND ResourceTypeId = 2








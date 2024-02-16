
/*******************************************************
Author: Radhika Dereddy
Date Created: 05/18/2020
Purpose: Create a view for the Role Based access in Client Access Application
         for PowerBi Dashboard availability
Execution: SELECT * FROM [dbo].[vwClientContact]
********************************************************/


CREATE VIEW [dbo].[vwClientContact]
AS

SELECT Privilege.PrincipalId AS UserId -- PrincipalId
	,Principal.[username] AS UserName
	,R.[RoleId] AS RoleId --ResourceId
	,Principal.Email AS UserEmail
	,[Principal].[CLNO]  AS ClientId
FROM [dbo].[ClientContacts]  [Principal]
LEFT JOIN [Security].[vwPrivilege] Privilege
	ON Principal.[ContactID] = Privilege.PrincipalId
LEFT JOIN Precheck.dbo.[Role] [R]
	ON Privilege.ResourceId = R.[RoleId]
WHERE [PrincipalTypeId] = 1
AND ResourceTypeId = 3

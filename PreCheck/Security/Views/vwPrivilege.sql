CREATE VIEW [Security].[vwPrivilege]
AS
SELECT 
	   P.[PrivilegeId]
      ,P.[PrincipalTypeId]
	  ,PT.[PrincipalTypeName] AS PrincipalType
	  ,PT.[ShortName] AS PrincipalTypeShortName
	  ,PT.[EntityName]	AS PrincipalTypeEntity
      ,P.[PrincipalId]
      ,P.[ResourceTypeId]
	  ,RT.[ResourceTypeName] AS ResourceType
	  ,RT.[ShortName] AS ResourceTypeShortName
	  ,RT.[EntityName]	AS ResourceTypeEntity
      ,P.[ResourceId]
      ,P.[AccessTypeId]
	  ,AT.[AccessTypeName] AS AccessType
	  ,AT.[ShortName] AS AccessTypeShortName
	  ,AT.[EntityName]	AS AccessTypeEntity
      ,P.[AccessId]
      ,P.[IsActive]
      ,P.[CreateDate]
      ,P.[CreateBy]
      ,P.[ModifyDate]
      ,P.[ModifyBy]
FROM [Security].[Privilege] P
INNER JOIN [Security].[PrincipalType] PT
	ON P.[PrincipalTypeId] = PT.[PrincipalTypeId]
INNER JOIN [Security].[ResourceType]	RT
	ON P.ResourceTypeId = RT.ResourceTypeId
LEFT OUTER JOIN [Security].[AccessType] AT
	ON P.AccessTypeId = AT.AccessTypeId


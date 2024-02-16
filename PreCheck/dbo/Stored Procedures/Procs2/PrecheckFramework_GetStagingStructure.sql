CREATE procedure [dbo].[PrecheckFramework_GetStagingStructure]      
as      
      
select top 0 * from [dbo].[PrecheckFramework_ApplStaging]      
select top 0 * from [dbo].[PrecheckFramework_EmplStaging]    
select top 0 * from [dbo].[PrecheckFramework_EducatStaging]  
select top 0 * from [dbo].[PrecheckFramework_ProfLicStaging]  
select top 0 * from [dbo].[PrecheckFramework_PersRefStaging]  
select top 0 * from dbo.PrecheckFramework_MVRPIDSCStaging
select top 0 * from [dbo].[PrecheckFramework_PublicRecordsStaging]
select top 0 * from [dbo].[PrecheckFramework_ApplAliasStaging]
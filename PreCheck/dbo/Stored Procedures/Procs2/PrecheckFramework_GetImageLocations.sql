
CREATE procedure [dbo].[PrecheckFramework_GetImageLocations]
as
SELECT [ApplFileLocationID] ,[APNOStart] ,[APNOEnd] ,[FilePath] ,[GroupSize] ,[SubFolder] ,afl.[refApplTypeID] ,rf.Description,[SearchRoot] FROM [dbo].[ApplFileLocation] afl join [dbo].RefApplFileType rf on afl.[refApplTypeID] = rf.[refApplFileTypeID]

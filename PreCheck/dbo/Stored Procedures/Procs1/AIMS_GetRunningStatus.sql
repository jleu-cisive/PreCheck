CREATE procedure [dbo].[AIMS_GetRunningStatus]
@sectionKeyId varchar(10), @section varchar(10)

as 
begin
declare @AIMSRunningCount int;
declare @UtilRunningCount int;

select @AIMSRunningCount = count(1) from dbo.AIMS_Jobs where SectionKeyId = @sectionKeyId AND section = @section  AND AIMS_JobStatus IN ('Q','A')
SELECT @UtilRunningCount = COUNT(1) from dataXtract_Logging where DateLogRequest is null and SectionKeyId = @sectionKeyId AND section = @section
IF (@AIMSRunningCount > 0 or @UtilRunningCount > 0)
	Select CAST(1 AS bit) as IsRunning
else
	Select CAST(0 AS bit) as IsRunning

end
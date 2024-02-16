--dbo.AIMS_Queue_LicensingJob 'UT-RN','CC'

CREATE procedure dbo.AIMS_Queue_LicensingJob(@sectionkeyid varchar(50),@type varchar(50))
as
declare @id int
declare @currentdate varchar(50)
declare @scheduleId int

set @currentdate =  convert(varchar(10), GETDATE(), 101)

select @id = DataXtract_RequestMappingXMLID from dbo.DataXtract_RequestMapping where SectionKeyID = @sectionkeyid
update 
	dbo.DataXtract_AIMS_Schedule
set 
	NextRunTime = dateadd(day,datediff(day,NextRunTime,@currentdate),NextRunTime)  
where 
	DataXtract_RequestMappingXMLID = @id and refAIMS_SectionTypeCode=@type

select  DataXtract_AIMS_ScheduleID from dbo.DataXtract_AIMS_Schedule where DataXtract_RequestMappingXMLID = @id and refAIMS_SectionTypeCode=@type
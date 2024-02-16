--dbo.AIMS_ShowScheduleAndLastSuccesfulRun 'TX-RN'
CREATE procedure dbo.AIMS_ShowScheduleAndLastSuccesfulRun
(@sectionkeyid varchar(30))
as
declare @loggingid int 
declare @status varchar(15)
declare @jobstart datetime
declare @jobend datetime
declare @jobcreationdate datetime
declare @jobid int

select top 1 @jobid = AIMS_JobId,@status =rajs.Description,@jobstart = JobStart,@jobend = JobEnd,@jobcreationdate = CreatedDate,@loggingid = DataXtract_LoggingId from dbo.AIMS_Jobs aj inner join dbo.refAIMS_JobStatus rajs
on aj.AIMS_jobStatus=rajs.AIMS_JobStatus 
where SectionKeyID = @sectionkeyid and aj.AIMS_JobStatus not in ('A','R','E','U','D') 
order by AIMS_JobID desc

select 
	'Schedule' as 'Type',
	null as Id,
	null as Status,
	null as 'Error',
	case when refAIMS_SectionTypeCode = 'CC' then 'Monthly' else 'All' end Type,
	NextRunTime as ScheduledTime,
	null as '[Completed Date]',
	null as 'Created',
	null as 'Start',
	null as 'End', 
	null as 'Ran By'
from dbo.DataXtract_AIMS_Schedule where DataXtract_RequestMappingXMLId in 
(select DataXtract_RequestMappingXMLID from dbo.DataXtract_RequestMapping where SectionKeyID = @sectionkeyid)
and iSactive=1
UNION ALL
select 
	'Job' as 'Type',
	@jobid as 'Id',
	@Status as 'Status',
	null as 'Error',
	null as 'Type',
	null as 'ScheduledTime',
	null as '[Completed Date]',
	@jobcreationdate as 'Created',
	@JobStart as 'Start',
	@jobend as 'End',
	null as 'Ran By'
UNION ALL
select 
	'Log' as 'Type',
	DataXtract_LoggingId as 'Id',
	ResponseStatus as 'Status',
	ResponseError as 'Error',
	null as 'Type',
	null as 'ScheduledTime',
	DateLogResponse as '[Completed Date]',
	null as 'Created',
	null as 'Start',
	null as 'End', 
	LogUser as '[Ran By]' 
from dbo.DataXtract_Logging where DataXtract_LoggingId = @loggingid
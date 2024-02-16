--dbo.DataXtract_GetAIMSLog

CREATE procedure dbo.DataXtract_GetAIMSLog(
@SectionKeyID varchar(30) = '938',
@StartDate datetime = '07/13/2015',
@EndDate datetime = '07/13/2015')
as
Select distinct
	
	AIMS_JobID,
	AIMS_JobStatus,
	Request, 
	Response, 
	ResponseError, 
	ResponseStatus, 
	DateLogRequest,
	DateLogResponse,
	LogUser 
		From 
	dbo.DataXtract_Logging l (Nolock) 
	left join dbo.AIMS_Jobs j (Nolock) on j.DataXtract_LoggingId = l.DataXtract_LoggingId
	Where 
	--l.Section = 'Crim' and 
	l.SectionKeyID = @SectionKeyID
	and DateLogRequest between @StartDate and DateAdd(d,1,@EndDate) and j.DataXtract_LoggingId is not null
	--SectionKeyID = --295-- 
	--and DateLogRequest between --'01/01/2011'-- and DateAdd(d,1,--'02/01/2011'--)


--  Exec [AIMS_CredentCheck_Log] 'GA-LPN','03/20/2017','03/20/2017'
CREATE PROCEDURE [dbo].[AIMS_CredentCheck_Log]
   @SectionKeyID varchar(20),
   @Startdate  datetime,
    @Enddate  datetime
AS

BEGIN
Select  lg.DataXtract_LoggingId,IsNull(Parent_LoggingId,lg.DataXtract_LoggingId) as Parent_LoggingId , LG.SectionKeyId,LG.Section,su.SearchOrderId,  ResponseError, ResponseStatus, DateLogRequest, DateLogResponse, LogUser, ProcessDate, ProcessFlag, Total_Records, Total_Clears, Total_Exceptions,Total_NoChange,Response_RecordCount,
case when 
	J.AIMS_JobStatus ='Z' then 'Zero records in the input'
	when J.AIMS_JobStatus ='Q' then 'Queued'
	when J.AIMS_JobStatus ='C' then 'Completed'
	when j.AIMS_JobStatus = 'A' then 'Active'
	when j.AIMS_JobStatus = 'E' then 'Error' 
else 'NA' end as CurrentStatus
From dbo.DataXtract_Logging lg (Nolock) left join dbo.AIMS_StatusUpdate su (NoLock) on lg.AIMS_StatusUpdateId = su.AIMS_StatusUpdateId
left join dbo.AIMS_Jobs j (NoLock) on lg.DataXtract_LoggingId = J.DataXtract_LoggingId     
Where LG.Section <> 'Crim' 
and DateLogRequest between @Startdate and DateAdd(d,1,@Enddate)
and LG.SectionKeyID = (Case when len(@SectionKeyID) > 0 then  @SectionKeyID  else LG.SectionKeyID end)
order by DateLogRequest--Parent_LoggingId,SearchOrderId

END


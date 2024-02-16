

--  Exec [AIMS_CredentCheck_Log_Archive] 'NH-RN','05/1/2016','06/03/2016'
CREATE PROCEDURE [dbo].[AIMS_CredentCheck_Log_Archive]
   @SectionKeyID varchar(20),
   @Startdate  datetime,
    @Enddate  datetime
AS

BEGIN
Create table #ActiveRecord (DataXtract_LoggingId INT ,Parent_LoggingId INT,SectionKeyId varchar(50),Section varchar(100),SearchOrderId INT,
								ResponseError varchar(max), ResponseStatus varchar(20), DateLogRequest datetime, DateLogResponse datetime, LogUser varchar(30), ProcessDate datetime,
								 ProcessFlag bit, Total_Records INT , Total_Clears INT, Total_Exceptions INT,Total_NoChange INT,Response_RecordCount INT,CurrentStatus VARCHAR(200))

--DECLARE @ArchiveRecordRecord as Table(DataXtract_LoggingId INT primary key,Parent_LoggingId INT,SectionKeyId varchar(50),Section varchar(100),SearchOrderId INT,
--								ResponseError varchar(max), ResponseStatus varchar(20), DateLogRequest datetime, DateLogResponse datetime, LogUser varchar(30), ProcessDate datetime,
--								 ProcessFlag bit, Total_Records INT , Total_Clears INT, Total_Exceptions INT,Total_NoChange INT,Response_RecordCount INT,CurrentStatus VARCHAR(200))


-----------------------------------------------------------------------------FETCH ACTIVE RECORDS-------------------------------------------------------------------------------------------
INSERT INTO #ActiveRecord
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
--order by Parent_LoggingId,SearchOrderId

-----------------------------------------------------------------------------FETCH ARCHIVE RECORDS-------------------------------------------------------------------------------------------
INSERT INTO #ActiveRecord
Select  lg.DataXtract_LoggingId,IsNull(Parent_LoggingId,lg.DataXtract_LoggingId) as Parent_LoggingId , LG.SectionKeyId,LG.Section,su.SearchOrderId,  ResponseError, ResponseStatus, DateLogRequest, DateLogResponse, LogUser, ProcessDate, ProcessFlag, Total_Records, Total_Clears, Total_Exceptions,Total_NoChange,Response_RecordCount,
case when 
	J.AIMS_JobStatus ='Z' then 'Zero records in the input'
	when J.AIMS_JobStatus ='Q' then 'Queued'
	when J.AIMS_JobStatus ='C' then 'Completed'
	when j.AIMS_JobStatus = 'A' then 'Active'
	when j.AIMS_JobStatus = 'E' then 'Error' 
else 'NA' end as CurrentStatus
From [Precheck_Archive].dbo.DataXtract_Logging lg (Nolock) left join dbo.AIMS_StatusUpdate su (NoLock) on lg.AIMS_StatusUpdateId = su.AIMS_StatusUpdateId
left join dbo.AIMS_Jobs j (NoLock) on lg.DataXtract_LoggingId = J.DataXtract_LoggingId     
Where LG.Section <> 'Crim' 
and DateLogRequest between @Startdate and DateAdd(d,1,@Enddate)
and LG.SectionKeyID = (Case when len(@SectionKeyID) > 0 then  @SectionKeyID  else LG.SectionKeyID end)

INSERT INTO #ActiveRecord
Select  lg.DataXtract_LoggingId,lg.DataXtract_LoggingId Parent_LoggingId , LG.SectionKeyId,LG.Section,0 SearchOrderId,  ResponseError, ResponseStatus, DateLogRequest, DateLogResponse, LogUser, ProcessDate, ProcessFlag, Total_Records, Total_Clears, Total_Exceptions,0 Total_NoChange,0 Response_RecordCount,
case when 
	J.AIMS_JobStatus ='Z' then 'Zero records in the input'
	when J.AIMS_JobStatus ='Q' then 'Queued'
	when J.AIMS_JobStatus ='C' then 'Completed'
	when j.AIMS_JobStatus = 'A' then 'Active'
	when j.AIMS_JobStatus = 'E' then 'Error' 
else 'NA' end as CurrentStatus
From [Precheck_Archive].dbo.DataXtract_Logging_2016 lg (Nolock) --left join dbo.AIMS_StatusUpdate su (NoLock) on lg.AIMS_StatusUpdateId = su.AIMS_StatusUpdateId
left join dbo.AIMS_Jobs j (NoLock) on lg.DataXtract_LoggingId = J.DataXtract_LoggingId     
Where LG.Section <> 'Crim' 
and DateLogRequest between @Startdate and DateAdd(d,1,@Enddate)
and LG.SectionKeyID = (Case when len(@SectionKeyID) > 0 then  @SectionKeyID  else LG.SectionKeyID end)

INSERT INTO #ActiveRecord
Select  lg.DataXtract_LoggingId,lg.DataXtract_LoggingId Parent_LoggingId , LG.SectionKeyId,LG.Section,0 SearchOrderId,  ResponseError, ResponseStatus, DateLogRequest, DateLogResponse, LogUser, ProcessDate, ProcessFlag, Total_Records, Total_Clears, Total_Exceptions,0 Total_NoChange,0 Response_RecordCount,
case when 
	J.AIMS_JobStatus ='Z' then 'Zero records in the input'
	when J.AIMS_JobStatus ='Q' then 'Queued'
	when J.AIMS_JobStatus ='C' then 'Completed'
	when j.AIMS_JobStatus = 'A' then 'Active'
	when j.AIMS_JobStatus = 'E' then 'Error' 
else 'NA' end as CurrentStatus
From Precheck_Log.dbo.DataXtract_Logging lg (Nolock) --left join dbo.AIMS_StatusUpdate su (NoLock) on lg.AIMS_StatusUpdateId = su.AIMS_StatusUpdateId
left join dbo.AIMS_Jobs j (NoLock) on lg.DataXtract_LoggingId = J.DataXtract_LoggingId     
Where LG.Section <> 'Crim' 
and DateLogRequest between @Startdate and DateAdd(d,1,@Enddate)
and LG.SectionKeyID = (Case when len(@SectionKeyID) > 0 then  @SectionKeyID  else LG.SectionKeyID end)

--temp - added test DB while DBA fixes missing data
----INSERT INTO #ActiveRecord
----Select  lg.DataXtract_LoggingId,IsNull(Parent_LoggingId,lg.DataXtract_LoggingId) as Parent_LoggingId , LG.SectionKeyId,LG.Section,su.SearchOrderId,  ResponseError, ResponseStatus, DateLogRequest, DateLogResponse, LogUser, ProcessDate, ProcessFlag, Total_Records, Total_Clears, Total_Exceptions,Total_NoChange,Response_RecordCount,
----case when 
----	J.AIMS_JobStatus ='Z' then 'Zero records in the input'
----	when J.AIMS_JobStatus ='Q' then 'Queued'
----	when J.AIMS_JobStatus ='C' then 'Completed'
----	when j.AIMS_JobStatus = 'A' then 'Active'
----	when j.AIMS_JobStatus = 'E' then 'Error' 
----else 'NA' end as CurrentStatus
----From [hou-sqltest-01].precheck.dbo.DataXtract_Logging lg (Nolock) left join dbo.AIMS_StatusUpdate su (NoLock) on lg.AIMS_StatusUpdateId = su.AIMS_StatusUpdateId
----left join dbo.AIMS_Jobs j (NoLock) on lg.DataXtract_LoggingId = J.DataXtract_LoggingId     
----Where LG.Section <> 'Crim' 
----and DateLogRequest between @Startdate and DateAdd(d,1,@Enddate) and (@Startdate < '12/31/2016' or @Enddate<'12/31/2016')
----and LG.SectionKeyID = (Case when len(@SectionKeyID) > 0 then  @SectionKeyID  else LG.SectionKeyID end)

-----------------------------------------------------------------------------FETCH BOTH ACTIVE & ARCHIVE RECORDS FROM BOTH TBALE VARIBALES-------------------------------------------------------------------------------------------

select * from #ActiveRecord 
--UNION ALL 
--SELECT * FROM @ArchiveRecordRecord
order by DateLogRequest,SearchOrderId

DROP TABLE #ActiveRecord

 

END


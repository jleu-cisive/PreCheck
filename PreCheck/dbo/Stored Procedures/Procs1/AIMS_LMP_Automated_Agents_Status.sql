
--[AIMS_LMP_Automated_Agents_Status] '04/06/2017'
CREATE PROCEDURE [dbo].[AIMS_LMP_Automated_Agents_Status] 

@RunDate DateTime 

AS


SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

Declare  @EndDate datetime 
--set @StartDate = '3/31/2016'
set @EndDate = Dateadd(d,1,@RunDate)

SELECT    * Into #tempDataXtract_Logging
FROM            DataXtract_Logging
where Section <> 'CRIM'
and DateLogResponse between @RunDate and @EndDate
order by SectionKeyId  


--select * from #tempDataXtract_Logging where SectionKeyId = 'CO-RRT'

--select * from #tempDataXtract_Logging where Request = '<ItemList />'

-- CC/SBM all completed
SELECT    SectionKeyId, Section,  ResponseError, ResponseStatus, DateLogRequest, DateLogResponse, LogUser,  ProcessDate, ProcessFlag, Total_Records, Total_Clears, Total_Exceptions,Total_NoChange, Total_NotFound, Total_BoardAction Into #tempDataXtract_Logging_NoErrors
FROM            #tempDataXtract_Logging
where Section <> 'Nursys' and Request <> '<ItemList />'
and (ResponseStatus   like '%Comp%' or ResponseStatus is null)
AND ResponseError IS NULL
AND Total_Records > 0
order by SectionKeyId  
 -- Nursys Individuals
--SELECT    SectionKeyId, Section,  ResponseError, ResponseStatus, DateLogRequest, DateLogResponse, LogUser,  ProcessDate, ProcessFlag, Total_Records, Total_Clears, Total_Exceptions Into #tempDataXtract_Logging_Nursys
--FROM            #tempDataXtract_Logging
--where Section = 'Nursys' and Request <> '<ItemList />'
--and (ResponseStatus   like '%Comp%' or ResponseStatus is null)
--AND ResponseError IS NULL
--AND Total_Records > 0
--order by SectionKeyId  

SELECT    SectionKeyId, 'Nursys' Section, 'Null' ResponseError,'Completed' ResponseStatus, Max(DateLogRequest) DateLogRequest, Max(DateLogResponse) DateLogResponse, 'Nursys'  LogUser, Max(ProcessDate) ProcessDate, Sum(Total_Records) Total_Records ,Sum(Total_Clears) Total_Clears,Sum(Total_Exceptions) Total_Exceptions
, Sum(Total_NoChange) Total_NoChange, Sum(Total_NotFound) Total_NotFound, Sum(Total_BoardAction) Total_BoardAction Into #tempDataXtract_Logging_NursysGroup
from #tempDataXtract_Logging
where Section = 'Nursys' and Request <> '<ItemList />'
and (ResponseStatus   like '%Comp%' or ResponseStatus is null)
AND ResponseError IS NULL
AND Total_Records > 0
Group by SectionKeyId

---- No data to process
--SELECT   distinct SectionKeyId, Section, ResponseError,'No data available to check aganist the Board.' ResponseStatus,@RunDate  DateLogRequest, @RunDate DateLogResponse, LogUser, ProcessDate, Total_Records, Total_Clears, Total_Exceptions ,Total_NoChange, Total_NotFound, Total_BoardAction into #tempDataXtract_Logging_Nodata
SELECT   distinct SectionKeyId, Section, ResponseError,'No data available to check aganist the Board.' ResponseStatus, DateLogRequest, DateLogResponse, LogUser, ProcessDate, Total_Records, Total_Clears, Total_Exceptions ,Total_NoChange, Total_NotFound, Total_BoardAction into #tempDataXtract_Logging_Nodata
FROM            #tempDataXtract_Logging
where  Request = '<ItemList />'

order by SectionKeyId  


----Zero records processed
SELECT  distinct SectionKeyId, Section, ResponseError, 'No Data to process from Agent' ResponseStatus, DateLogRequest, DateLogResponse, LogUser, ProcessDate, Total_Records, Total_Clears, Total_Exceptions ,Total_NoChange, Total_NotFound, Total_BoardAction Into #tempDataXtract_Logging_ZeroRecords
FROM            #tempDataXtract_Logging
where  Request <> '<ItemList />'
and (ResponseStatus   like '%Comp%' or ResponseStatus is null)
AND ResponseError IS NULL
AND Total_Records = 0
and Processflag =0

order by SectionKeyId  

---- errors
/*
--SELECT  Distinct SectionKeyId, Section, ResponseError, 'Error' ResponseStatus, @RunDate  DateLogRequest, @RunDate DateLogResponse, LogUser, ProcessDate, ProcessFlag, Total_Records, Total_Clears, Total_Exceptions ,Total_NoChange, Total_NotFound, Total_BoardAction Into #tempDataXtract_Logging_Errors
SELECT  Distinct SectionKeyId, Section, ResponseError, 'Error' ResponseStatus,  DateLogRequest, DateLogResponse, LogUser, ProcessDate, ProcessFlag, Total_Records, Total_Clears, Total_Exceptions ,Total_NoChange, Total_NotFound, Total_BoardAction Into #tempDataXtract_Logging_Errors
FROM            #tempDataXtract_Logging
where  Request <> '<ItemList />'
AND ResponseError IS not NULL
and SectionKeyId not in ( Select SectionKeyId  from #tempDataXtract_Logging_NoErrors)
and SectionKeyId not in ( Select SectionKeyId  from #tempDataXtract_Logging_NursysGroup)
order by SectionKeyId  
*/
SELECT  Max(SectionKeyId) SectionKeyId, Max(Section) Section, MAx(ResponseError) ResponseError, 'Error' ResponseStatus, Max(DateLogRequest) DateLogRequest, Max(DateLogResponse) DateLogResponse, max(LogUser) LogUser, Max(ProcessDate) ProcessDate, Sum(Total_Records) Total_Records ,Sum(Total_Clears) Total_Clears,Sum(Total_Exceptions) Total_Exceptions
, Sum(Total_NoChange) Total_NoChange, Sum(Total_NotFound) Total_NotFound, Sum(Total_BoardAction) Total_BoardAction
Into #tempDataXtract_Logging_Errors
FROM            #tempDataXtract_Logging 
where  Request <> '<ItemList />'
AND ResponseError IS not NULL
and SectionKeyId not in ( Select SectionKeyId  from #tempDataXtract_Logging_NoErrors)
and SectionKeyId not in ( Select SectionKeyId  from #tempDataXtract_Logging_NursysGroup)
group by SectionKeyId
order by SectionKeyId  
/*
SELECT   SectionKeyId, Section,ResponseError, ResponseError, ResponseStatus, @RunDate  DateLogRequest, @RunDate DateLogResponse, LogUser, ProcessDate,  Total_Records, Total_Clears, Total_Exceptions,Total_NoChange, Total_NotFound, Total_BoardAction
from
(
Select  SectionKeyId, Section, ResponseError, ResponseStatus, @RunDate  DateLogRequest, @RunDate DateLogResponse, LogUser, ProcessDate, Total_Records, Total_Clears, Total_Exceptions,Total_NoChange, Total_NotFound, Total_BoardAction from #tempDataXtract_Logging_NoErrors
Union all
 Select  SectionKeyId, Section, ResponseError, ResponseStatus, @RunDate  DateLogRequest, @RunDate DateLogResponse, LogUser, ProcessDate,  Total_Records, Total_Clears, Total_Exceptions ,Total_NoChange, Total_NotFound, Total_BoardAction from #tempDataXtract_Logging_NursysGroup
Union all
Select  SectionKeyId, Section, ResponseError, ResponseStatus, @RunDate  DateLogRequest, @RunDate DateLogResponse, LogUser, ProcessDate,  Total_Records, Total_Clears, Total_Exceptions,Total_NoChange, Total_NotFound, Total_BoardAction from #tempDataXtract_Logging_Nodata
Union all
Select  SectionKeyId, Section, ResponseError, ResponseStatus, @RunDate  DateLogRequest, @RunDate DateLogResponse, LogUser, ProcessDate,  Total_Records, Total_Clears, Total_Exceptions,Total_NoChange, Total_NotFound, Total_BoardAction from #tempDataXtract_Logging_ZeroRecords
Union all
Select  SectionKeyId, Section, ResponseError, ResponseStatus, @RunDate  DateLogRequest, @RunDate DateLogResponse, LogUser, ProcessDate,  Total_Records, Total_Clears, Total_Exceptions,Total_NoChange, Total_NotFound, Total_BoardAction from #tempDataXtract_Logging_Errors
*/
SELECT   SectionKeyId, Section,ResponseError, ResponseStatus,  DateLogRequest, DateLogResponse, LogUser, ProcessDate,  Total_Records, Total_Clears, Total_Exceptions,Total_NoChange, Total_NotFound, Total_BoardAction
from
(
Select  SectionKeyId, Section, ResponseError, ResponseStatus,  DateLogRequest, DateLogResponse, LogUser, ProcessDate, Total_Records, Total_Clears, Total_Exceptions,Total_NoChange, Total_NotFound, Total_BoardAction from #tempDataXtract_Logging_NoErrors
Union all
 Select  SectionKeyId, Section, ResponseError, ResponseStatus,   DateLogRequest,  DateLogResponse, LogUser, ProcessDate,  Total_Records, Total_Clears, Total_Exceptions ,Total_NoChange, Total_NotFound, Total_BoardAction from #tempDataXtract_Logging_NursysGroup
Union all
Select  SectionKeyId, Section, ResponseError, ResponseStatus,   DateLogRequest,  DateLogResponse, LogUser, ProcessDate,  Total_Records, Total_Clears, Total_Exceptions,Total_NoChange, Total_NotFound, Total_BoardAction from #tempDataXtract_Logging_Nodata
Union all
Select  SectionKeyId, Section, ResponseError, ResponseStatus,   DateLogRequest,  DateLogResponse, LogUser, ProcessDate,  Total_Records, Total_Clears, Total_Exceptions,Total_NoChange, Total_NotFound, Total_BoardAction from #tempDataXtract_Logging_ZeroRecords
Union all
Select  SectionKeyId, Section, ResponseError, ResponseStatus,   DateLogRequest,  DateLogResponse, LogUser, ProcessDate,  Total_Records, Total_Clears, Total_Exceptions,Total_NoChange, Total_NotFound, Total_BoardAction from #tempDataXtract_Logging_Errors

) a order by SectionKeyId 

drop table #tempDataXtract_Logging
drop table #tempDataXtract_Logging_Nodata
drop table #tempDataXtract_Logging_ZeroRecords
drop table #tempDataXtract_Logging_Errors
drop table #tempDataXtract_Logging_NoErrors
 --Drop table #tempDataXtract_Logging_Nursys
  Drop table #tempDataXtract_Logging_NursysGroup


	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT Off;




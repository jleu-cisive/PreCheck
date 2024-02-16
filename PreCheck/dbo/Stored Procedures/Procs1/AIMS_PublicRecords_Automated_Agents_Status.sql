/****************************************************************************
-- Alter Procedure AIMS_PublicRecords_Automated_Agents_Status

--[dbo].[AIMS_PublicRecords_Automated_Agents_Status_Amy]  '02/15/2021'
--Modified by Amy Liu on 02/22/2021 for HDT84544
*****************************************************************************/
CREATE PROCEDURE [dbo].[AIMS_PublicRecords_Automated_Agents_Status] 

@RunDate DateTime


AS


SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

Declare  @EndDate datetime 
--set @StartDate = '3/31/2016'
set @EndDate = Dateadd(d,1,@RunDate)

SELECT    c.County as County,l.SectionKeyId,l.Section,l.Request,l.ResponseError,l.ResponseStatus,l.DateLogRequest,l.DateLogResponse,l.LogUser,
cast(Request as xml).value('(count(//Item))[1]','int') Total_Request_Items,
cast(replace(Response,'&','') as xml).value('(count(//Item))[1]','int') Total_Response_Items,
l.Total_Records,l.Total_Clears,l.Total_Exceptions Into #tempDataXtract_Logging
FROM            DataXtract_Logging l  inner join dbo.TblCounties c on l.SectionKeyID = cast(c.CNTY_NO as varchar(10))
where 
Section = 'CRIM'
and 
DateLogResponse between @RunDate and @EndDate
order by SectionKeyId  


-- CRIM all completed
SELECT    County,SectionKeyId, Section,  ResponseError, ResponseStatus, DateLogRequest, DateLogResponse, LogUser,Total_Request_Items,Total_Response_Items, Total_Records, Total_Clears, Total_Exceptions Into #tempDataXtract_Logging_NoErrors
FROM            #tempDataXtract_Logging
where  Request <> '<ItemList />'
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



---- No data to process
SELECT   distinct County,SectionKeyId, Section, ResponseError,'No data available to check aganist the Board.' ResponseStatus,@RunDate  DateLogRequest, @RunDate DateLogResponse, LogUser, Total_Request_Items,Total_Response_Items,Total_Records, Total_Clears, Total_Exceptions into #tempDataXtract_Logging_Nodata
FROM            #tempDataXtract_Logging
where  Request = '<ItemList />'
order by SectionKeyId  


----Zero records processed
SELECT  distinct County,SectionKeyId, Section, ResponseError, 'No Data to process from Agent' ResponseStatus, DateLogRequest, DateLogResponse, LogUser, Total_Request_Items,Total_Response_Items, Total_Records, Total_Clears, Total_Exceptions Into #tempDataXtract_Logging_ZeroRecords
FROM            #tempDataXtract_Logging
where  Request <> '<ItemList />'
and (ResponseStatus   like '%Comp%' or ResponseStatus is null)
AND ResponseError IS NULL
AND Total_Records = 0
order by SectionKeyId  

---- errors
SELECT  Distinct County,SectionKeyId,Section, ResponseError, 'Error' ResponseStatus, @RunDate  DateLogRequest, @RunDate DateLogResponse, LogUser,Total_Request_Items,Total_Response_Items, Total_Records, Total_Clears, Total_Exceptions Into #tempDataXtract_Logging_Errors
FROM            #tempDataXtract_Logging
where  Request <> '<ItemList />'
AND ResponseError IS not NULL
and SectionKeyId not in ( Select SectionKeyId  from #tempDataXtract_Logging_NoErrors)
--and SectionKeyId not in ( Select SectionKeyId  from #tempDataXtract_Logging_NursysGroup)
order by SectionKeyId  

SELECT distinct  County, Section, ResponseError, ResponseStatus,  DateLogRequest, DateLogResponse, LogUser,  Total_Request_Items,Total_Response_Items, Total_Records, Total_Clears, Total_Exceptions
from
(
Select  County,SectionKeyId, Section, ResponseError, ResponseStatus,  DateLogRequest, DateLogResponse, LogUser, Total_Request_Items,Total_Response_Items, Total_Records, Total_Clears, Total_Exceptions from #tempDataXtract_Logging_NoErrors
Union all
Select  County,SectionKeyId, Section, ResponseError, ResponseStatus,  DateLogRequest, DateLogResponse, LogUser, Total_Request_Items,Total_Response_Items,  Total_Records, Total_Clears, Total_Exceptions from #tempDataXtract_Logging_Nodata
Union all
Select  County,SectionKeyId, Section, ResponseError, ResponseStatus,  DateLogRequest, DateLogResponse, LogUser,  Total_Request_Items,Total_Response_Items, Total_Records, Total_Clears, Total_Exceptions from #tempDataXtract_Logging_ZeroRecords
Union all
Select  County,SectionKeyId, Section, ResponseError, ResponseStatus,  DateLogRequest, DateLogResponse, LogUser, Total_Request_Items,Total_Response_Items,  Total_Records, Total_Clears, Total_Exceptions from #tempDataXtract_Logging_Errors


) a order by County 

drop table #tempDataXtract_Logging
drop table #tempDataXtract_Logging_Nodata
drop table #tempDataXtract_Logging_ZeroRecords
drop table #tempDataXtract_Logging_Errors
drop table #tempDataXtract_Logging_NoErrors


	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT Off;

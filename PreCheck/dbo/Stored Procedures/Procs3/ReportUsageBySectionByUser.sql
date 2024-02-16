



CREATE PROCEDURE [dbo].[ReportUsageBySectionByUser] @StartDate datetime, @EndDate datetime AS

--SELECT t.UserID, TableName, Convert(varchar(20),dbo.SecondsToTime(avg(datediff(s,TimeOpen,TimeClose))),8) Time FROM SectionUsage t
  --WHERE   TimeClose is not null and TimeOpen is not null and TimeOpen >= @StartDate and TimeOpen < @EndDate
--GROUP BY TableName, UserID

select UserID
     , TableName
     , count( distinct tableid) as Count, Convert(varchar(20), (dbo.SecondsToTime(sum(datediff(s,TimeOpen,TimeClose))/count( distinct tableid))), 8) as AvgTime
     , Convert(varchar(20),dbo.SecondsToTime(sum(datediff(s,TimeOpen,TimeClose))),8) as SumTime
from sectionusage 
WHERE TimeClose is not null 
  and TimeOpen is not null 
  and TimeOpen >= @StartDate 
  and TimeOpen < @EndDate 
group by userid
       , tablename
order by userid
        ,TableName


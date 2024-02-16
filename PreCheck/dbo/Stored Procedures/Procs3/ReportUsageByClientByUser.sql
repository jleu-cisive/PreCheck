


CREATE PROCEDURE [dbo].[ReportUsageByClientByUser] @StartDate datetime, @EndDate datetime AS

--SELECT t.UserID, a.CLNO, Convert(varchar(20),dbo.SecondsToTime(avg(datediff(s,TimeOpen,TimeClose))),8) Time FROM SectionUsage t
 --JOIN precheck.dbo.Appl a ON a.apno=t.TableID
 --JOIN precheck.dbo.CLient c ON c.clno=a.clno
  --WHERE TableName = 'Appl' and  TimeClose is not null and TimeOpen is not null --and TimeOpen >= @StartDate and TimeOpen < @EndDate
--GROUP BY a.CLNO, c.Name, t.UserID





SELECT t.UserID
     , a.CLNO
     , c.Name
     , count( distinct tableid) as Count, Convert(varchar(20)
     , (dbo.SecondsToTime(sum(datediff(s,TimeOpen,TimeClose))/count( distinct tableid))), 8) as AvgTime
     , Convert(varchar(20),dbo.SecondsToTime(sum(datediff(s,TimeOpen,TimeClose))),8) as SumTime  
FROM SectionUsage t
     JOIN precheck.dbo.Appl a ON a.apno=t.APNO
     JOIN precheck.dbo.CLient c ON c.clno=a.clno
WHERE TableName = 'Appl' 
      and  TimeClose is not null 
      and TimeOpen is not null 
      and TimeOpen >= @StartDate 
      and TimeOpen < @EndDate
GROUP BY a.CLNO
       , c.Name
       , t.UserID 
order by t.userid





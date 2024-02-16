


Create PROCEDURE [dbo].[ReportUsageBySectionByClient] @StartDate datetime, @EndDate datetime AS


--SELECT a.CLNO, c.Name, Convert(varchar(20), (dbo.SecondsToTime(sum(datediff(s,TimeOpen,TimeClose))/count(a.CLNO))), 8) as AvgTime,
--Convert(varchar(20),dbo.SecondsToTime(sum(datediff(s,TimeOpen,TimeClose))),8) 
--as SumTime  FROM SectionUsage t
  --JOIN precheck.dbo.Appl a ON a.apno=t.TableID
  --JOIN precheck.dbo.CLient c ON c.clno=a.clno
  --WHERE TimeClose is not null and TimeOpen is not null and TimeOpen >= @StartDate and TimeOpen < @EndDate
--GROUP BY a.CLNO, c.Name order by a.CLNO



SELECT CLNO
    , NAME
	, Convert(varchar(20), (dbo.SecondsToTime(SUM(NumOfSecond) / COUNT(APNO))),8) AS AvgTime
    , Convert(varchar(20), (dbo.SecondsToTime(SUM(NumOfSecond))),8) AS SumTime
FROM
(
	SELECT A.CLNO, C.NAME, SU.APNO
		, (SELECT SUM(DATEDIFF(s, TimeOpen, TimeClose)) FROM dbo.SectionUsage WHERE APNO = SU.APNO) AS NumOfSecond
	FROM dbo.SectionUsage SU
		INNER JOIN dbo.Appl A ON A.APNO = SU.APNO
        INNER JOIN dbo.CLIENT C ON A.CLNO = C.CLNO
    WHERE TimeClose is not null 
      and TimeOpen is not null 
      and TimeOpen >= @StartDate 
      and TimeOpen < @EndDate
   	GROUP BY A.CLNO, C.NAME, SU.APNO
) T1
GROUP BY CLNO, NAME
ORDER BY CLNO

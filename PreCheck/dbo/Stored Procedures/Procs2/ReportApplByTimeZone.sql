

CREATE PROCEDURE dbo.ReportApplByTimeZone 
@FromDate datetime,
@ToDate datetime
AS

SELECT  TimeZoneName, count(a.apno) as AppCount, 
100*count(a.apno)/
 (SELECT Count(*) FROM APPL 
	JOIN Client ON CLient.clno=Appl.clno 
	JOIN refBillingStatus ON client.BillingStatusID=refBillingStatus.BillingStatusID
	Where billingstatus='active' and nonClient=0 and apdate >= @FromDate and apdate < @ToDate) as AppPercent
  FROM CLient c
Join refBillingStatus s ON c.BillingStatusID=s.BillingStatusID
left JOIN  ZipCodeWorld2 z ON SUBSTRING(c.zip,1,5) = z.zip_code
JOIN ZipCodeWorldZones zz ON zz.Time_Zone = z.Time_Zone
JOIN Appl a ON a.clno=c.clno
Where billingstatus='active' and nonClient=0 --and zip is not null 
  and apdate >= @FromDate and apdate < @ToDate
group by  TimeZoneName, z.time_zone
order by Convert(int, z.time_zone)



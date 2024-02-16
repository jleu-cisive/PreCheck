CREATE PROCEDURE ReportApplCompletedForMDAnderson 
@StartDate datetime,  --default should be the next Monday
@EndDate datetime   --default should be the Monday after @StartDate
AS


--ElapsedBusinesDays_2() is corrected and doesn't need -1
-- change back to ElapsedBusinesDays() (without -1) when it is corrected
SELECT StartDate, ApStatus, Last, First, SSN, Attn, APNO, ClientAPNO, Apdate, CompDate, dbo.elapsedbusinessdays_2((select apdate from Appl where apno=a.apno),(select compdate from Appl where apno=a.apno))  Days
FROM Appl a
Where StartDate >= @StartDate and StartDate < @EndDate and clno=2167
order by   CompDate
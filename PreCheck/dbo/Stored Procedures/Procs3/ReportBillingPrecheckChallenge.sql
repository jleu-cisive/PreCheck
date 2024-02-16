

CREATE PROCEDURE dbo.ReportBillingPrecheckChallenge
@StartDate datetime,
@EndDate datetime
AS

SELECT  c.name, a.CLNO, a.apno, a.apstatus, a.UserID, --a.Apdate, a.Compdate, a.attn
        convert(varchar(10),a.Apdate,101) ApDate, convert(varchar(10),a.Compdate,101) CompDate,a.attn
  FROM  Appl a join client c on c.clno=a.clno
 WHERE  (PrecheckChallenge = 1) AND CompDate >= @StartDate AND CompDate < @EndDate
order by c.name



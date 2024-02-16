

CREATE PROCEDURE dbo.ReportBillingNoPackage 
@StartDate datetime
AS
SELECT     a.clno, c.name, count(a.clno) as Cnt
FROM   appl a
join client c on a.clno=c.clno
WHERE 
not exists (SELECT * FROM ClientPackages  WHERE ClientPackages.CLNO = c.CLNO)
AND (a.compDate >= @StartDate or a.Apstatus <> 'F')
and BillingStatusID = 1  --Only check active accounts
AND a.apDate < '1/1/2099' --last date needed for 2099 date (Y2K problem)
group by a.clno, c.name
order by c.name


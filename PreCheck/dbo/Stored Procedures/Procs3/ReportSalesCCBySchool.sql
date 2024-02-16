CREATE PROCEDURE [dbo].[ReportSalesCCBySchool] 
@StartDate datetime,
@EndDate datetime
AS
-- needs to be rewritten to pull UserIDs out of the Users table
SELECT c.Clno, c.name Client, count(*) Count, sum(TransAmount) TransAmount 
  FROM HEVN.DBO.Precheck_CCTransactionLog l
  JOIN precheck.dbo.Appl a on a.apno=l.AppNumber
  JOIN precheck.dbo.Client c on c.clno=a.clno
  WHERE TransResponseDesc in ('Approved','INVALID Billing ZipCode') and TransUserIP in ('rdurham','mrose','rbrown')
	and transdate >= @StartDate and transdate < @EndDate
GROUP BY c.clno, c.name
ORDER BY c.name

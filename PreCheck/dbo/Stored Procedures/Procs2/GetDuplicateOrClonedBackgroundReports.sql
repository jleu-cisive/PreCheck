
CREATE PROCEDURE [dbo].[GetDuplicateOrClonedBackgroundReports] --'10/20/2015', '10/22/2015'

@StartDate DateTime = '09/21/2015', 
@EndDate DateTime = '09/21/2015'

AS

select c.CLNO as ClientNumber,a.Apno as [Original ReportNumber],c.Name as ClientName,a.[First] as [Applicant FirstName],a.[Last] as [Applicant LastName],c.CAM as [CAM Name],a.EnteredBy as [Data Entry Investigator],a.Priv_Notes,a.EnteredVia, a.ApDate as [Original Report Date],a.Last_Updated as [Original Close Date] from Appl a inner join client c on a.CLNO = c.CLNO
where (a.ApDate between @StartDate and @EndDate) and (Priv_Notes like'%Duplicate' or Priv_Notes like'%clone%')

--Created on 01-06-2006 get new report 

Create Proc dbo.Adverse_GetNewReport
@apno int
As
Declare @ErrorCode int

select BackgroundReport 
from BackgroundReports.dbo.BackgroundReport 
where BackgroundReportID=(select max(backgroundreportid) from BackgroundReports.dbo.BackgroundReport where apno=@apno)
  




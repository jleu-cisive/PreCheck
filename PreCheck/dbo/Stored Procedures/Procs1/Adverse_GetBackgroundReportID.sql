


--Created on 01-10-2006 get BackgroundReportID 

Create Proc dbo.Adverse_GetBackgroundReportID
@apno int
As
Declare @ErrorCode int

select BackgroundReportID 
from BackgroundReports.dbo.BackgroundReport 
where BackgroundReportID=(select max(backgroundreportid) from BackgroundReports.dbo.BackgroundReport where apno=@apno)
  




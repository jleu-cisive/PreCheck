

CREATE Proc dbo.Adverse_GetFistPrintedReportID
@apno int
As

select ReportID  
from AdverseActionHistory 
where date=(select max(Date) from AdverseaCtionHistory h 
		inner join AdverseAction a on h.AdverseActionID=a.AdverseActionID
		where a.apno=@apno
		and h.AdverseChangeTypeID=1
		and h.StatusID=4
	    )
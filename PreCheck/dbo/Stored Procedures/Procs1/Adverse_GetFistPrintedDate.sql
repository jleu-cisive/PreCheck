

CREATE Proc dbo.Adverse_GetFistPrintedDate
@apno int
As

select min(date)FirstPrintedDate 
from AdverseActionHistory h inner join AdverseAction a on h.AdverseActionID=a.AdverseActionID 
where  h.AdverseChangeTypeID=1
and a.apno=@apno
and h.StatusID=4
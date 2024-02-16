--dbo.AIMS_FindCrimRecordByApno 2480,3614426,'05/01/2017','05/10/2017'

CREATE procedure dbo.AIMS_FindCrimRecordByApno(@countyid int,@apno int,@datefrom datetime,@dateto datetime)
as
select 
	DataXtract_LoggingId as Id,Cast(Request as xml) as Input,Cast(Response as xml) as Output,DateLogRequest as RequestDate,DateLogResponse as ResponseDate 
from 
	dbo.DataXtract_Logging lg (nolock)
where 
	charindex(cast(@apno as varchar(20)),Request) > 0 and 
	DateLogRequest between @datefrom and @dateto and
	Section='Crim' and 
	SectionKeyID = @countyid 
 order by 1 desc

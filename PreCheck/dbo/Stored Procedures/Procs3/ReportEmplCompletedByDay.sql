
CREATE PROCEDURE [dbo].[ReportEmplCompletedByDay] 
@Date datetime

AS

select EnteredBy, count(*) as Count 
from empl (NOLOCK) 
where enteredby is not null and entereddate=@Date and IsOnReport = 1
group by EnteredBy
order by EnteredBy



set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON


CREATE PROCEDURE [dbo].[license_summary] @StartDate varchar(10),
	@EndDate varchar(10) as 
select count( p.lic_type) as Total_requested ,p.lic_type,p.state 
from proflic p, appl a
where (a.apdate BETWEEN CONVERT(DATETIME, @startdate, 102) AND CONVERT(DATETIME, @enddate, 102)) and
(p.apno = a.apno) and p.state is not null and p.sectstat <> 0 AND (A.ApStatus <> 'M') AND p.IsOnReport = 1
group by p.lic_type ,p.state
order by p.state asc , p.lic_type asc


set ANSI_NULLS OFF
set QUOTED_IDENTIFIER OFF

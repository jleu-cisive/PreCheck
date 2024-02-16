CREATE PROCEDURE Iris_Researcher_Avg_Update AS


-- Updates the Calculated Average turnaround per researcher
-- 12/13/2004 - js


Declare @Last30Day DateTime

Set @Last30Day = (Select Dateadd(Day,-30,getdate()))


truncate table Iris_Researcher_Avg_Turnaround


insert into Iris_Researcher_Avg_Turnaround(r_id,averageturnaround,insertdate)
select r_id,
(SELECT avg(CONVERT(numeric(7,2), 
dbo.ElapsedBusinesshours(c.ordered,c.last_updated))) 
as average
FROM    Crim c with(nolock) where (dbo.Fix_Crim_Ordered_Date(ordered) 
between @last30Day and getdate())
and c.vendorid =  iris_researchers.r_id) as AverageTurnAround,getdate() as InsertDate
from iris_researchers with(nolock) where
r_active = 'yes'
order by r_id
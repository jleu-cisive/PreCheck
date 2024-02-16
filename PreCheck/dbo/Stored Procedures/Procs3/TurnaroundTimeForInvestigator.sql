

--TurnaroundTimeForInvestigator 'PJARMON','01/1/2011','01/31/2011'

CREATE PROCEDURE dbo.TurnaroundTimeForInvestigator
(
@Investigator varchar(8) = '',
  @StartDate datetime,
  @EndDate datetime
  
)
as
Select 
A.Investigator,count(*) as Total,
--(cast((round(sum(case when A.turnaround = 0 then 1 else 0 end)/cast(count(*) as decimal),4)*100)as decimal(10,4))) as day,

(cast((round(sum(case when A.turnaround = 0 then 1 else 0
        end)/cast(count(*) as decimal),4)*100)as decimal(10,4))) as day0,
sum(case when A.turnaround = 0 then 1 else 0
        end) as count0,
(cast((round(sum(case when A.turnaround = 1 then 1 else 0
        end)/cast(count(*) as decimal),4)*100)as decimal(10,4))) as day1,
sum(case when A.turnaround = 1 then 1 else 0
        end) as count1,
(cast((round(sum(case when A.turnaround = 2 then 1 else 0
        end)/cast(count(*) as decimal),4)*100)as decimal(10,4))) as day2,
sum(case when A.turnaround = 2 then 1 else 0
        end) as count2,
(cast((round(sum(case when A.turnaround = 3 then 1 else 0
        end)/cast(count(*) as decimal),4)*100)as decimal(10,4))) as day3,
sum(case when A.turnaround = 3 then 1 else 0
        end) as count3,
(cast((round(sum(case when A.turnaround = 4 then 1 else 0
        end)/cast(count(*) as decimal),4)*100)as decimal(10,4))) as day4,
sum(case when A.turnaround = 4 then 1 else 0
        end) as count4,
(cast((round(sum(case when A.turnaround = 5 then 1 else 0
        end)/cast(count(*) as decimal),4)*100 )as decimal(10,4)))as day5,
sum(case when A.turnaround = 5 then 1 else 0
        end) as count5,
(cast((round(sum(case when A.turnaround = 6 then 1 else 0
        end)/cast(count(*) as decimal),4)*100)as decimal(10,4))) as [day6+],
sum(case when A.turnaround = 6 then 1 else 0
        end) as [count6+]
from
(select Appl.Investigator, 
        case when ( dbo.elapsedbusinessdays_2( Appl.Apdate, Appl.Origcompdate ) + dbo.elapsedbusinessdays_2( Appl.Reopendate, Appl.Compdate ) ) < 6 then ( dbo.elapsedbusinessdays_2( Appl.Apdate, Appl.Origcompdate ) + dbo.elapsedbusinessdays_2( Appl.Reopendate, Appl.Compdate ) )
        else 6 end as turnaround
   from Appl with (nolock)
  where Apdate >= @StartDate 
   and Apdate < @EndDate 
   and (@Investigator = '' or @Investigator = null or Investigator = @Investigator)
and Investigator is not null
   and apstatus in ('W','F')
)A
group by A.Investigator 
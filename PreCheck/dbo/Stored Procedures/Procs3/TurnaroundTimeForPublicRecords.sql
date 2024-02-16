/*
Modified by Sahithi Gangaraju 12/9/2020 for HDT :76685
*/
CREATE PROCEDURE [dbo].[TurnaroundTimeForPublicRecords]
(
  @StartDate datetime,
  @EndDate datetime
)
as
DECLARE @CrimTable TABLE 
( 
   turnaround int 
) 

insert into @CrimTable (turnaround)
select case when dbo.elapsedbusinessdays_2( convert(datetime,Crim.crimenteredtime), Crim.last_updated ) < 50 then dbo.elapsedbusinessdays_2( convert(datetime,Crim.crimenteredtime), Crim.last_updated ) 
       else 50 end as turnaround 
  from Crim with (nolock)
  inner join Appl(nolock)on Appl.Apno = Crim.Apno
 where Crim.crimenteredtime >= @StartDate 
   and Crim.last_updated < @EndDate
   and Crim.Clear in ('T','F','P')
   AND crim.IsHidden = 0

--select * from @CrimTable

DECLARE @CrimTableSum TABLE 
( 
    turnaround int, 
    total int,
    percentage decimal(16,4),
    grandtotal int
) 

insert into @CrimTableSum ( turnaround, total, percentage, grandtotal)

select 
        case when grouping(turnaround) = 1 then 50
        else turnaround end as turnaround,
        sum(count(*)) over(partition by turnaround ) as total,
        sum(count(*)) over(partition by turnaround)*2/ cast(sum(count(*)) over()as decimal) as percentage,
        sum(count(*)) over()/2 as grandtotal
   from @CrimTable
 group by turnaround
 with cube


--select * from @CrimTableSum

Select 
case when A.total/cast(A.grandtotal as decimal) = 1 then 'Total'
    else 
      case when A.turnaround = 50 then  cast(A.turnaround as varchar(8)) 
           else cast(A.turnaround as varchar(8))
      end 
end as Days,
A.total as [Count],
(cast(((A.total/cast(A.grandtotal as decimal))*100)as decimal(16,4))) as Percentage,
(cast(((A.total/cast(A.grandtotal as decimal) + COALESCE((SELECT SUM(B.total/cast(B.grandtotal as decimal)) 
                      FROM
                      @CrimTableSum B WHERE B.turnaround < A.turnaround and A.turnaround <> 7),0))*100)as decimal(16,4))) AS [Cumulative Percentage],
					  0 as apno, null as 'county', 0 as CountyNumber ,null as 'Crim Created Date',null as 'Crim Created Date', null as 'Crim Last Verified'-- added for hdt :76685
from
@CrimTableSum A
group by A.turnaround, A.total, A.grandtotal 
-- below added for hdt :76685
union all

select CAST(( dbo.elapsedbusinessdays_2(Apdate, c.Last_Updated)) AS NVARCHAR(100)) as [Days],
0 as [Count],
0 as [Percentage], 
0 as [Cumulative Percentage],appl.apno,c.County as 'County', c.cnty_no as 'CountyNumber',c.CreatedDate as 'Crim Created Date', c.CreatedDate as 'Crim Created Date',c.Last_Updated as 'Crim Last Verified'

from appl with (nolock) 
inner join Crim c on Appl.apno = c.apno
where c.Last_Updated >= @StartDate and c.Last_Updated < @EndDate and ApStatus not in ('9')
group by appl.apno, apdate,c.Last_Updated,LastModifiedDate,c.CreatedDate, c.County,c.CNTY_NO


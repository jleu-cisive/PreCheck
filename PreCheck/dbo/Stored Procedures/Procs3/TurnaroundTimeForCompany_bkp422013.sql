create PROCEDURE [dbo].[TurnaroundTimeForCompany_bkp422013]
(
  @StartDate datetime,
  @EndDate datetime
)
as

DECLARE @TempTable TABLE 
( 
    turnaround int 
) 

insert into @TempTable (turnaround)
select case when dbo.elapsedbusinessdays_2( Appl.Apdate, Appl.Origcompdate ) 
               + dbo.elapsedbusinessdays_2( Appl.Reopendate, Appl.Compdate )  < 6 
           then  dbo.elapsedbusinessdays_2( Appl.Apdate, Appl.Origcompdate ) 
               + dbo.elapsedbusinessdays_2( Appl.Reopendate, Appl.Compdate )                    
           else 6 end as turnaround
   from Appl with (nolock)
  where Apdate >= @StartDate
   and Apdate < @EndDate 
   and apstatus in ('W','F')

DECLARE @TempTableSum TABLE 
( 
    turnaround int, 
    total int,
    percentage decimal(16,2),
    grandtotal int
) 

insert into @TempTableSum (turnaround, total, percentage, grandtotal)

select  case when grouping(turnaround) = 1 then 7
        else turnaround end as turnaround,
        sum(count(*)) over(partition by turnaround ) as total,
        sum(count(*)) over(partition by turnaround)*2/ cast(sum(count(*)) over()as decimal) as percentage,
        sum(count(*)) over()/2 as grandtotal
   from @TempTable
 group by turnaround
   with cube

Select 
case when A.total/cast(A.grandtotal as decimal) = 1 then ''
    else 
      case when A.turnaround = 6 then  cast(A.turnaround as varchar(8)) + '+ days' 
           else cast(A.turnaround as varchar(8)) + ' days' 
      end 
end as Days,
A.total as [Count],
(cast(((A.total/cast(A.grandtotal as decimal))*100)as decimal(16,2))) as Percentage,
(cast(((A.total/cast(A.grandtotal as decimal) + COALESCE((SELECT SUM(B.total/cast(B.grandtotal as decimal)) 
                      FROM
                      @TempTableSum B WHERE B.turnaround < A.turnaround and A.turnaround <> 7),0))*100)as decimal(16,2))) AS [Cumulative Percentage]
from
@TempTableSum A
group by A.turnaround, A.total, A.grandtotal 


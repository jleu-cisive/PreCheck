CREATE PROCEDURE [dbo].[EmploymentVerification_Test]
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
select dbo.elapsedbusinessdays_2(A.Apdate, GETDATE() ) as turnaround 
  from Empl E with (nolock)
  inner join Appl A
    on E.Apno = A.Apno
 where A.Apdate >= @StartDate 
   and A.Apdate < @EndDate
   and E.Investigator <> 'RefPro'
   and E.Web_Status = 0
   and E.isHidden = 0
   and E.SectStat in ('0','9')


DECLARE @EmplTableSum TABLE 
( 
    turnaround int, 
    total int,
	grandtotal int
) 

insert into @EmplTableSum ( turnaround, total, grandtotal)

select 
        case when grouping(turnaround) = 1 then 7
        else turnaround end as turnaround,
        sum(count(*)) over(partition by turnaround ) as total,
		sum(count(*)) over()/2 as grandtotal   
   from @TempTable
 group by turnaround
 with cube


Select 
case when A.total/cast(A.grandtotal as decimal) = 1 then ''
    else 
      case when A.turnaround > 7 then  cast(A.turnaround as varchar(8)) + '+'
           else cast(A.turnaround as varchar(8))  
      end 
end as Days,
A.total as [Count]
FROM
@EmplTableSum A
group by A.turnaround, A.total, A.grandTotal
CREATE PROCEDURE [dbo].[TurnaroundTimeForCompany]
(
  @StartDate datetime,
  @EndDate datetime
)
as

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
DECLARE @TempTable TABLE 
( 
    turnaround int 
) 

insert into @TempTable (turnaround)
select dbo.elapsedbusinessdays_2( Appl.Apdate, Appl.Origcompdate ) 
               + dbo.elapsedbusinessdays_2( Appl.Reopendate, Appl.Compdate )  
   from Appl with (nolock)
  where Apdate >= @StartDate
   and Apdate < @EndDate 
   and apstatus in ('W','F')
   and clno NOT IN (2135, 3468)


DECLARE @TempTableSum TABLE 
( 
    turnaround int, 
    total int,
    percentage decimal(16,2),
    grandtotal int
) 

insert into @TempTableSum (turnaround, total, percentage, grandtotal)

select  case when grouping(turnaround) = 1 then max(turnaround) + 1
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
          cast(A.turnaround as varchar(8)) --+ ' days' --radhika on 03/11/2014 as asked by Dana
       
end as Days,
A.total as [Count],
(cast(((A.total/cast(A.grandtotal as decimal))*100)as decimal(16,2))) as Percentage,
(cast(((A.total/cast(A.grandtotal as decimal) + COALESCE((SELECT SUM(B.total/cast(B.grandtotal as decimal)) 
                      FROM
                      @TempTableSum B WHERE B.turnaround < A.turnaround and A.turnaround <= max(TA.turnaround)),0))*100)as decimal(16,2))) AS [Cumulative Percentage],
0 as apno, 0 as CLNO,  null as 'App Created Date', null as 'Original Closed Date'
from
@TempTableSum A, @TempTable TA
group by A.turnaround, A.total, A.grandtotal 


--Added by Radhika Dereddy on 04/02/2015 as per Dana's Request
union all

select (  dbo.elapsedbusinessdays_2( Appl.Apdate, Appl.Origcompdate ) 
               + dbo.elapsedbusinessdays_2( Appl.Reopendate, Appl.Compdate )  ) as Days,
0 as totalcount,
0 as percentage, 
0 as [Cumulative Percentage],
apno, CLNO, apdate as 'App Created Date', origcompdate as 'Original Closed Date'
from appl with (nolock) where Apdate >= @StartDate and Apdate < @EndDate and (CLNO not in (2135, 3468)) 
and apstatus in ('W','F')





END

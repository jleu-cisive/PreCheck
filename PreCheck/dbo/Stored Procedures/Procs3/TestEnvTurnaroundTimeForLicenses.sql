CREATE PROCEDURE [dbo].[TestEnvTurnaroundTimeForLicenses]  --'04/01/2015','04/23/2015'
(
  @StartDate datetime,
  @EndDate datetime
)
as
DECLARE @LicenseTable TABLE 
( 
   turnaround int 
) 

insert into @LicenseTable (turnaround)
select case when dbo.elapsedbusinessdays_2( convert(datetime,pl.CreatedDate), pl.Last_updated) < 6 then dbo.elapsedbusinessdays_2( convert(datetime,pl.CreatedDate), pl.Last_updated) 
       else 6 end as turnaround 
  from [Hou-SQLTEST-01].PreCheck.dbo.ProfLic pl with (nolock)
  join [Hou-SQLTEST-01].PreCheck.dbo.Appl as a with (nolock) on a.Apno = pl.Apno
 where pl.CreatedDate >= @StartDate 
   and pl.Last_updated < @EndDate
   and pl.SectStat not in ('9')

--select * from @LicenseTable

DECLARE @LicenseTableSum TABLE 
( 
    turnaround int, 
    total int,
    percentage decimal(16,4),
    grandtotal int
) 

insert into @LicenseTableSum ( turnaround, total, percentage, grandtotal)

select 
        case when grouping(turnaround) = 1 then 7
        else turnaround end as turnaround,
        sum(count(*)) over(partition by turnaround ) as total,
        sum(count(*)) over(partition by turnaround)*2/ cast(sum(count(*)) over()as decimal) as percentage,
        sum(count(*)) over()/2 as grandtotal
   from @LicenseTable
 group by turnaround
 with cube


--select * from @LicenseTableSum

Select 
case when A.total/cast(A.grandtotal as decimal) = 1 then ''--'Total'
    else 
      case when A.turnaround = 6 then  cast(A.turnaround as varchar(8)) --+ '+ days' 
           else cast(A.turnaround as varchar(8)) --+ ' days' 
      end 
end as Days,
A.total as [Count],
(cast(((A.total/cast(A.grandtotal as decimal))*100)as decimal(16,4))) as Percentage,
(cast(((A.total/cast(A.grandtotal as decimal) + COALESCE((SELECT SUM(B.total/cast(B.grandtotal as decimal)) 
                      FROM
                      @LicenseTableSum B WHERE B.turnaround < A.turnaround and A.turnaround <> 7),0))*100)as decimal(16,4))) AS [Cumulative Percentage]
,0 as apno, null as 'App Created Date', null as 'License Type', null as LicenseCompletedDate
from
@LicenseTableSum A
group by A.turnaround, A.total, A.grandtotal 

union all

select ( dbo.elapsedbusinessdays_2(Apdate, pl.Last_updated)) as Days,
0 as totalcount,
0 as percentage, 
0 as [Cumulative Percentage]
,a.apno, apdate as 'App Created Date',pl.Lic_Type as LicenseType,pl.Last_updated as LicenseCompletedDate
from [Hou-SQLTEST-01].PreCheck.dbo.Appl AS a with (nolock) 
inner join [Hou-SQLTEST-01].PreCheck.dbo.ProfLic pl with (nolock) on a.apno = pl.apno
where Apdate >= @StartDate and pl.Last_updated < @EndDate and pl.SectStat not in ('9')
group by a.apno, apdate,pl.Lic_Type,pl.Last_updated

--select ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) as Days,
--0 as totalcount,
--0 as percentage, 
--0 as [Cumulative Percentage],
--apno, apdate as 'App Created Date', origcompdate as 'Original Closed Date'
--from [Hou-SQLTEST-01].PreCheck.dbo.Appl with (nolock) where Apdate >= @StartDate and Apdate < @EndDate and apstatus in ('W','F')

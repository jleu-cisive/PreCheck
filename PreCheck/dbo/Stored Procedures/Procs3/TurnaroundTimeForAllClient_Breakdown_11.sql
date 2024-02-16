
--[[TurnaroundTimeForAllClient_Breakdown_11]] '1/1/2012','1/30/2012'
CREATE PROCEDURE [dbo].[TurnaroundTimeForAllClient_Breakdown_11]
(
  @StartDate datetime,
  @EndDate datetime
)
as
DECLARE @EmplTable TABLE 
( 
    section varchar(10), 
    turnaround int 
) 

insert into @EmplTable (section, turnaround)
select 'Empl' as section,
 case when dbo.elapsedbusinessdays_2( Empl.createddate, Empl.last_worked ) < 11 then dbo.elapsedbusinessdays_2( Empl.createddate, Empl.last_worked ) 
        else 11 end as turnaround 
  from Empl with (nolock) 
  join Appl 
    on Appl.Apno = Empl.Apno
 where Empl.createddate >= @StartDate
   and Empl.last_worked < @EndDate
   and Empl.SectStat in ('2','3','4','5','6','7','8','A')

DECLARE @EmplTableSum TABLE 
( 
    section varchar(10), 
    turnaround int, 
    total int,
    percentage decimal(16,4),
    grandtotal int
) 

insert into @EmplTableSum (section, turnaround, total, percentage, grandtotal)

select 'Empl' as section, 
        case when grouping(turnaround) = 1 then 11
        else turnaround end as turnaround,
        sum(count(*)) over(partition by turnaround ) as total,
        sum(count(*)) over(partition by turnaround)*2/ cast(sum(count(*)) over()as decimal) as percentage,
        sum(count(*)) over()/2 as grandtotal
   from @EmplTable
 group by turnaround
 with cube

DECLARE @EducatTable TABLE 
( 
    section varchar(10), 
    turnaround int 
) 

insert into @EducatTable (section, turnaround)
select 'Educat' as section,
        case when dbo.elapsedbusinessdays_2( Educat.createddate, Educat.last_worked ) < 11 then dbo.elapsedbusinessdays_2( Educat.createddate, Educat.last_worked ) 
       else 11 end as turnaround 
  from Educat with (nolock) 
  join Appl 
  on Appl.Apno = Educat.Apno
  where Educat.createddate >= @StartDate 
   and Educat.last_worked < @EndDate
   and Educat.SectStat in ('2','3','4','5','6','7','8','A')

DECLARE @EducatTableSum TABLE 
( 
    section varchar(10), 
    turnaround int, 
    total int,
    percentage decimal(16,4),
    grandtotal int
) 

insert into @EducatTableSum (section, turnaround, total, percentage, grandtotal)

select 'Educat' as section, 
        case when grouping(turnaround) = 1 then 11
        else turnaround end as turnaround,
        sum(count(*)) over(partition by turnaround ) as total,
        sum(count(*)) over(partition by turnaround)*2/ cast(sum(count(*)) over()as decimal) as percentage,
        sum(count(*)) over()/2 as grandtotal
   from @EducatTable
 group by turnaround
 with cube

DECLARE @ProfLicTable TABLE 
( 
    section varchar(10), 
    turnaround int 
) 

insert into @ProfLicTable (section, turnaround)
select 'ProfLic' as section,
      case when dbo.elapsedbusinessdays_2( ProfLic.createddate, ProfLic.last_worked ) < 11 then dbo.elapsedbusinessdays_2( ProfLic.createddate, ProfLic.last_worked ) 
       else 11 end as turnaround 
  from ProfLic with (nolock) 
  join Appl 
    on Appl.Apno = ProfLic.Apno
 where ProfLic.createddate >= @StartDate
   and ProfLic.last_worked < @EndDate
   and ProfLic.SectStat in ('2','3','4','5','6','7','8','A')

DECLARE @ProfLicTableSum TABLE 
( 
    section varchar(10), 
    turnaround int, 
    total int,
    percentage decimal(16,4),
    grandtotal int
) 

insert into @ProfLicTableSum (section, turnaround, total, percentage, grandtotal)

select 'ProfLic' as section, 
        case when grouping(turnaround) = 1 then 11
        else turnaround end as turnaround,
        sum(count(*)) over(partition by turnaround ) as total,
        sum(count(*)) over(partition by turnaround)*2/ cast(sum(count(*)) over()as decimal) as percentage,
        sum(count(*)) over()/2 as grandtotal
   from @ProfLicTable
 group by turnaround
 with cube

DECLARE @PersRefTable TABLE 
( 
    section varchar(10), 
    turnaround int 
) 

insert into @PersRefTable (section, turnaround)
select 'PersRef' as section,
        case when dbo.elapsedbusinessdays_2( PersRef.createddate, PersRef.last_worked ) < 11 then dbo.elapsedbusinessdays_2( PersRef.createddate, PersRef.last_worked ) 
       else 11 end as turnaround
  from PersRef with (nolock) 
  join Appl 
    on Appl.Apno = PersRef.Apno
 where PersRef.createddate >= @StartDate 
   and PersRef.last_worked < @EndDate
   and PersRef.SectStat in ('2','3','4','5','6','7','8','A')

DECLARE @PersRefTableSum TABLE 
( 
    section varchar(10), 
    turnaround int, 
    total int,
    percentage decimal(16,4),
    grandtotal int
) 

insert into @PersRefTableSum (section, turnaround, total, percentage, grandtotal)

select 'PersRef' as section, 
        case when grouping(turnaround) = 1 then 11
        else turnaround end as turnaround,
        sum(count(*)) over(partition by turnaround ) as total,
        sum(count(*)) over(partition by turnaround)*2/ cast(sum(count(*)) over()as decimal) as percentage,
        sum(count(*)) over()/2 as grandtotal
   from @PersRefTable
 group by turnaround
 with cube

DECLARE @CrimTable TABLE 
( 
    section varchar(10), 
    turnaround int 
) 

insert into @CrimTable (section, turnaround)
select 'Crim' as section,
        case when dbo.elapsedbusinessdays_2( Crim.crimenteredtime, Crim.last_updated ) < 11 then dbo.elapsedbusinessdays_2( Crim.crimenteredtime, Crim.last_updated ) 
       else 11 end as turnaround  
  from Crim with (nolock) 
  join Appl 
    on Appl.Apno = Crim.Apno
 where Crim.crimenteredtime >= @StartDate
   and Crim.last_updated < @EndDate
   and Crim.Clear in ('T','F','P')

DECLARE @CrimTableSum TABLE 
( 
    section varchar(10), 
    turnaround int, 
    total int,
    percentage decimal(16,4),
    grandtotal int
) 

insert into @CrimTableSum (section, turnaround, total, percentage, grandtotal)

select 'Crim' as section, 
        case when grouping(turnaround) = 1 then  11
        else turnaround end as turnaround,
        sum(count(*)) over(partition by turnaround ) as total,
        sum(count(*)) over(partition by turnaround)*2/ cast(sum(count(*)) over()as decimal) as percentage,
        sum(count(*)) over()/2 as grandtotal
   from @CrimTable
 group by turnaround
 with cube


Select 
case when A.turnaround = 11 then 'Total'
     else A.section 
end as [Type],
case when A.total/cast(A.grandtotal as decimal) = 1 then ''
	else 
      case when A.turnaround = 11 then  cast(A.turnaround as varchar(8)) + '+ days' 
    else
	   cast(A.turnaround as varchar(8)) + ' days' 
	 end
end as Days,
A.total as [Count],
(cast(((A.total/cast(A.grandtotal as decimal))*100)as decimal(16,4))) as Percentage,
(cast(((A.total/cast(A.grandtotal as decimal) + COALESCE((SELECT SUM(b.total/cast(b.grandtotal as decimal)) 
                      FROM
                      @EmplTableSum B WHERE B.turnaround < A.turnaround and A.turnaround <> 11),0))*100)as decimal(16,4))) AS [Cumulative Percentage]
from
@EmplTableSum A
group by A.section, A.turnaround, A.total, A.grandtotal 

union all

Select 
case when A.turnaround = 11 then 'Total'
     else A.section 
end as [Type],
case when A.total/cast(A.grandtotal as decimal) = 1 then ''
	else 
      case when A.turnaround = 11 then  cast(A.turnaround as varchar(8)) + '+ days' 
     else
	  cast(A.turnaround as varchar(8)) + ' days' 
	  end
end as Days,
A.total as [Count],
(cast(((A.total/cast(A.grandtotal as decimal))*100)as decimal(16,4))) as Percentage,
(cast(((A.total/cast(A.grandtotal as decimal) + COALESCE((SELECT SUM(b.total/cast(b.grandtotal as decimal)) 
                      FROM
                      @EducatTableSum B WHERE B.turnaround < A.turnaround and A.turnaround <> 11),0))*100)as decimal(16,4))) AS [Cumulative Percentage]
from
@EducatTableSum A
group by A.section, A.turnaround, A.total, A.grandtotal 

union all

Select 
case when A.turnaround = 11 then 'Total'
     else A.section 
end as [Type],
case when A.total/cast(A.grandtotal as decimal) = 1 then ''
	else 
      case when A.turnaround = 11 then  cast(A.turnaround as varchar(8)) + '+ days' 
     else 
	   cast(A.turnaround as varchar(8)) + ' days' 
     end
end as Days,
A.total as [Count],
(cast(((A.total/cast(A.grandtotal as decimal))*100)as decimal(16,4))) as Percentage,
(cast(((A.total/cast(A.grandtotal as decimal) + COALESCE((SELECT SUM(b.total/cast(b.grandtotal as decimal)) 
                      FROM
                      @ProfLicTableSum B WHERE B.turnaround < A.turnaround and A.turnaround <> 11),0))*100)as decimal(16,4))) AS [Cumulative Percentage]
from
@ProfLicTableSum A
group by A.section, A.turnaround, A.total, A.grandtotal 

union all

Select 
case when A.turnaround = 11 then 'Total'
     else A.section 
end as [Type],
case when A.total/cast(A.grandtotal as decimal) = 1 then ''
	else 
      case when A.turnaround = 11 then  cast(A.turnaround as varchar(8)) + '+ days' 
    else
	 cast(A.turnaround as varchar(8)) + ' days' 
	 end
end as Days,
A.total as [Count],
(cast(((A.total/cast(A.grandtotal as decimal))*100)as decimal(16,4))) as Percentage,
(cast(((A.total/cast(A.grandtotal as decimal) + COALESCE((SELECT SUM(b.total/cast(b.grandtotal as decimal)) 
                      FROM
                      @PersRefTableSum B WHERE B.turnaround < A.turnaround and A.turnaround <>11),0))*100)as decimal(16,4))) AS [Cumulative Percentage]
from
@PersRefTableSum A
group by A.section, A.turnaround, A.total, A.grandtotal 

union all

Select 
case when A.turnaround = 11 then 'Total'
     else A.section 
end as [Type],
case when A.total/cast(A.grandtotal as decimal) = 1 then ''
	else 
      case when A.turnaround = 11 then  cast(A.turnaround as varchar(8)) + '+ days' 
     else 
	   cast(A.turnaround as varchar(8)) + ' days' 
	   end
end as Days,
A.total as [Count],
(cast(((A.total/cast(A.grandtotal as decimal))*100)as decimal(16,4))) as Percentage,
(cast(((A.total/cast(A.grandtotal as decimal) + COALESCE((SELECT SUM(B.total/cast(B.grandtotal as decimal)) 
                      FROM
                      @CrimTableSum B WHERE B.turnaround < A.turnaround and A.turnaround <> 11),0))*100)as decimal(16,4))) AS [Cumulative Percentage]
from
@CrimTableSum A
group by A.section, A.turnaround, A.total, A.grandtotal 

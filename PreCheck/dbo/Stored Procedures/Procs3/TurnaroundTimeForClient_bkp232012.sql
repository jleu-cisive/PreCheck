
Create PROCEDURE [dbo].[TurnaroundTimeForClient_bkp232012]
(
  @CLNO int,
  @StartDate datetime,
  @EndDate datetime
)
as
Select 
case when A.total/cast(A.grandtotal as decimal) = 1 then 'Total'
     else A.section 
end as [Type],
case when A.total/cast(A.grandtotal as decimal) = 1 then ''
    else 
      case when A.turnaround = 6 then  cast(A.turnaround as varchar(8)) + '+ days' 
           else cast(A.turnaround as varchar(8)) + ' days' 
      end 
end as Days,
A.total as [Count],
(cast(((A.total/cast(A.grandtotal as decimal))*100)as decimal(10,4))) as Percentage,
(cast(((A.total/cast(A.grandtotal as decimal) + COALESCE((SELECT SUM(b.total/cast(b.grandtotal as decimal)) 
                      FROM
                      (select 'Empl' as section, 
        case when grouping(case when dbo.elapsedbusinessdays_2( Empl.createddate, Empl.last_worked ) < 6 then dbo.elapsedbusinessdays_2( Empl.createddate, Empl.last_worked ) 
        else 6 end) = 1 then 7
        else
        (case when dbo.elapsedbusinessdays_2( Empl.createddate, Empl.last_worked ) < 6 then dbo.elapsedbusinessdays_2( Empl.createddate, Empl.last_worked ) 
        else 6 end) 
      end 
as turnaround,
        sum(count(*)) over(partition by case when dbo.elapsedbusinessdays_2( Empl.createddate, Empl.last_worked ) < 6 then dbo.elapsedbusinessdays_2( Empl.createddate, Empl.last_worked )
        else 6 end) as total,
        sum(count(*)) over(partition by case when dbo.elapsedbusinessdays_2( Empl.createddate, Empl.last_worked ) < 6 then dbo.elapsedbusinessdays_2( Empl.createddate, Empl.last_worked )
        else 6 end)*2/ cast(sum(count(*)) over()as decimal) as percentage,
        sum(count(*)) over()/2 as grandtotal
   from Empl with (nolock) 
  join Appl 
    on Appl.Apno = Empl.Apno
 where Empl.createddate >= @StartDate 
   and Empl.last_worked < @EndDate
   and Appl.CLNO = @CLNO
   and Empl.SectStat in ('2','3','4','5','6','7','8','A')
 group by (case when dbo.elapsedbusinessdays_2( Empl.createddate, Empl.last_worked ) < 6 then dbo.elapsedbusinessdays_2( Empl.createddate, Empl.last_worked )
        else 6 end)
 with cube )b WHERE b.turnaround < A.turnaround and A.turnaround <> 7),0))*100)as decimal(10,4))) AS [Cumulative Percentage]
from
(select 'Empl' as section, 
        case when grouping(case when dbo.elapsedbusinessdays_2( Empl.createddate, Empl.last_worked ) < 6 then dbo.elapsedbusinessdays_2( Empl.createddate, Empl.last_worked ) 
        else 6 end) = 1 then 7
        else
        (case when dbo.elapsedbusinessdays_2( Empl.createddate, Empl.last_worked ) < 6 then dbo.elapsedbusinessdays_2( Empl.createddate, Empl.last_worked ) 
        else 6 end) 
      end 
as turnaround,
        sum(count(*)) over(partition by case when dbo.elapsedbusinessdays_2( Empl.createddate, Empl.last_worked ) < 6 then dbo.elapsedbusinessdays_2( Empl.createddate, Empl.last_worked )
        else 6 end) as total,
        sum(count(*)) over(partition by case when dbo.elapsedbusinessdays_2( Empl.createddate, Empl.last_worked ) < 6 then dbo.elapsedbusinessdays_2( Empl.createddate, Empl.last_worked )
        else 6 end)*2/ cast(sum(count(*)) over()as decimal) as percentage,
        sum(count(*)) over()/2 as grandtotal
   from Empl with (nolock) 
  join Appl 
    on Appl.Apno = Empl.Apno
 where Empl.createddate >= @StartDate 
   and Empl.last_worked < @EndDate
   and Appl.CLNO = @CLNO
   and Empl.SectStat in ('2','3','4','5','6','7','8','A')
 group by (case when dbo.elapsedbusinessdays_2( Empl.createddate, Empl.last_worked ) < 6 then dbo.elapsedbusinessdays_2( Empl.createddate, Empl.last_worked )
        else 6 end)
 with cube
) A
group by A.section, A.turnaround, A.total, A.grandtotal 
union all
Select 
case when A.total/cast(A.grandtotal as decimal) = 1 then 'Total'
     else A.section 
end as [Type],
case when A.total/cast(A.grandtotal as decimal) = 1 then ''
    else 
      case when A.turnaround = 6 then  cast(A.turnaround as varchar(8)) + '+ days' 
           else cast(A.turnaround as varchar(8)) + ' days' 
      end 
end as Days,
A.total as [Count],
(cast(((A.total/cast(A.grandtotal as decimal))*100)as decimal(10,4))) as Percentage,
(cast(((A.total/cast(A.grandtotal as decimal) + COALESCE((SELECT SUM(b.total/cast(b.grandtotal as decimal)) 
                      FROM
                      (select 'Educat' as section, 
        case when grouping(case when dbo.elapsedbusinessdays_2( Educat.createddate, Educat.last_worked ) < 6 then dbo.elapsedbusinessdays_2( Educat.createddate, Educat.last_worked ) 
        else 6 end) = 1 then 7
        else
        (case when dbo.elapsedbusinessdays_2( Educat.createddate, Educat.last_worked ) < 6 then dbo.elapsedbusinessdays_2( Educat.createddate, Educat.last_worked ) 
        else 6 end) 
      end 
as turnaround,
        sum(count(*)) over(partition by case when dbo.elapsedbusinessdays_2( Educat.createddate, Educat.last_worked ) < 6 then dbo.elapsedbusinessdays_2( Educat.createddate, Educat.last_worked )
        else 6 end) as total,
        sum(count(*)) over(partition by case when dbo.elapsedbusinessdays_2( Educat.createddate, Educat.last_worked ) < 6 then dbo.elapsedbusinessdays_2( Educat.createddate, Educat.last_worked )
        else 6 end)*2/ cast(sum(count(*)) over()as decimal) as percentage,
        sum(count(*)) over()/2 as grandtotal
   from Educat with (nolock) 
  join Appl 
    on Appl.Apno = Educat.Apno
 where Educat.createddate >= @StartDate 
   and Educat.last_worked < @EndDate
   and Appl.CLNO = @CLNO
   and Educat.SectStat in ('2','3','4','5','6','7','8','A')
 group by (case when dbo.elapsedbusinessdays_2( Educat.createddate, Educat.last_worked ) < 6 then dbo.elapsedbusinessdays_2( Educat.createddate, Educat.last_worked )
        else 6 end)
 with cube )b WHERE b.turnaround < A.turnaround and A.turnaround <> 7),0))*100)as decimal(10,4))) AS [Cumulative Percentage]
from
(select 'Educat' as section, 
        case when grouping(case when dbo.elapsedbusinessdays_2( Educat.createddate, Educat.last_worked ) < 6 then dbo.elapsedbusinessdays_2( Educat.createddate, Educat.last_worked ) 
        else 6 end) = 1 then 7
        else
        (case when dbo.elapsedbusinessdays_2( Educat.createddate, Educat.last_worked ) < 6 then dbo.elapsedbusinessdays_2( Educat.createddate, Educat.last_worked ) 
        else 6 end) 
      end 
as turnaround,
        sum(count(*)) over(partition by case when dbo.elapsedbusinessdays_2( Educat.createddate, Educat.last_worked ) < 6 then dbo.elapsedbusinessdays_2( Educat.createddate, Educat.last_worked )
        else 6 end) as total,
        sum(count(*)) over(partition by case when dbo.elapsedbusinessdays_2( Educat.createddate, Educat.last_worked ) < 6 then dbo.elapsedbusinessdays_2( Educat.createddate, Educat.last_worked )
        else 6 end)*2/ cast(sum(count(*)) over()as decimal) as percentage,
        sum(count(*)) over()/2 as grandtotal
   from Educat with (nolock) 
  join Appl 
    on Appl.Apno = Educat.Apno
 where Educat.createddate >= @StartDate 
   and Educat.last_worked < @EndDate
   and Appl.CLNO = @CLNO
   and Educat.SectStat in ('2','3','4','5','6','7','8','A')
 group by (case when dbo.elapsedbusinessdays_2( Educat.createddate, Educat.last_worked ) < 6 then dbo.elapsedbusinessdays_2( Educat.createddate, Educat.last_worked )
        else 6 end)
 with cube
) A
group by A.section, A.turnaround, A.total, A.grandtotal 
union all
Select 
case when A.total/cast(A.grandtotal as decimal) = 1 then 'Total'
     else A.section 
end as [Type],
case when A.total/cast(A.grandtotal as decimal) = 1 then ''
    else 
      case when A.turnaround = 6 then  cast(A.turnaround as varchar(8)) + '+ days' 
           else cast(A.turnaround as varchar(8)) + ' days' 
      end 
end as Days,
A.total as [Count],
(cast(((A.total/cast(A.grandtotal as decimal))*100)as decimal(10,4))) as Percentage,
(cast(((A.total/cast(A.grandtotal as decimal) + COALESCE((SELECT SUM(b.total/cast(b.grandtotal as decimal)) 
                      FROM
                      (select 'ProfLic' as section, 
        case when grouping(case when dbo.elapsedbusinessdays_2( ProfLic.createddate, ProfLic.last_worked ) < 6 then dbo.elapsedbusinessdays_2( ProfLic.createddate, ProfLic.last_worked ) 
        else 6 end) = 1 then 7
        else
        (case when dbo.elapsedbusinessdays_2( ProfLic.createddate, ProfLic.last_worked ) < 6 then dbo.elapsedbusinessdays_2( ProfLic.createddate, ProfLic.last_worked ) 
        else 6 end) 
      end 
as turnaround,
        sum(count(*)) over(partition by case when dbo.elapsedbusinessdays_2( ProfLic.createddate, ProfLic.last_worked ) < 6 then dbo.elapsedbusinessdays_2( ProfLic.createddate, ProfLic.last_worked )
        else 6 end) as total,
        sum(count(*)) over(partition by case when dbo.elapsedbusinessdays_2( ProfLic.createddate, ProfLic.last_worked ) < 6 then dbo.elapsedbusinessdays_2( ProfLic.createddate, ProfLic.last_worked )
        else 6 end)*2/ cast(sum(count(*)) over()as decimal) as percentage,
        sum(count(*)) over()/2 as grandtotal
   from ProfLic with (nolock) 
  join Appl 
    on Appl.Apno = ProfLic.Apno
 where ProfLic.createddate >= @StartDate 
   and ProfLic.last_worked < @EndDate
   and Appl.CLNO = @CLNO
   and ProfLic.SectStat in ('2','3','4','5','6','7','8','A')
 group by (case when dbo.elapsedbusinessdays_2( ProfLic.createddate, ProfLic.last_worked ) < 6 then dbo.elapsedbusinessdays_2( ProfLic.createddate, ProfLic.last_worked )
        else 6 end)
 with cube )b  WHERE b.turnaround < A.turnaround and A.turnaround <> 7),0))*100)as decimal(10,4))) AS [Cumulative Percentage]
from
(select 'ProfLic' as section, 
        case when grouping(case when dbo.elapsedbusinessdays_2( ProfLic.createddate, ProfLic.last_worked ) < 6 then dbo.elapsedbusinessdays_2( ProfLic.createddate, ProfLic.last_worked ) 
        else 6 end) = 1 then 7
        else
        (case when dbo.elapsedbusinessdays_2( ProfLic.createddate, ProfLic.last_worked ) < 6 then dbo.elapsedbusinessdays_2( ProfLic.createddate, ProfLic.last_worked ) 
        else 6 end) 
      end 
as turnaround,
        sum(count(*)) over(partition by case when dbo.elapsedbusinessdays_2( ProfLic.createddate, ProfLic.last_worked ) < 6 then dbo.elapsedbusinessdays_2( ProfLic.createddate, ProfLic.last_worked )
        else 6 end) as total,
        sum(count(*)) over(partition by case when dbo.elapsedbusinessdays_2( ProfLic.createddate, ProfLic.last_worked ) < 6 then dbo.elapsedbusinessdays_2( ProfLic.createddate, ProfLic.last_worked )
        else 6 end)*2/ cast(sum(count(*)) over()as decimal) as percentage,
        sum(count(*)) over()/2 as grandtotal
   from ProfLic with (nolock) 
  join Appl 
    on Appl.Apno = ProfLic.Apno
 where ProfLic.createddate >= @StartDate 
   and ProfLic.last_worked < @EndDate
   and Appl.CLNO = @CLNO
   and ProfLic.SectStat in ('2','3','4','5','6','7','8','A')
 group by (case when dbo.elapsedbusinessdays_2( ProfLic.createddate, ProfLic.last_worked ) < 6 then dbo.elapsedbusinessdays_2( ProfLic.createddate, ProfLic.last_worked )
        else 6 end)
 with cube ) A
group by A.section, A.turnaround, A.total, A.grandtotal 
union all
Select 
case when A.total/cast(A.grandtotal as decimal) = 1 then 'Total'
     else A.section 
end as [Type],
case when A.total/cast(A.grandtotal as decimal) = 1 then ''
    else 
      case when A.turnaround = 6 then  cast(A.turnaround as varchar(8)) + '+ days' 
           else cast(A.turnaround as varchar(8)) + ' days' 
      end 
end as Days,
A.total as [Count],
(cast(((A.total/cast(A.grandtotal as decimal))*100)as decimal(10,4))) as Percentage,
(cast(((A.total/cast(A.grandtotal as decimal) + COALESCE((SELECT SUM(b.total/cast(b.grandtotal as decimal)) 
                      FROM
                      (select 'PersRef' as section, 
        case when grouping(case when dbo.elapsedbusinessdays_2( PersRef.createddate, PersRef.last_worked ) < 6 then dbo.elapsedbusinessdays_2( PersRef.createddate, PersRef.last_worked ) 
        else 6 end) = 1 then 7
        else
        (case when dbo.elapsedbusinessdays_2( PersRef.createddate, PersRef.last_worked ) < 6 then dbo.elapsedbusinessdays_2( PersRef.createddate, PersRef.last_worked ) 
        else 6 end) 
      end 
as turnaround,
        sum(count(*)) over(partition by case when dbo.elapsedbusinessdays_2( PersRef.createddate, PersRef.last_worked ) < 6 then dbo.elapsedbusinessdays_2( PersRef.createddate, PersRef.last_worked )
        else 6 end) as total,
        sum(count(*)) over(partition by case when dbo.elapsedbusinessdays_2( PersRef.createddate, PersRef.last_worked ) < 6 then dbo.elapsedbusinessdays_2( PersRef.createddate, PersRef.last_worked )
        else 6 end)*2/ cast(sum(count(*)) over()as decimal) as percentage,
        sum(count(*)) over()/2 as grandtotal
   from PersRef with (nolock) 
  join Appl 
    on Appl.Apno = PersRef.Apno
 where PersRef.createddate >= @StartDate 
   and PersRef.last_worked < @EndDate
   and Appl.CLNO = @CLNO
   and PersRef.SectStat in ('2','3','4','5','6','7','8','A')
 group by (case when dbo.elapsedbusinessdays_2( PersRef.createddate, PersRef.last_worked ) < 6 then dbo.elapsedbusinessdays_2( PersRef.createddate, PersRef.last_worked )
        else 6 end)
 with cube )b WHERE b.turnaround < A.turnaround and A.turnaround <> 7),0))*100)as decimal(10,4))) AS [Cumulative Percentage]
from
(select 'PersRef' as section, 
        case when grouping(case when dbo.elapsedbusinessdays_2( PersRef.createddate, PersRef.last_worked ) < 6 then dbo.elapsedbusinessdays_2( PersRef.createddate, PersRef.last_worked ) 
        else 6 end) = 1 then 7
        else
        (case when dbo.elapsedbusinessdays_2( PersRef.createddate, PersRef.last_worked ) < 6 then dbo.elapsedbusinessdays_2( PersRef.createddate, PersRef.last_worked ) 
        else 6 end) 
      end 
as turnaround,
        sum(count(*)) over(partition by case when dbo.elapsedbusinessdays_2( PersRef.createddate, PersRef.last_worked ) < 6 then dbo.elapsedbusinessdays_2( PersRef.createddate, PersRef.last_worked )
        else 6 end) as total,
        sum(count(*)) over(partition by case when dbo.elapsedbusinessdays_2( PersRef.createddate, PersRef.last_worked ) < 6 then dbo.elapsedbusinessdays_2( PersRef.createddate, PersRef.last_worked )
        else 6 end)*2/ cast(sum(count(*)) over()as decimal) as percentage,
        sum(count(*)) over()/2 as grandtotal
   from PersRef with (nolock) 
  join Appl 
    on Appl.Apno = PersRef.Apno
 where PersRef.createddate >= @StartDate 
   and PersRef.last_worked < @EndDate
   and Appl.CLNO = @CLNO
   and PersRef.SectStat in ('2','3','4','5','6','7','8','A')
 group by (case when dbo.elapsedbusinessdays_2( PersRef.createddate, PersRef.last_worked ) < 6 then dbo.elapsedbusinessdays_2( PersRef.createddate, PersRef.last_worked )
        else 6 end)
 with cube
) A
group by A.section, A.turnaround, A.total, A.grandtotal 














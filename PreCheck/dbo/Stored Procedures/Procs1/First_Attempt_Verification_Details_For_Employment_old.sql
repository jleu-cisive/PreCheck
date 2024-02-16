



CREATE Procedure [dbo].[First_Attempt_Verification_Details_For_Employment_old]
(
@StartDate DateTime = '07/08/2014', 
@EndDate DateTime = '07/08/2014'

) 
 as 

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

select id, oldvalue, min(changedate) as changedate, userid into #temp11 from changelog with (nolock) 
group by  id, tablename, oldvalue, userid
having tablename = 'Empl.SectStat' 
and (min(changedate)> CONVERT(DATETIME, @StartDate, 102)) and min(changedate)< = dateadd(s,-1,dateadd(d,1,@EndDate)) 
and oldvalue ='9' and count(id)<2
order by id

select  t.id as emplid, t.oldvalue,  c.newvalue, t.changedate, t.userid into #temp12 from #temp11 t join changelog c with (nolock) 
on t.id = c.id and t.changedate = c.changedate and t.userid = t.userid
where NewValue  = '5' --in ('4','5','6','7','8') 
order by t.id

select w.history_appno as apno, e.emplid, e.userid, w.history_status, w.history_date into #temp 
from #temp12 e join web_status_history w WITH (NOLOCK) on e.emplid = w.emplid
  

-- select * from #temp
select * into #temp1 from #temp where apno not in (select apno from #temp where history_status in('12','44')) 

--select * from #temp1
--select apno, userid, emplid, count(*) as ncount  from #temp1 
--group by apno, userid, emplid--, history_status
----having count(*)>1 
--order by userid, emplid

select apno, userid, emplid, history_status, count(*) as ncount into #temp2 from #temp1 
group by apno, userid, emplid, history_status
having count(*)>1 
order by userid, emplid

select apno, userid, emplid, history_status, count(*) as ncount into #temp3 from #temp1 
group by apno, userid, emplid, history_status
having count(*)<2 and apno not in (select apno from #temp2)
order by userid, emplid


select distinct userid, emplid  into #temp4 from #temp3

select userid as UserID, Count(*) as 'First Attempt Closed' into #temp5 from #temp4
group by userid
union ALL
select 'Total' as UserID, count(*) as 'First Attempt Closed' from #temp4

select * into #temp6 from #temp5 where userid<>'Total' order by userid

select * from #temp6 union ALL
select * from #temp5 where userid = 'Total' 

drop table #temp11
drop table #temp12
drop table #temp
drop table #temp1
drop table #temp2
drop table #temp3
drop table #temp4
drop table #temp5
drop table #temp6

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

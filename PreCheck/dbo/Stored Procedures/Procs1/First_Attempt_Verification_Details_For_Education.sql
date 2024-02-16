
CREATE Procedure [dbo].[First_Attempt_Verification_Details_For_Education]
(
@StartDate DateTime = '2015-02-10 10:00:00.000', 
@EndDate DateTime = '2015-02-10 12:00:00.000'

) 
 as 
select e.apno, e.educatid, w.history_status, w.history_date into #temp 
from educat e WITH (NOLOCK) join web_edu_history w WITH (NOLOCK) on e.educatid = w.educatid and e.apno = w.history_apno 
and (e.last_worked > CONVERT(DATETIME, @StartDate, 102)) and e.last_worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) 
and e.sectstat in('4','5','6','7','8') 

  Select * from #temp

select * into #temp1 from #temp where apno not in (select apno from #temp where history_status in('12','44')) 


select apno, educatid, history_status, count(*) as ncount into #temp2 from #temp1 
group by apno, educatid,history_status
having count(*)>1 
order by educatid

select apno, educatid, history_status, count(*) as ncount into #temp3 from #temp1 
group by apno, educatid,history_status
having count(*)<2 and apno not in (select apno from #temp2)
order by educatid


select distinct educatid  into #temp4 from #temp3

  Select * from #temp1
    Select * from #temp2 
	 Select * from #temp3
	   Select * from #temp4

select case when investigator is null then ''
else investigator end as UserID, Count(*) as 'First Attempt Closed'  into #temp5 from educat e WITH (NOLOCK) join #temp4 t on e.educatid = t.educatid
group by investigator 
union 
select 'Total' as UserID, count(*) as 'First Attempt Closed' from #temp4 
select * into #temp6 from #temp5 where userid<> 'Total' order by userid
select * from #temp6 union ALL
select * from #temp5 where userid = 'Total' 
drop table #temp
drop table #temp1
drop table #temp2
drop table #temp3
drop table #temp4
drop table #temp5
drop table #temp6
















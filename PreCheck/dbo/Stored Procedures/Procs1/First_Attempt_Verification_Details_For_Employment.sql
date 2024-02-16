


-- exec First_Attempt_Verification_Details_For_Employment '01/14/2020', '01/14/2020'
--'2015-01-05', '2015-01-06'

CREATE Procedure [dbo].[First_Attempt_Verification_Details_For_Employment]
(
@StartDate DateTime = '2015-10-10 10:00', 
@EndDate DateTime = '2015-02-10 12:00'

) 
 as 

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

-- Get the 'Modified From' values--> ["NEEDS REVIEW" & "PENDING"] when the Modified To is ["VERIFIED/SEE ATTACHED"] from 'Empl.SectStat' 
select id, oldvalue, min(changedate) as changedate, REPLACE(USERID, '-empl','') userid 
	   into #temp11 
from changelog with (nolock) 
group by  id, tablename, oldvalue,NewValue, userid
having tablename = 'Empl.SectStat' 
and (min(changedate)>= @StartDate)--CONVERT(DATETIME, @StartDate, 102))
 and min(changedate)< dateadd(d,1,@EndDate)
and oldvalue in ('9', '0') and NewValue  IN ('5','7')  --and count(id)<2
order by id

--select @StartDate,@EndDate
--select * from #temp11 where UserID = 'bwintlen'

--select  t.id as emplid, t.oldvalue,  c.newvalue, t.changedate, t.userid into #temp12 from #temp11 t join changelog c with (nolock) 
--on t.id = c.id and t.changedate = c.changedate and t.userid = t.userid
--where NewValue  = '5' --in ('4','5','6','7','8') 
--order by t.id

--select * from #temp12

-- Get all the occurances of the ID from above from the web_status_history
--select e.id emplid, e.userid--, w.history_status, w.history_date 
--into #temp 
--from #temp11 e left join web_status_history w WITH (NOLOCK) on e.id = w.emplid 
select distinct e.id emplid, e.userid--, w.history_status, w.history_date 
into #temp 
from #temp11 e left join web_status_history w WITH (NOLOCK) on e.id = w.emplid 
WHERE w.history_date >=@StartDate AND w.history_date< dateadd(d,1,@EndDate)

--group by e.id,e.userid  --having   count(e.id)<2

-- Remove dupilcate Employment Id's
delete from #temp where emplid in (
select emplid  from #temp  group by emplid having   count(emplid)>1)

 --select * from #temp where UserID = 'bwintlen'


-- Get all the 'Modified From' values--> ["Choose"] from 'Empl.web_status'
select	id , REPLACE(USERID, '-empl','') userid  
		into #temp12 
from changelog with (nolock) 
where tablename  = 'Empl.web_status'
and ((changedate)>= @StartDate)-- CONVERT(DATETIME, @StartDate, 102)) 
and (changedate)<  dateadd(d,1,@EndDate) --dateadd(s,-1,dateadd(d,1,@EndDate)) 
and oldvalue = '0'



---- Get all the occurances of the ID from above from the web_status_history
--select e.id emplid, e.userid
--into #temp13 
--from #temp12 e left join web_status_history w WITH (NOLOCK) on e.id = w.emplid 


---- Remove dupilcate Employment Id's
--delete from #temp13 where emplid in (
--select emplid  from #temp13  group by emplid having   count(emplid)>1)


-- Combine all the values from 'Empl.web_status' and 'Empl.SectStat' 
select  id , userid  into #temp14 from #temp12
union all
select emplid as id , userid   from #temp
--select t1.id , t1.userid into #temp14 from #temp12 t1 inner join #temp11 t2 on t1.id= t2.id


-- Get unique ID's from above
select distinct ID,userid into #temp15 from #temp14
--select * from #temp15 --where UserID = 'bwintlen'
 


--select * into #temp1 from #temp12 where emplid not in (select emplid from #temp ) 

--select * from #temp13

-- Get all the Unique ID's when the value is anything like "Empl"
SELECT distinct REPLACE(USERID, '-empl','') UserID,id into #tempChangeLog3
FROM dbo.ChangeLog 
where TableName like  'Empl.%'
and ChangeDate>=@StartDate and ChangeDate<dateadd(d,1,@EndDate) --dateadd(s,-1,dateadd(d,1,@EndDate))
order by UserID

--select * from #tempChangeLog3

-- Get all the Users who use "Employment module"
Select	distinct UserID 
		into #tempUsers 
from Users 
Where Empl = 1 
  and Disabled = 0 --(Added by Radhika Dereddy on 04/07/2014 as per Milton's request to have all investiagtors incuded irrrespective of their activity each day)
order by UserID

--select userid, 
--(select count(1) From #tempChangeLog3 where  #tempChangeLog3.UserID = T.UserID) [Efforts],
--count(emplid) as 'FirstAttemptClosed' 
--into #tempr
-- from #temp1 T
--group by userid

--select * from #tempr

-- Get all the Values
select userid, 
(select count(1) From #tempChangeLog3 where  #tempChangeLog3.UserID = T.UserID) [Efforts],
(select count(1) From #temp15 where  #temp15.UserID = T.UserID) 'FirstAttemptEfforts',
(select count(emplid) from #temp where #temp.UserID = T.UserID )'FirstAttemptClosed' 
into #tempr
 from #tempUsers T
group by userid

--select * from #tempr

--select userid,[Efforts], FirstAttemptEfforts,[FirstAttemptClosed],
--(Case When (cast(FirstAttemptEfforts as int)> 0) Then (cast(FirstAttemptClosed as decimal(10,4))/FirstAttemptEfforts*100) else '0.00' end)  as 'Percentage' from #tempr

create table #TempStatus 
( 
   Userid varchar(8),
   Efforts int,
   FirstAttemptEfforts int,
   FirstAttemptClosed int,
   Percentage decimal
) 


insert into #TempStatus (UserID, Efforts,FirstAttemptEfforts, FirstAttemptClosed, Percentage)
select userid,[Efforts], FirstAttemptEfforts,[FirstAttemptClosed],
(Case When (cast(FirstAttemptEfforts as int)> 0) Then (cast(FirstAttemptClosed as decimal(10,4))/FirstAttemptEfforts*100) else '0.00' end)  as 'Percentage' from #tempr


Select UserID, Efforts,FirstAttemptEfforts, FirstAttemptClosed, Cast(round(Percentage, 2) as numeric(36,2)) as 'Percentage %' from #TempStatus
union all
Select 'Totals', sum(Efforts) Efforts, sum(FirstAttemptEfforts) FirstAttemptEfforts, sum(FirstAttemptClosed) count, 0 as 'Percentage %' from #TempStatus

--drop table #temp13
drop table #tempStatus
drop table #temp11
--drop table #temp12
drop table #temp
--drop table #temp1
drop table #tempr
drop table #tempUsers

drop table #temp14
drop table #temp15

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

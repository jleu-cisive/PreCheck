
CREATE PROCEDURE [dbo].[Personal_Reference_Verification_Status_QReport] 

@StartDate DateTime = '12/5/2014',
@EndDate DateTime = '12/6/2014'

AS



SELECT  id, Newvalue,UserID 
into #tempChangeLog
FROM         dbo.ChangeLog
WHERE     (TableName = 'PersRef.SectStat')
and ChangeDate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))
order by UserID


   --where Newvalue = '4' --and

Select Investigator,web_Updated,sectstat, Apno, PersRefID into #tmp1
From dbo.PersRef (NoLock)
Where isnull(Investigator,'') <> '' and 
(Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)))
order by Investigator asc

--(InvestigatorAssigned>= @StartDate and InvestigatorAssigned< = dateadd(s,-1,dateadd(d,1,@EndDate)))
----OR



SELECT distinct UserID,id into #tempChangeLog2
FROM         dbo.ChangeLog where
TableName =  'PersRef.web_status'
and  ChangeDate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))
and Newvalue <> 0 
order by UserID


SELECT    UserID,id into #tempChangeLog3
FROM         dbo.ChangeLog where
TableName like  'PersRef.%'
and  ChangeDate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))
order by UserID

Select  distinct id,UserID into #tempChangeLog4 From #tempChangeLog3 

Select distinct UserID into #tempUsers from Users Where PersRef = 1 and Disabled = 0 
order by UserID


--CREATE TABLE #TEMPUser(
--	[Investigator] varchar(8) )
--
--
----insert into #TEMPUser(Investigator)
----select Investigator from #tmp1
--
--insert into #TEMPUser(Investigator)
--select UserID from #tempChangeLog


--select * from #tempChangeLog order by userid



--Select * From #tmp1 
Select  T.UserID  Investigator, 
(select count(1) From #tempChangeLog4 where  #tempChangeLog4.UserID = T.UserID) [Efforts],
 --(Select count(1) From dbo.#tmp1 J (NoLock) where  (InvestigatorAssigned>= @StartDate and InvestigatorAssigned< = dateadd(s,-1,dateadd(d,1,@EndDate))) and isnull(J.Investigator,'') = isnull(T.UserID,'')) [Verifications Assigned],
(Select count(1) From #tempChangeLog2 A where A.UserID = T.UserID) [Verifications - Updated WebStatus],
	  (Select count(1) From #tempChangeLog B (NoLock)  where NewValue = '4' and isnull(B.UserID,'') = isnull(T.UserID,'')) [VERIFIED],
	   (Select count(1) From #tempChangeLog C (NoLock)  where Newvalue = '5'  and isnull(C.UserID,'') = isnull(T.UserID,'')) [VERIFIED/SEE ATTACHED],
	   (Select count(1) From #tempChangeLog D (NoLock)  where Newvalue = '6'  and isnull(D.UserID,'') = isnull(T.UserID,'')) [UNVERIFIED/SEE ATTACHED],
	   (Select count(1) From #tempChangeLog E (NoLock)  where Newvalue = '8'   and isnull(E.UserID,'') = isnull(T.UserID,'')) [SEE ATTACHED],
   (Select count(1) From dbo.#tempChangeLog E1 (NoLock)  where E1.Newvalue in ('5','6','8') and isnull(E1.UserID,'') = isnull(T.UserID,'')) [Closed In by User],
   (Select count(1) From dbo.PersRef E2 (NoLock)  where E2.sectstat in ('5','6','8') and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) and isnull(E2.Investigator,'') = isnull(T.UserID,'')) [Closed In  User Module],	   
(Select count(1) From #tempChangeLog F (NoLock)  where Newvalue = '7'  and isnull(F.UserID,'') = isnull(T.UserID,'')) [ALERT/SEE ATTACHED],
--	   (Select count(1) From #tempChangeLog G (NoLock)  where Newvalue = '3'  and isnull(G.UserID,'') = isnull(T.UserID,'')) [COMPLETE/SEE ATTACHED],
--	   (Select count(1) From #tempChangeLog H( NoLock)  where Newvalue = '2'   and isnull(H.UserID,'') = isnull(T.UserID,'')) [COMPLETE],
	   (Select count(1) From #tempChangeLog I (NoLock)  where Newvalue = '9'  and isnull(I.UserID,'') = isnull(T.UserID,'')) [Pending - Assigned],
	   (Select count(1) From dbo.PersRef E (NoLock) inner JOin Appl A (NoLock) on E.APNO = A.APNO  where sectstat = '9' and  A.ApStatus not in ('F') ) [Pending - Overall]
--From  #tempChangeLog T
FROM #tempUsers T
Group By T.UserID

UNION ALL


Select 'Totals' Investigator, 0 [Efforts],
--(Select count(1) From dbo.Empl J (NoLock) where  (InvestigatorAssigned>= @StartDate and InvestigatorAssigned< = dateadd(s,-1,dateadd(d,1,@EndDate))) ) [Verifications Assigned],
--count(1) [Verifications Assigned],
 --(Select count(1) From #tmp1 A where web_Updated is not null ) [Verifications - Updated WebStatus],
		(Select count(1) From dbo.PersRef A (NoLock)  where web_Updated is not null and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)))  [Verifications - Updated WebStatus],
	   (Select count(1) From dbo.PersRef B (NoLock)  where sectstat = '4' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [VERIFIED],
	   (Select count(1) From dbo.PersRef C (NoLock)  where sectstat = '5'and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) ) [VERIFIED/SEE ATTACHED],
	   (Select count(1) From dbo.PersRef D (NoLock)  where sectstat = '6' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [UNVERIFIED/SEE ATTACHED],
	   (Select count(1) From dbo.PersRef E (NoLock)  where sectstat = '8' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [SEE ATTACHED],
	'' [Closed In by User],'' [Closed In  User Module],	   
(Select count(1) From dbo.PersRef F (NoLock)  where sectstat = '7' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [ALERT/SEE ATTACHED],
--	   (Select count(1) From dbo.Empl G (NoLock)  where sectstat = '3' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [COMPLETE/SEE ATTACHED],
--	   (Select count(1) From dbo.Empl H (NoLock)  where sectstat = '2' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [COMPLETE],
	   (Select count(1) From dbo.PersRef I (NoLock)  where sectstat = '9'and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) ) [Pending - Assigned],
	  (Select count(1) From dbo.PersRef E (NoLock) inner JOin Appl A (NoLock) on E.APNO = A.APNO  where sectstat = '9' and  A.ApStatus not in ('F') and CLNO not in (3468 ) ) [Pending - Overall]


Drop Table #tmp1

Drop Table #tempChangeLog
Drop Table #tempChangeLog2
--Drop Table #TEMPUser
Drop Table #tempChangeLog3
Drop Table #tempChangeLog4
Drop Table #tempUsers












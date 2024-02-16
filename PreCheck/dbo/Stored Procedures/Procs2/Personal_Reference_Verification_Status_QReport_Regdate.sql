

-- [Personal_Reference_Verification_Status_QReport_Regdate] '08/01/2013','08/07/2013'
-- =============================================
-- Author:		Liel Alimole
-- Create date: 4/2/2013
-- Description:	Rreflect results associated with the "Personal Reference" component in OASIS/Intranet Module.
-- =============================================
CREATE PROCEDURE [dbo].[Personal_Reference_Verification_Status_QReport_Regdate] 

@StartDate DateTime = '04/01/2013', 
@EndDate DateTime = '04/01/2013'

AS
BEGIN
SELECT    Newvalue,UserID,id into #tempChangeLog
FROM         dbo.ChangeLog
WHERE     (TableName = 'PersRef.SectStat')
and ChangeDate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))
order by UserID

--select * from #tempChangeLog

--   --where Newvalue = '4' --and
--Select Investigator,web_Updated,sectstat,apno,PersRefID into #tmp1
--From dbo.PersRef (NoLock)
--Where (Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)))
--order by Investigator asc
----
--select * from #tmp1

SELECT    Newvalue,UserID,id into #tempChangeLog2
FROM         dbo.ChangeLog where
TableName =  'PersRef.web_status'
and  ChangeDate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))
and Newvalue <> 0 
order by UserID

--select * from #tempChangeLog2
SELECT    UserID,id into #tempChangeLog3
FROM         dbo.ChangeLog where
TableName like  'PersRef.%'
and  ChangeDate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))
order by UserID
--select * from #tempChangeLog3
--
--CREATE TABLE #TEMPUser(
--	[Investigator] varchar(8) )
--
Select  distinct id,UserID into #tempChangeLog4 From #tempChangeLog3

--select	APNO AS id, Investigator AS UserID
--		into #tempChangeLog4 
--FROM dbo.PersRef AS P WITH(NOLOCK) 
--INNER JOIN dbo.SectStat AS S ON S.Code = P.SectStat
--WHERE PersRefID in ( SELECT DISTINCT(id)
--					FROM dbo.ChangeLog 
--					where TableName like  'PersRef.%'
--					  and ChangeDate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))
--					  and UserID in ('AComer','KChabot')
--					  )
--GROUP BY APNO, Investigator
--ORDER BY Investigator desc

--select * from #tempChangeLog4
--
----insert into #TEMPUser(Investigator)
----select Investigator from #tmp1
--
--insert into #TEMPUser(Investigator)
--select UserID from #tempChangeLog


--select * from #tmp1 where Investigator = 'Savery'
--where Newvalue = '6' order by ID,USerid

Select distinct UserID into #tempUsers from Users Where PersRef = 1 and Disabled = 0 --(Added by Radhika Dereddy on 04/07/2014 as per Milton's request to have all investiagtors included irrrespective of their activity each day)
order by UserID

--select * from #tempUsers

--Select * From #tmp1 
Select  T.UserID  Investigator, 
(select count(1) From #tempChangeLog4 where  #tempChangeLog4.UserID = T.UserID) [Efforts],
--(Select count(1) From dbo.#tmp1 J (NoLock) where  (InvestigatorAssigned>= @StartDate and InvestigatorAssigned< = dateadd(s,-1,dateadd(d,1,@EndDate))) and isnull(J.Investigator,'') = isnull(T.UserID,'')),
--(Select count(1) From #tempChangeLog2 A where web_Updated is not null and web_Updated between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate)) and A.Investigator = T.UserID) [Verifications - Updated WebStatus],
(Select count(1) From #tempChangeLog2 A where  A.UserID = T.UserID) [Verifications - Updated WebStatus],
	  (Select count(1) From #tempChangeLog B (NoLock)  where Newvalue = '4' and isnull(B.UserID,'') = isnull(T.UserID,'')) [VERIFIED],
	   (Select count(1) From #tempChangeLog C (NoLock)  where Newvalue = '5'  and isnull(C.UserID,'') = isnull(T.UserID,'')) [VERIFIED/SEE ATTACHED],
	   (Select count(1) From #tempChangeLog D (NoLock)  where Newvalue = '6'  and isnull(D.UserID,'') = isnull(T.UserID,'')) [UNVERIFIED/SEE ATTACHED],
	   (Select count(1) From #tempChangeLog E (NoLock)  where Newvalue = '8'   and isnull(E.UserID,'') = isnull(T.UserID,'')) [SEE ATTACHED],
   (Select count(1) From dbo.#tempChangeLog E1 (NoLock)  where E1.Newvalue in ('4','5','6','8') and isnull(E1.UserID,'') = isnull(T.UserID,'')) [Closed In by User],
   (Select count(1) From dbo.PersRef E2 (NoLock)  where E2.sectstat in ('4','5','6','8') and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) and isnull(E2.Investigator,'') = isnull(T.UserID,'')) [Closed In  User Module],	   
(Select count(1) From #tempChangeLog F (NoLock)  where Newvalue = '7'  and isnull(F.UserID,'') = isnull(T.UserID,'')) [ALERT/SEE ATTACHED],
	--   (Select count(1) From #tempChangeLog G (NoLock)  where Newvalue = '3'  and isnull(G.UserID,'') = isnull(T.UserID,'')) [COMPLETE/SEE ATTACHED],
  --(Select count(1) From #tempChangeLog H( NoLock)  where Newvalue = '2'   and isnull(H.UserID,'') = isnull(T.UserID,'')) [COMPLETE],
	   (Select count(1) From #tempChangeLog I (NoLock)  where Newvalue = '9'  and isnull(I.UserID,'') = isnull(T.UserID,'')) [Pending - Assigned],
	   (Select count(1) From dbo.PersRef E (NoLock) inner JOin Appl A (NoLock) on E.APNO = A.APNO  where sectstat = '9' and  A.ApStatus not in ('F') and CLNO not in (3468 ) ) [Pending - Overall]
--From  #tempChangeLog T --commented by rdereddy on 06/19/2014
FROM #tempUsers T
Group By T.UserID


UNION ALL
Select 'Totals' Investigator, 0 [Efforts],
--(Select count(1) From dbo.PersRef J (NoLock) where  (InvestigatorAssigned>= @StartDate and InvestigatorAssigned< = dateadd(s,-1,dateadd(d,1,@EndDate))) ),
--count(1) [Verifications Assigned],
 --(Select count(1) From #tmp1 A where web_Updated is not null ) [Verifications - Updated WebStatus],
	(Select count(1) From dbo.PersRef A (NoLock)  where web_Updated is not null and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [Verifications - Updated WebStatus],
	   (Select count(1) From dbo.PersRef B (NoLock)  where sectstat = '4' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [VERIFIED],
	   (Select count(1) From dbo.PersRef C (NoLock)  where sectstat = '5'and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) ) [VERIFIED/SEE ATTACHED],
	   (Select count(1) From dbo.PersRef D (NoLock)  where sectstat = '6' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [UNVERIFIED/SEE ATTACHED],
	   (Select count(1) From dbo.PersRef E (NoLock)  where sectstat = '8' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [SEE ATTACHED],
	'' [Closed In by User],'' [Closed In  User Module],	   
(Select count(1) From dbo.PersRef F (NoLock)  where sectstat = '7' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [ALERT/SEE ATTACHED],
--	   (Select count(1) From dbo.PersRef G (NoLock)  where sectstat = '3' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [COMPLETE/SEE ATTACHED],
--	   (Select count(1) From dbo.PersRef H (NoLock)  where sectstat = '2' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [COMPLETE],
	   (Select count(1) From dbo.PersRef I (NoLock)  where sectstat = '9'and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) ) [Pending - Assigned],
	  (Select count(1) From dbo.PersRef E (NoLock) inner JOin Appl A (NoLock) on E.APNO = A.APNO  where sectstat = '9' and  A.ApStatus not in ('F') and CLNO not in (3468 ) ) [Pending - Overall]


--Drop Table #tmp1

Drop Table #tempChangeLog
Drop Table #tempChangeLog2
--Drop Table #TEMPUser
Drop Table #tempChangeLog3
Drop Table #tempChangeLog4
Drop Table #tempUsers
END

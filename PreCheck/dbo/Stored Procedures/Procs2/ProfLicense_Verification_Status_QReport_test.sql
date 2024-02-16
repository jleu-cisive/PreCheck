








CREATE PROCEDURE [dbo].[ProfLicense_Verification_Status_QReport_test] 

@StartDate DateTime = '01/23/2012', 
@EndDate DateTime = '01/24/2012'

AS


SELECT    Newvalue,UserID into #tempChangeLog
FROM         dbo.ChangeLog
WHERE     (TableName = 'ProfLic.SectStat')
and ChangeDate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))
order by UserID

--SELECT    * --into #tempChangeLog
--FROM         dbo.ChangeLog
--WHERE     (TableName = 'ProfLic.SectStat')
--and ChangeDate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))
--order by UserID


Select Investigator,web_Updated,sectstat into #tmp1
From dbo.ProfLic (NoLock)
Where (Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)))
order by Investigator asc


--
--Select * From #tempChangeLog 
--
--
--Select * From #tmp1   


Select  T.UserID  Investigator, 
 --(Select count(1) From dbo.#tmp1 J (NoLock) where  (InvestigatorAssigned>= @StartDate and InvestigatorAssigned< = dateadd(s,-1,dateadd(d,1,@EndDate))) and isnull(J.Investigator,'') = isnull(T.UserID,'')) [Verifications Assigned],
(Select count(1) From #tmp1 A where web_Updated is not null and A.Investigator = T.UserID) [Verifications - Updated WebStatus],
	  (Select count(1) From #tempChangeLog B (NoLock)  where Newvalue = '4' and isnull(B.UserID,'') = isnull(T.UserID,'')) [VERIFIED],
	   (Select count(1) From #tempChangeLog C (NoLock)  where Newvalue = '5'  and isnull(C.UserID,'') = isnull(T.UserID,'')) [VERIFIED/SEE ATTACHED],
	   (Select count(1) From #tempChangeLog D (NoLock)  where Newvalue = '6'  and isnull(D.UserID,'') = isnull(T.UserID,'')) [UNVERIFIED/SEE ATTACHED],
	   (Select count(1) From #tempChangeLog E (NoLock)  where Newvalue = '8'   and isnull(E.UserID,'') = isnull(T.UserID,'')) [SEE ATTACHED],
	   (Select count(1) From #tempChangeLog F (NoLock)  where Newvalue = '7'  and isnull(F.UserID,'') = isnull(T.UserID,'')) [ALERT/SEE ATTACHED],
(Select count(1) From dbo.#tempChangeLog E1 (NoLock)  where E1.Newvalue in ('4','5','6','7','8') and isnull(E1.UserID,'') = isnull(T.UserID,'')) [Closed  by User],
   (Select count(1) From dbo.ProfLic E2 (NoLock)  where E2.sectstat in ('5','6','8') and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) and isnull(E2.Investigator,'') = isnull(T.UserID,'')) [Closed In  User Module],	   

--	   (Select count(1) From #tempChangeLog G (NoLock)  where Newvalue = '3'  and isnull(G.UserID,'') = isnull(T.UserID,'')) [COMPLETE/SEE ATTACHED],
--	   (Select count(1) From #tempChangeLog H( NoLock)  where Newvalue = '2'   and isnull(H.UserID,'') = isnull(T.UserID,'')) [COMPLETE],
	   (Select count(1) From #tempChangeLog I (NoLock)  where Newvalue = '9'  and isnull(I.UserID,'') = isnull(T.UserID,'')) [Pending - Assigned],
	   --(Select count(1) From dbo.ProfLic  (NoLock) where sectstat = '9') [Pending - Overall]
(Select count(1) From dbo.ProfLic E (NoLock) inner JOin Appl A (NoLock) on E.APNO = A.APNO  where sectstat = '9' and  A.ApStatus not in ('F') ) [Pending - Overall]
From  #tempChangeLog T
Group By T.UserID


UNION ALL
Select 'Totals' Investigator, 

--count(1) [Verifications Assigned],
 --(Select count(1) From #tmp1 A where web_Updated is not null ) [Verifications - Updated WebStatus],
		(Select count(1) From dbo.ProfLic A (NoLock)  where web_Updated is not null and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)))  [Verifications - Updated WebStatus],
	   (Select count(1) From dbo.ProfLic B (NoLock)  where sectstat = '4' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [VERIFIED],
	   (Select count(1) From dbo.ProfLic C (NoLock)  where sectstat = '5'and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) ) [VERIFIED/SEE ATTACHED],
	   (Select count(1) From dbo.ProfLic D (NoLock)  where sectstat = '6' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [UNVERIFIED/SEE ATTACHED],
	   (Select count(1) From dbo.ProfLic E (NoLock)  where sectstat = '8' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [SEE ATTACHED],
	   (Select count(1) From dbo.ProfLic F (NoLock)  where sectstat = '7' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [ALERT/SEE ATTACHED],
	'' [Closed  by User],'' [Closed In  User Module],
--	   (Select count(1) From dbo.ProfLic G (NoLock)  where sectstat = '3' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [COMPLETE/SEE ATTACHED],
--	   (Select count(1) From dbo.ProfLic H (NoLock)  where sectstat = '2' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [COMPLETE],
	   (Select count(1) From dbo.ProfLic I (NoLock)  where sectstat = '9'and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) ) [Pending - Assigned],
--	   (Select count(1) From dbo.ProfLic  (NoLock) where sectstat = '9') [Pending - Overall]
(Select count(1) From dbo.ProfLic E (NoLock) inner JOin Appl A (NoLock) on E.APNO = A.APNO  where sectstat = '9' and  A.ApStatus not in ('F') ) [Pending - Overall]



Drop Table #tempChangeLog

Drop Table #tmp1







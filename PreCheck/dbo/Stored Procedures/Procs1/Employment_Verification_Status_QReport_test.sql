







 CREATE PROCEDURE [dbo].[Employment_Verification_Status_QReport_test] 

@StartDate DateTime = '12/14/2011', 
@EndDate DateTime = '12/15/2011'

AS

--Declare @StartDate DateTime
--Declare @EndDate DateTime
--
--Set @StartDate = '08/29/2011'
--Set @EndDate = '08/29/2011'

--SELECT     *
--FROM         dbo.ChangeLog
--WHERE     (TableName = 'Empl.SectStat')
--and ChangeDate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))



--SELECT    Newvalue,UserID --into #tempChangeLog
--FROM         dbo.ChangeLog
--WHERE     (TableName = 'Empl.SectStat')
--and ChangeDate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))
--order by UserID

Select Investigator,InvestigatorAssigned,web_Updated,sectstat into #tmp1
From dbo.Empl (NoLock)
Where (InvestigatorAssigned>= @StartDate and InvestigatorAssigned< = dateadd(s,-1,dateadd(d,1,@EndDate)))
OR (Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)))
order by Investigator asc

Select Case When T.Investigator is Null then 'UnAssigned' else T.Investigator end Investigator, 
 (Select count(1) From dbo.#tmp1 J (NoLock) where  (InvestigatorAssigned>= @StartDate and InvestigatorAssigned< = dateadd(s,-1,dateadd(d,1,@EndDate))) and isnull(J.Investigator,'') = isnull(T.Investigator,'')) [Verifications Assigned],
(Select count(1) From #tmp1 A where web_Updated is not null and A.Investigator = T.Investigator) [Verifications - Updated WebStatus],
	  (Select count(1) From dbo.Empl B (NoLock)  where sectstat = '4'and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))and isnull(B.Investigator,'') = isnull(T.Investigator,'')) [VERIFIED],
	   (Select count(1) From dbo.Empl C (NoLock)  where sectstat = '5' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) and isnull(C.Investigator,'') = isnull(T.Investigator,'')) [VERIFIED/SEE ATTACHED],
	   (Select count(1) From dbo.Empl D (NoLock)  where sectstat = '6' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) and isnull(D.Investigator,'') = isnull(T.Investigator,'')) [UNVERIFIED/SEE ATTACHED],
	   (Select count(1) From dbo.Empl E (NoLock)  where sectstat = '8' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) and isnull(E.Investigator,'') = isnull(T.Investigator,'')) [SEE ATTACHED],
	   (Select count(1) From dbo.Empl F (NoLock)  where sectstat = '7' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) and isnull(F.Investigator,'') = isnull(T.Investigator,'')) [ALERT/SEE ATTACHED],
	   (Select count(1) From dbo.Empl G (NoLock)  where sectstat = '3' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) and isnull(G.Investigator,'') = isnull(T.Investigator,'')) [COMPLETE/SEE ATTACHED],
	   (Select count(1) From dbo.Empl H( NoLock)  where sectstat = '2' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) and isnull(H.Investigator,'') = isnull(T.Investigator,'')) [COMPLETE],
	   (Select count(1) From dbo.Empl I (NoLock)  where sectstat = '9' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) and isnull(I.Investigator,'') = isnull(T.Investigator,'')) [Pending - Assigned],
	   (Select count(1) From dbo.Empl  (NoLock) where sectstat = '9') [Pending - Overall]
From #tmp1 T
Group By T.Investigator
UNION ALL
Select 'Totals' Investigator, 
(Select count(1) From dbo.Empl J (NoLock) where  (InvestigatorAssigned>= @StartDate and InvestigatorAssigned< = dateadd(s,-1,dateadd(d,1,@EndDate))) ) [Verifications Assigned],
--count(1) [Verifications Assigned],
 --(Select count(1) From #tmp1 A where web_Updated is not null ) [Verifications - Updated WebStatus],
		(Select count(1) From dbo.Empl A (NoLock)  where web_Updated is not null and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [VERIFIED],
	   (Select count(1) From dbo.Empl B (NoLock)  where sectstat = '4' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [VERIFIED],
	   (Select count(1) From dbo.Empl C (NoLock)  where sectstat = '5'and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) ) [VERIFIED/SEE ATTACHED],
	   (Select count(1) From dbo.Empl D (NoLock)  where sectstat = '6' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [UNVERIFIED/SEE ATTACHED],
	   (Select count(1) From dbo.Empl E (NoLock)  where sectstat = '8' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [SEE ATTACHED],
	   (Select count(1) From dbo.Empl F (NoLock)  where sectstat = '7' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [ALERT/SEE ATTACHED],
	   (Select count(1) From dbo.Empl G (NoLock)  where sectstat = '3' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [COMPLETE/SEE ATTACHED],
	   (Select count(1) From dbo.Empl H (NoLock)  where sectstat = '2' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [COMPLETE],
	   (Select count(1) From dbo.Empl I (NoLock)  where sectstat = '9'and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) ) [Pending - Assigned],
	   (Select count(1) From dbo.Empl  (NoLock) where sectstat = '9') [Pending - Overall]
--From #tmp1 T

--Select count(1) From #tmp1  where  (InvestigatorAssigned>= @StartDate and InvestigatorAssigned< = dateadd(s,-1,dateadd(d,1,@EndDate)))
--
--Drop Table #tmp1

--
--Declare @StartDate DateTime
--Declare @EndDate DateTime
--
--Set @StartDate = --'08/01/2011'--
--Set @EndDate = --'08/20/2011'--
--
--Select Investigator,web_Updated,sectstat into #tmp1
--From dbo.Empl (NoLock)
--Where InvestigatorAssigned>= @StartDate and InvestigatorAssigned< = dateadd(s,-1,dateadd(d,1,@EndDate))
--
--Select Case When T.Investigator is Null then 'UnAssigned' else T.Investigator end Investigator, count(1) [Verifications Assigned],
--	   (Select count(1) From #tmp1 A where web_Updated is not null and A.Investigator = T.Investigator) [Verifications - Updated WebStatus],
--	   (Select count(1) From #tmp1 B where sectstat = '4' and B.Investigator = T.Investigator) [VERIFIED],
--	   (Select count(1) From #tmp1 C where sectstat = '5' and C.Investigator = T.Investigator) [VERIFIED/SEE ATTACHED],
--	   (Select count(1) From #tmp1 D where sectstat = '6' and D.Investigator = T.Investigator) [UNVERIFIED/SEE ATTACHED],
--	   (Select count(1) From #tmp1 E where sectstat = '8' and E.Investigator = T.Investigator) [SEE ATTACHED],
--	   (Select count(1) From #tmp1 F where sectstat = '7' and F.Investigator = T.Investigator) [ALERT/SEE ATTACHED],
--	   (Select count(1) From #tmp1 G where sectstat = '3' and G.Investigator = T.Investigator) [COMPLETE/SEE ATTACHED],
--	   (Select count(1) From #tmp1 H where sectstat = '2' and H.Investigator = T.Investigator) [COMPLETE],
--	   (Select count(1) From #tmp1 I where sectstat = '9' and I.Investigator = T.Investigator) [Pending - Assigned],
--	   (Select count(1) From dbo.Empl  (NoLock) where sectstat = '9') [Pending - Overall]
--From #tmp1 T
--Group By T.Investigator
--UNION ALL
--Select 'Totals' Investigator, count(1) [Verifications Assigned],
--	   (Select count(1) From #tmp1 A where web_Updated is not null ) [Verifications - Updated WebStatus],
--	   (Select count(1) From #tmp1 B where sectstat = '4' ) [VERIFIED],
--	   (Select count(1) From #tmp1 C where sectstat = '5' ) [VERIFIED/SEE ATTACHED],
--	   (Select count(1) From #tmp1 D where sectstat = '6' ) [UNVERIFIED/SEE ATTACHED],
--	   (Select count(1) From #tmp1 E where sectstat = '8' ) [SEE ATTACHED],
--	   (Select count(1) From #tmp1 F where sectstat = '7' ) [ALERT/SEE ATTACHED],
--	   (Select count(1) From #tmp1 G where sectstat = '3' ) [COMPLETE/SEE ATTACHED],
--	   (Select count(1) From #tmp1 H where sectstat = '2' ) [COMPLETE],
--	   (Select count(1) From #tmp1 I where sectstat = '9' ) [Pending - Assigned],
--	   (Select count(1) From dbo.Empl  (NoLock) where sectstat = '9') [Pending - Overall]
--From #tmp1 T

Drop Table #tmp1







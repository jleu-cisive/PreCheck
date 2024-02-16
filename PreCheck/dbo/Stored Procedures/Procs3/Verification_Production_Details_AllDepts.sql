
CREATE PROCEDURE [dbo].[Verification_Production_Details_AllDepts] 

@StartDate DateTime = '04/23/2013', 
@EndDate DateTime = '04/23/2013'

AS


----EMPLOYMENT------

--STEP:1 Empl #tempChangeLog
SELECT    Newvalue,UserID,id into #EmpltempChangeLog
FROM         dbo.ChangeLog
WHERE     (TableName = 'Empl.SectStat')
and ChangeDate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))
order by UserID

--STEP:2 Empl #tmp1
Select Investigator,InvestigatorAssigned,web_Updated,sectstat,apno,emplid into #Empltmp1
From dbo.Empl (NoLock)
Where (InvestigatorAssigned>= @StartDate and InvestigatorAssigned< = dateadd(s,-1,dateadd(d,1,@EndDate)))
OR (Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)))
order by Investigator asc

--STEP:3 Empl #tempChangeLog2
SELECT distinct UserID,id into #EmpltempChangeLog2
FROM         dbo.ChangeLog where
TableName =  'Empl.web_status'
and  ChangeDate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))
and Newvalue <> 0 
order by UserID

--STEP:4 Empl #tempChangeLog3
SELECT    UserID,id into #EmpltempChangeLog3
FROM         dbo.ChangeLog where
TableName like  'Empl.%'
and  ChangeDate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))
order by UserID

--STEP:5 Epml #tempChangeLog4
Select  distinct id,UserID into #EmpltempChangeLog4 From #EmpltempChangeLog3 

--STEP:6 #tempUsers
Select distinct UserID into #tempUsers from Users Where Empl = 1 OR Educat =1 OR PersRef = 1 OR CAM =1 and Disabled = 0
order by UserID
----------------------------------------------------------------------


----EDUCATION-----------------

--STEP:1 Edu #tempChangeLog
SELECT    Newvalue,UserID, id into #EdutempChangeLog
FROM         dbo.ChangeLog
WHERE     (TableName = 'Educat.SectStat')
and ChangeDate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))
order by UserID

--STEP:2 Edu #tmp1
Select Investigator,
web_Updated,sectstat into #Edutmp1
From dbo.Educat (NoLock)
Where (Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)))
order by Investigator asc

--STEP:3 Edu #tempChangeLog2
SELECT    Newvalue,UserID,id into #EdutempChangeLog2
FROM         dbo.ChangeLog where
TableName =  'Educat.web_status'
and  ChangeDate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))
and Newvalue <> 0 
order by UserID

--STEP:4 Edu #tempChangeLog3
SELECT    UserID,id into #EdutempChangeLog3
FROM         dbo.ChangeLog where
TableName like  'Educat.%'
and  ChangeDate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))
order by UserID

--STEP:5 Edu #tempChangeLog4
Select  distinct id,UserID into #EdutempChangeLog4 From #EdutempChangeLog3 

-----------------------------------------------------------------------------------

-------Personal Reference----------------------

--STEP:1 Persref  #tempChangeLog
SELECT Newvalue,UserID,id
into #PersReftempChangeLog
FROM         dbo.ChangeLog
WHERE     (TableName = 'PersRef.SectStat')
and ChangeDate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))
order by UserID


--STEP:2 Persref #tmp1
Select Investigator,
web_Updated,sectstat into #PersReftmp1
From dbo.PersRef (NoLock)
Where (Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)))
order by Investigator asc

--STEP:3 Persref #tempChangeLog2
SELECT    Newvalue,UserID,id into #PersReftempChangeLog2
FROM         dbo.ChangeLog where
TableName =  'PersRef.web_status'
and  ChangeDate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))
and Newvalue <> 0 
order by UserID

--STEP:4 Persref #tempChangeLog3
SELECT    UserID,id into #PersReftempChangeLog3
FROM         dbo.ChangeLog where
TableName like  'PersRef.%'
and  ChangeDate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))
order by UserID

--STEP:5 Persref #tempChangeLog4
Select  distinct id,UserID into #PersReftempChangeLog4 From #PersReftempChangeLog3 


-----------------------------------------------------------
create table #TempStatus 
( 
   NewValue varchar(8000),
   UserID varchar(50),
   id int
) 

insert into #TempStatus (NewValue,UserID,id) SELECT  Newvalue, UserID, id from #EmpltempChangeLog
insert into #TempStatus (NewValue,UserID,id) SELECT  Newvalue, UserID, id from #EdutempChangeLog
insert into #TempStatus (NewValue,UserID,id) SELECT  Newvalue, UserID, id from #PersReftempChangeLog 


Create Table #tempAllModulesClosed
(
  ClosedInUserModule int,
  UserID varchar(8)
)

insert into #tempAllModulesClosed (ClosedInUserModule, UserID)
Select count(EmplID),  H.Investigator as UserID From Empl H (NoLock) where H.sectstat in ('A','4','5','6','7','8') and 
Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1, @EndDate)) and H.Investigator is not null
group by H.Investigator	   
insert into #tempAllModulesClosed (ClosedInUserModule, UserID)
Select count(EducatID), I.Investigator as UserID From Educat I (NoLock)  where I.sectstat in ('A','4','5','6','7','8') and
Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1, @EndDate)) and I.Investigator is not null
group by I.Investigator
insert into #tempAllModulesClosed (ClosedInUserModule, UserID) 
Select count(PersRefID), J.Investigator as UserID From PersRef J (NoLock)  where J.sectstat in ('A','4','5','6','7','8') 
and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1, @EndDate)) and J.Investigator is not null 
group by J.Investigator 
Create Table #tempAllModulesPending
(
  PendingOverall int
)

insert into #tempAllModulesPending (PendingOverall) Select count(EmplID) From Empl P (NoLock) inner JOin Appl Ap (NoLock) on P.APNO = Ap.APNO  where sectstat = '9' and  Ap.ApStatus not in ('F') and CLNO not in (3468 ) 
insert into #tempAllModulesPending (PendingOverall) Select count(EducatID) From Educat Q (NoLock) inner JOin Appl Ap (NoLock) on Q.APNO = Ap.APNO  where sectstat = '9' and  Ap.ApStatus not in ('F') and CLNO not in (3468 ) 
insert into #tempAllModulesPending (PendingOverall) Select count(PersRefID) From PersRef R (NoLock) inner JOin Appl Ap (NoLock) on R.APNO = Ap.APNO  where sectstat = '9' and  Ap.ApStatus not in ('F') and CLNO not in (3468 )  

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Create Table #TempVerificationProdDetails
(
	Investigator varchar(8),
	EmplEfforts int,
	EduEfforts int,
	PresRefEfforts int,
	EmplVerificationsAssigned int,
	EduVerificationsAssigned int,
	PersRefVerificationsAssigned int,
	EmplUpdatedWebStatus int,
	EduUpdatedWebStatus int,
	PersRefUpdatedWebStatus int,
	Verified int,
	VerifiedSeeAttached int,
	UnVerifiedSeeAttached int,
	SeeAttached int,
	AlertSeeAttached int,
	EduInstClosed int,
	ClosedbyUser int, 
	ClosedInUserModule int,
	PendingAssigned int,
	PendingOverall int
)

Insert into #TempVerificationProdDetails (Investigator, EmplEfforts, EduEfforts,PresRefEfforts,
		EmplVerificationsAssigned,EduVerificationsAssigned,PersRefVerificationsAssigned,
		EmplUpdatedWebStatus, EduUpdatedWebStatus,PersRefUpdatedWebStatus,
		Verified,VerifiedSeeAttached,UnVerifiedSeeAttached,SeeAttached,AlertSeeAttached,EduInstClosed,
		ClosedbyUser, ClosedInUserModule, PendingAssigned,PendingOverall)

(Select T.UserID  Investigator, 
(select count(1) From #EmpltempChangeLog4 where  #EmpltempChangeLog4.UserID = T.UserID) [Empl Efforts],
(select count(1) From #EdutempChangeLog4 where  #EdutempChangeLog4.UserID = T.UserID) [Edu Efforts],
(select count(1) From #PersReftempChangeLog4 where  #PersReftempChangeLog4.UserID = T.UserID) [PersRef Efforts],

(Select count(1) From dbo.#Empltmp1 X (NoLock) where  (InvestigatorAssigned>= @StartDate and InvestigatorAssigned< = dateadd(s,-1,dateadd(d,1,@EndDate))) and isnull(X.Investigator,'') = isnull(T.UserID,'')) [Empl Verifications Assigned],
 0 [Edu Verifications Assigned],
 0 [PersRef Verifications Assigned],
--(Select count(1) From dbo.#Edutmp1 Y (NoLock) where  (InvestigatorAssigned>= @StartDate and InvestigatorAssigned< = dateadd(s,-1,dateadd(d,1,@EndDate))) and isnull(Y.Investigator,'') = isnull(T.UserID,'')) [Edu_Verifications_Assigned],
--(Select count(1) From dbo.#PersReftmp1 Z (NoLock) where  (InvestigatorAssigned>= @StartDate and InvestigatorAssigned< = dateadd(s,-1,dateadd(d,1,@EndDate))) and isnull(Z.Investigator,'') = isnull(T.UserID,'')) [Empl_Verifications_Assigned],

(Select count(1) From #EmpltempChangeLog2 K where  K.UserID = T.UserID) [Empl Updated WebStatus],
(Select count(1) From #EdutempChangeLog2 L where  L.UserID = T.UserID) [Edu Updated WebStatus],
(Select count(1) From #PersReftempChangeLog2 M where  M.UserID = T.UserID) [PersRef Updated WebStatus],

(Select count(1) From #TempStatus B (NoLock)  where Newvalue = '4' and isnull(B.UserID,'') = isnull(T.UserID,'')) [VERIFIED],
(Select count(1) From #TempStatus C (NoLock)  where Newvalue = '5'  and isnull(C.UserID,'') = isnull(T.UserID,'')) [VERIFIED/SEE ATTACHED],
(Select count(1) From #TempStatus D (NoLock)  where Newvalue = '6'  and isnull(D.UserID,'') = isnull(T.UserID,'')) [UNVERIFIED/SEE ATTACHED],
(Select count(1) From #TempStatus E (NoLock)  where Newvalue = '8'   and isnull(E.UserID,'') = isnull(T.UserID,'')) [SEE ATTACHED],
(Select count(1) From #TempStatus F (NoLock)  where Newvalue = '7'  and isnull(F.UserID,'') = isnull(T.UserID,'')) [ALERT/SEE ATTACHED],
(Select count(1) From #TempStatus F1 (NoLock)  where Newvalue = 'A'  and isnull(F1.UserID,'') = isnull(T.UserID,'')) [EDU INST CLOSED],
(Select count(1) From #TempStatus G (NoLock)  where G.Newvalue in ('A','4','5','6','8','7') and isnull(G.UserID,'') = isnull(T.UserID,'')) [Closed by User],
(Select Sum(ClosedInUserModule) From #tempAllModulesClosed X1 where isnull(X1.UserID,'') = isnull(T.UserID,'')) [Closed In User Module],   
(Select count(1) From #TempStatus O (NoLock)  where Newvalue = '9'  and isnull(O.UserID,'') = isnull(T.UserID,'')) [Pending Assigned],
(Select sum(PendingOverAll) From #tempAllModulesPending) [Pending Overall]
FROM #tempUsers T
Group By T.UserID)

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


Select * From #TempVerificationProdDetails

UNION ALL

Select 'Totals' Investigator, 
sum(EmplEfforts) as [Empl Efforts],
sum(EduEfforts) as [Edu Efforts],
sum(PresRefEfforts) as [PersRef Efforts],
sum(EmplVerificationsAssigned) as [Empl Verifications Assigned],
sum(EduVerificationsAssigned) as [Edu Verifications Assigned],
sum(PersRefVerificationsAssigned) as [PersRef Verifications Assigned],
sum(EmplUpdatedWebStatus) as [Empl Updated WebStatus],
sum(EduUpdatedWebStatus) as [Edu Updated WebStatus],
sum(PersRefUpdatedWebStatus) as [PersRef Updated WebStatus],
sum(Verified) as [VERIFIED],
sum(VerifiedSeeAttached) as [VERIFIED/SEE ATTACHED],
sum(UnVerifiedSeeAttached) as [UNVERIFIED/SEE ATTACHED],
sum(SeeAttached) as [SEE ATTACHED],
sum(AlertSeeAttached) as [ALERT/SEE ATTACHED],
sum(EduInstClosed) as [EDU INST CLOSED],
sum(ClosedbyUser) as [ClosedbyUser],
sum(ClosedInUserModule) as [ClosedInUserModule],
sum(PendingAssigned) as [PendingAssigned],
sum(PendingOverall) as [PendingOverall]
FROM #TempVerificationProdDetails



Drop Table #TempVerificationProdDetails
Drop Table #Edutmp1
Drop Table #EdutempChangeLog
Drop Table #EdutempChangeLog2
Drop Table #EdutempChangeLog3
Drop Table #EdutempChangeLog4
Drop Table #Empltmp1
Drop Table #EmpltempChangeLog
Drop Table #EmpltempChangeLog2
Drop Table #EmpltempChangeLog3
Drop Table #EmpltempChangeLog4
Drop Table #tempUsers
Drop Table #tempstatus
Drop Table #PersReftempChangeLog
Drop Table #PersReftempChangeLog2
Drop Table #PersReftempChangeLog3
Drop Table #PersReftempChangeLog4
Drop Table #PersRefTmp1
Drop Table #tempAllModulesClosed
Drop Table #tempAllModulesPending












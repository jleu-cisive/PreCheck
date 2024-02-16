
/*
	Modified by Radhika Dereddy on 09/10/2019 to set the date at one place add(s,-1,dateadd(d,1,@EndDate))
	EXEC Verification_Team_Production_Details_WithWN '08/02/2017','08/02/2017'
*/

CREATE PROCEDURE [dbo].[Verification_Team_Production_Details_WithWN] --'04/12/2017', '11/30/2015'

@StartDate DateTime, 
@EndDate DateTime

AS



SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
----EMPLOYMENT------
if @StartDate is null 
	set @StartDate = CAST(CURRENT_TIMESTAMP AS date)

if @EndDate+1 is null 
	set @EndDate = CAST(CURRENT_TIMESTAMP AS date) 
	
	--set @EndDate = dateadd(s,-1,dateadd(d,1,@EndDate))
--STEP:1 Empl #tempChangeLog

SELECT  distinct  v.SectStat as NewValue, (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING ( ltrim(rtrim(UserID)) ,1 , 
len(ltrim(rtrim(UserID))) -5) end) + '(WKN)' as UserID,v.emplid as id into #EmpltempChangeLogWN1
FROM  dbo.Changelog c  (nolock)
JOIN  dbo.Integration_Verification_SourceCode i (nolock) 
ON c.id = i.sectionkeyid
JOIN dbo.[Verification_RP_Logging_Empl] v (nolock)
ON i.sectionkeyid = v.emplid
WHERE (c.changedate between @StartDate and @EndDate and i.refVerificationSource = 'WorkNumber' and i.DateTimStamp between @StartDate and @EndDate)
and (c.TableName = 'Empl.web_status' and (c.NewValue in (69))) 


SELECT  distinct  c.NewValue, 
(case when len(ltrim(rtrim(c.UserID))) <=8 then ltrim(rtrim(c.UserID)) else  SUBSTRING ( ltrim(rtrim(c.UserID)) ,1 , len(ltrim(rtrim(c.UserID))) -5) end) + '(WKN)' as UserID,i.sectionkeyid as id
into #EmpltempChangeLogWN2
FROM dbo.Changelog c  (nolock) 
JOIN (
SELECT    UserID, id, Max(changedate) as changedate
FROM  dbo.Changelog (nolock)
group by userid, id, TableName
having (max(changedate) between @StartDate and @EndDate)
and (TableName = 'Empl.sectstat')
)c1
ON c.UserID = c1.UserId and c.id = c1.id and c.changedate = c1.changedate
JOIN dbo.Integration_Verification_SourceCode i (nolock) 
ON c1.id = i.sectionkeyid
WHERE (c1.changedate between @StartDate and @EndDate and i.refVerificationSource = 'WorkNumber' and i.DateTimStamp between @StartDate and @EndDate)
and (c.TableName = 'Empl.sectstat') 

SELECT NewValue, UserID, ID INTO #EmpltempChangeLog
from (
select NewValue, UserID, ID from #EmpltempChangeLogWN1 where id not in 
(select id from #EmpltempChangeLogWN2)

union
select NewValue, UserID, ID from #EmpltempChangeLogWN2
)A

--insert into #EmpltempChangeLog
SELECT  distinct  v.SectStat as NewValue, (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING ( ltrim(rtrim(UserID)) ,1 , 
len(ltrim(rtrim(UserID))) -5) end) as UserID,v.emplid as id
into #EmpltempChangeLogNOTWN1
FROM  dbo.Changelog c  (nolock)
JOIN  dbo.Integration_Verification_SourceCode i (nolock) 
ON c.id = i.sectionkeyid
JOIN dbo.[Verification_RP_Logging_Empl] v (nolock)
ON i.sectionkeyid = v.emplid
WHERE (c.changedate between @StartDate and @EndDate and i.refVerificationSource = 'WorkNumber' and i.DateTimStamp between @StartDate and @EndDate)
and (c.TableName = 'Empl.web_status' and (c.NewValue in (69))) 


--insert into #EmpltempChangeLog
SELECT    c.Newvalue,(case when len(ltrim(rtrim(c.UserID))) <=8 then ltrim(rtrim(c.UserID)) else  SUBSTRING ( ltrim(rtrim(c.UserID)) ,1 , len(ltrim(rtrim(c.UserID))) -5) end) as UserID,c.id 
into #EmpltempChangeLogNOTWN2
FROM         dbo.ChangeLog c with (nolock)
JOIN (
SELECT    UserID, id, Max(changedate) as changedate
FROM  dbo.Changelog (nolock)
group by userid, id, TableName
having (max(changedate) between @StartDate and @EndDate)
and (TableName = 'Empl.sectstat')
)c1
ON c.UserID = c1.UserId and c.id = c1.id and c.changedate = c1.changedate
WHERE     (c.TableName = 'Empl.SectStat') and c.UserID <> ''
and c.ChangeDate between @StartDate and @EndDate
order by c.UserID

insert into #EmpltempChangeLog
SELECT NewValue, UserID, ID 
from (
select NewValue, UserID, ID from #EmpltempChangeLogNOTWN1 where id not in 
(select id from #EmpltempChangeLogNOTWN2)

union
select NewValue, UserID, ID from #EmpltempChangeLogNOTWN2
)B


select UserID into #tempUsers1 from #EmpltempChangeLog 


--STEP:2 Empl #tmp1
Select ltrim(rtrim(investigator)) + '(WKN)' as Investigator,InvestigatorAssigned,web_Updated,sectstat,apno,emplid into #Empltmp1
From dbo.Empl with (nolock)
Where ((InvestigatorAssigned>= @StartDate and InvestigatorAssigned< = @EndDate)
OR (Last_Worked>= @StartDate and Last_Worked< =@EndDate))
and emplid in (
SELECT sectionkeyid
FROM         dbo.Integration_Verification_SourceCode
WHERE    (DateTimStamp between @StartDate and @EndDate and refVerificationSource = 'WorkNumber' and DateTimStamp between @StartDate and @EndDate)
)

set IDENTITY_INSERT #Empltmp1 on
insert into #Empltmp1(Investigator,InvestigatorAssigned,web_Updated,sectstat,apno,emplid )
Select ltrim(rtrim(investigator)) as Investigator, InvestigatorAssigned,web_Updated,sectstat,apno,emplid 
From dbo.Empl with (nolock)
Where ((InvestigatorAssigned>= @StartDate and InvestigatorAssigned< = @EndDate)
OR (Last_Worked>= @StartDate and Last_Worked< = @EndDate))
order by Investigator asc

select Investigator as UserID into #tempUsers2 from #Empltmp1

--STEP:3 Empl #tempChangeLog2
SELECT distinct (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING ( ltrim(rtrim(UserID)) ,1 , len(ltrim(rtrim(UserID))) -5) end) + '(WKN)' as UserID,id into #EmpltempChangeLog2
FROM         dbo.ChangeLog where
TableName =  'Empl.web_status'
and  ChangeDate between @StartDate and @EndDate
and Newvalue <> 0 and UserID <> ''
and id in (
SELECT sectionkeyid
FROM         dbo.Integration_Verification_SourceCode
WHERE     (DateTimStamp between @StartDate and @EndDate and refVerificationSource = 'WorkNumber' and DateTimStamp between @StartDate and @EndDate)
)

insert into #EmpltempChangeLog2
SELECT distinct (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING ( ltrim(rtrim(UserID)) ,1 , len(ltrim(rtrim(UserID))) -5) end) as UserID, id
FROM         dbo.ChangeLog where
TableName =  'Empl.web_status'
and  ChangeDate between @StartDate and @EndDate
and Newvalue <> 0 and UserID <> ''
order by UserID

select UserID into #tempUsers3 from #EmpltempChangeLog2


--STEP:4 Empl #tempChangeLog3
SELECT    (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING ( ltrim(rtrim(UserID)) ,1 , len(ltrim(rtrim(UserID))) -5) end) + '(WKN)' as UserID,id into #EmpltempChangeLog3
FROM         dbo.ChangeLog where
--(TableName like  'Empl.%' or UserID like '%-empl')
UserID like '%-empl'
and  ChangeDate between @StartDate and @EndDate
and UserID <> ''
and id in (
SELECT sectionkeyid
FROM         dbo.Integration_Verification_SourceCode
WHERE     (DateTimStamp between @StartDate and @EndDate and refVerificationSource = 'WorkNumber' and DateTimStamp between @StartDate and @EndDate)
)


Insert into #EmpltempChangeLog3
SELECT    (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING ( ltrim(rtrim(UserID)) ,1 , len(ltrim(rtrim(UserID))) -5) end) as UserID,id
FROM         dbo.ChangeLog where
--(TableName like  'Empl.%' or UserID like '%-empl')
UserID like '%-empl'
and  ChangeDate between @StartDate and @EndDate
and UserID <> ''
order by UserID

select UserID into #tempUsers4 from #EmpltempChangeLog3

--STEP:5 Epml #tempChangeLog4
Select  distinct id,UserID into #EmpltempChangeLog4 From #EmpltempChangeLog3 

--STEP:6 Empl #tempUsers
Select distinct UserID into #tempUsers5 from Users Where Empl = 1 OR Educat =1 OR PersRef = 1 and Disabled = 0 and CAM = 0 
order by UserID

Select distinct A.UserID as UserID into #tempUsers from 
(
Select UserID from #tempUsers1
union Select  UserID from #tempUsers2
union Select  UserID from #tempUsers3
union Select  UserID from #tempUsers4
union Select  UserID from #tempUsers5
)A

--,#tempUsers2,#tempUsers3,#tempUsers4,#tempUsers5
----------------------------------------------------------------------


----EDUCATION-----------------

--STEP:1 Edu #tempChangeLog
SELECT    Newvalue,UserID, id into #EdutempChangeLog
FROM         dbo.ChangeLog
WHERE     (TableName = 'Educat.SectStat')
and ChangeDate between @StartDate and @EndDate
order by UserID

--STEP:2 Edu #tmp1
Select Investigator,
web_Updated,sectstat into #Edutmp1
From dbo.Educat (NoLock)
Where (Last_Worked>= @StartDate and Last_Worked< = @EndDate)
order by Investigator asc

--STEP:3 Edu #tempChangeLog2
SELECT    Newvalue,UserID,id into #EdutempChangeLog2
FROM         dbo.ChangeLog where
TableName =  'Educat.web_status'
and  ChangeDate between @StartDate and @EndDate
and Newvalue <> 0 
order by UserID

--STEP:4 Edu #tempChangeLog3
SELECT     (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING ( ltrim(rtrim(UserID)) ,1 , len(ltrim(rtrim(UserID))) -7) end) as UserID,id into #EdutempChangeLog3
FROM         dbo.ChangeLog where
--TableName like  'Educat.%'
( UserID like '%-educat')
and  ChangeDate between @StartDate and @EndDate
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
and ChangeDate between @StartDate and @EndDate
order by UserID


--STEP:2 Persref #tmp1
Select Investigator,
web_Updated,sectstat into #PersReftmp1
From dbo.PersRef (NoLock)
Where (Last_Worked>= @StartDate and Last_Worked< = @EndDate)
order by Investigator asc

--STEP:3 Persref #tempChangeLog2
SELECT    Newvalue,UserID,id into #PersReftempChangeLog2
FROM         dbo.ChangeLog where
TableName =  'PersRef.web_status'
and  ChangeDate between @StartDate and @EndDate
and Newvalue <> 0 
order by UserID

--STEP:4 Persref #tempChangeLog3
SELECT    (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING ( ltrim(rtrim(UserID)) ,1 , len(ltrim(rtrim(UserID))) -8) end) as UserID,id into #PersReftempChangeLog3
FROM         dbo.ChangeLog where
TableName like  'PersRef.%'
--( UserID like '%-persref')
and  ChangeDate between @StartDate and @EndDate
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

create table #PersRefTempStatus 
( 
   NewValue varchar(8000),
   UserID varchar(50),
   id int
)
insert into #PersRefTempStatus (NewValue,UserID,id) SELECT  Newvalue, UserID, id from #PersReftempChangeLog 


Create Table #tempAllModulesClosed
(
  ClosedInUserModule int,
  UserID varchar(8)
)

insert into #tempAllModulesClosed (ClosedInUserModule, UserID)
Select count(EmplID),  H.Investigator as UserID From Empl H (NoLock) where H.sectstat in ('A','4','5','6','7','8') and 
Last_Worked>= @StartDate and Last_Worked< = @EndDate and H.Investigator is not null
group by H.Investigator	   
insert into #tempAllModulesClosed (ClosedInUserModule, UserID)
Select count(EducatID), I.Investigator as UserID From Educat I (NoLock)  where I.sectstat in ('A','4','5','6','7','8') and
Last_Worked>= @StartDate and Last_Worked< = @EndDate and I.Investigator is not null
group by I.Investigator

Create Table #tempPersRefModuleClosed
(
  ClosedInUserModule int,
  UserID varchar(8)
)

insert into #tempPersRefModuleClosed (ClosedInUserModule, UserID) 
Select count(PersRefID), J.Investigator as UserID From PersRef J (NoLock)  where J.sectstat in ('A','4','5','6','7','8') 
and Last_Worked>= @StartDate and Last_Worked< = @EndDate and J.Investigator is not null 
group by J.Investigator  

Create Table #tempAllModulesPending
(
  PendingOverall int
)

insert into #tempAllModulesPending (PendingOverall) Select count(EmplID) From Empl P (NoLock) inner JOin Appl Ap (NoLock) on P.APNO = Ap.APNO  where sectstat = '9' and  Ap.ApStatus not in ('F') and CLNO not in (3468 ) 
insert into #tempAllModulesPending (PendingOverall) Select count(EducatID) From Educat Q (NoLock) inner JOin Appl Ap (NoLock) on Q.APNO = Ap.APNO  where sectstat = '9' and  Ap.ApStatus not in ('F') and CLNO not in (3468 ) 

Create Table #tempPersRefModulePending
(
  PendingOverall int
)

insert into #tempPersRefModulePending (PendingOverall) Select count(PersRefID) From PersRef R (NoLock) inner JOin Appl Ap (NoLock) on R.APNO = Ap.APNO  where sectstat = '9' and  Ap.ApStatus not in ('F') and CLNO not in (3468 )  

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Create Table #TempVerificationProdDetails
(
	Investigator varchar(20),
	EmplEfforts int,
	EduEfforts int,
	PresRefEfforts int,
	EmplVerificationsAssigned int,
	EduVerificationsAssigned int,
	PersRefVerificationsAssigned int,
	EmplUpdatedWebStatus int,
	EduUpdatedWebStatus int,
	PersRefUpdatedWebStatus int,
	PersRefVerifiedSeeAttached int,
	PersRefUnVerifiedSeeAttached int,
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
		EmplUpdatedWebStatus, EduUpdatedWebStatus,PersRefUpdatedWebStatus,PersRefVerifiedSeeAttached,PersRefUnVerifiedSeeAttached,
		Verified,VerifiedSeeAttached,UnVerifiedSeeAttached,SeeAttached,AlertSeeAttached,EduInstClosed,
		ClosedbyUser, ClosedInUserModule, PendingAssigned,PendingOverall)

(Select T.UserID  Investigator, 
(select count(1) From #EmpltempChangeLog4 where  #EmpltempChangeLog4.UserID = T.UserID) [Empl Efforts],
(select count(1) From #EdutempChangeLog4 where  #EdutempChangeLog4.UserID = T.UserID) [Edu Efforts],
(select count(1) From #PersReftempChangeLog4 where  #PersReftempChangeLog4.UserID = T.UserID) [PersRef Efforts],

(Select count(1) From dbo.#Empltmp1 X (NoLock) where  (InvestigatorAssigned>= @StartDate and InvestigatorAssigned< = @EndDate) and isnull(X.Investigator,'') = isnull(T.UserID,'')) [Empl Verifications Assigned],
 0 [Edu Verifications Assigned],
 0 [PersRef Verifications Assigned],

(Select count(1) From #EmpltempChangeLog2 K where  K.UserID = T.UserID) [Empl Updated WebStatus],
(Select count(1) From #EdutempChangeLog2 L where  L.UserID = T.UserID) [Edu Updated WebStatus],
(Select count(1) From #PersReftempChangeLog2 M where  M.UserID = T.UserID) [PersRef Updated WebStatus],

(Select count(1) From #PersRefTempStatus x (NoLock)  where Newvalue = '5'  and isnull(x.UserID,'') = isnull(T.UserID,'')) [Pers Ref - VERIFIED/SEE ATTACHED],
(Select count(1) From #PersRefTempStatus y (NoLock)  where Newvalue = '6'  and isnull(y.UserID,'') = isnull(T.UserID,'')) [Pers ref - UNVERIFIED/SEE ATTACHED],

(Select count(1) From #TempStatus B (NoLock)  where Newvalue = '4' and isnull(B.UserID,'') = isnull(T.UserID,'')) [VERIFIED],
(Select count(1) From #TempStatus C (NoLock)  where Newvalue = '5'  and isnull(C.UserID,'') = isnull(T.UserID,'')) [VERIFIED/SEE ATTACHED],
(Select count(1) From #TempStatus D (NoLock)  where Newvalue = '6'  and isnull(D.UserID,'') = isnull(T.UserID,'')) [UNVERIFIED/SEE ATTACHED],
(Select count(1) From #TempStatus E (NoLock)  where Newvalue = '8'   and isnull(E.UserID,'') = isnull(T.UserID,'')) [SEE ATTACHED],
(Select count(1) From #TempStatus F (NoLock)  where Newvalue = '7'  and isnull(F.UserID,'') = isnull(T.UserID,'')) [ALERT/SEE ATTACHED],
(Select count(1) From #TempStatus F1 (NoLock)  where Newvalue = 'A'  and isnull(F1.UserID,'') = isnull(T.UserID,'')) [EDU INST CLOSED],
(Select count(1) From #TempStatus G (NoLock)  where G.Newvalue in ('A','4','5','6','8','7') and isnull(G.UserID,'') = isnull(T.UserID,'')) [Closed by User],
(Select Sum(ClosedInUserModule) from #tempAllModulesClosed X1 where isnull(X1.UserID,'') = isnull(T.UserID,'')) [Closed In User Module],   
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
sum(PersRefVerifiedSeeAttached) as [PersRef Updated WebStatus],
sum(PersRefUnVerifiedSeeAttached) as [Pers Ref - VERIFIED/SEE ATTACHED],
sum(PersRefUpdatedWebStatus) as [Pers Ref - UNVERIFIED/SEE ATTACHED],
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

UNION ALL

Select 'WNTotals' Investigator, 
sum(EmplEfforts) as [Empl Efforts],
sum(EduEfforts) as [Edu Efforts],
sum(PresRefEfforts) as [PersRef Efforts],
sum(EmplVerificationsAssigned) as [Empl Verifications Assigned],
sum(EduVerificationsAssigned) as [Edu Verifications Assigned],
sum(PersRefVerificationsAssigned) as [PersRef Verifications Assigned],
sum(EmplUpdatedWebStatus) as [Empl Updated WebStatus],
sum(EduUpdatedWebStatus) as [Edu Updated WebStatus],
sum(PersRefUpdatedWebStatus) as [PersRef Updated WebStatus],
sum(PersRefUnVerifiedSeeAttached) as [Pers Ref - VERIFIED/SEE ATTACHED],
sum(PersRefUpdatedWebStatus) as [Pers Ref - UNVERIFIED/SEE ATTACHED],
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
Where Investigator like '%(WKN)'



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

Drop Table #tempUsers1
Drop Table #tempUsers2
Drop Table #tempUsers3
Drop Table #tempUsers4
Drop Table #tempUsers5

Drop Table #EmpltempChangeLogWN1
Drop Table #EmpltempChangeLogWN2
Drop Table #EmpltempChangeLogNOTWN1
Drop Table #EmpltempChangeLogNOTWN2


DROP TABLE #PersRefTempStatus
DROP TABLE #tempPersRefModuleClosed
DROP TABLE #tempPersRefModulePending


	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT Off;
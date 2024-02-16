


-- Verification_Team_Production_Details_WithWN '11/17/2015', '11/17/2015'
CREATE  PROCEDURE [dbo].[Verification_Team_Production_Details_Empl] --'11/30/2015', '11/30/2015'

@StartDate DateTime = null	,
@EndDate DateTime = null	

AS
SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
----EMPLOYMENT------
if @StartDate is null 
	set @StartDate = CAST(CURRENT_TIMESTAMP AS date)

if @EndDate is null 
	set @EndDate = CAST(CURRENT_TIMESTAMP AS date)

	set @EndDate = dateadd(s,-1,dateadd(d,1,@EndDate))
--STEP:1 Empl #tempChangeLog

SELECT  distinct  v.SectStat as NewValue, (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING ( ltrim(rtrim(UserID)) ,1 , 
len(ltrim(rtrim(UserID))) -5) end) + '(WKN)' as UserID,v.emplid as id into #EmpltempChangeLogWN1
FROM  dbo.Changelog c  (nolock)
JOIN  dbo.Integration_Verification_SourceCode i (nolock) 
ON c.id = i.sectionkeyid
JOIN dbo.[Verification_RP_Logging_Empl] v (nolock)
ON i.sectionkeyid = v.emplid
WHERE (c.changedate between @StartDate and @EndDate and i.refVerificationSource = 'WorkNumber')
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
WHERE (c1.changedate between @StartDate and @EndDate and i.refVerificationSource = 'WorkNumber')
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
WHERE (c.changedate between @StartDate and @EndDate and i.refVerificationSource = 'WorkNumber')
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
OR (Last_Worked>= @StartDate and Last_Worked< = @EndDate))
and emplid in (
SELECT sectionkeyid
FROM         dbo.Integration_Verification_SourceCode
WHERE    (DateTimStamp between @StartDate and @EndDate and refVerificationSource = 'WorkNumber')
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
WHERE     (DateTimStamp between @StartDate and @EndDate and refVerificationSource = 'WorkNumber')
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
TableName like  'Empl.%' and UserID like '%-empl'
and  ChangeDate between @StartDate and @EndDate
and UserID <> ''
and id in (
SELECT sectionkeyid
FROM         dbo.Integration_Verification_SourceCode
WHERE     (DateTimStamp between @StartDate and @EndDate and refVerificationSource = 'WorkNumber')
)


Insert into #EmpltempChangeLog3
SELECT    (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING ( ltrim(rtrim(UserID)) ,1 , len(ltrim(rtrim(UserID))) -5) end) as UserID,id
FROM         dbo.ChangeLog where
TableName like  'Empl.%' and UserID like '%-empl'
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
create table #TempStatus 
( 
   NewValue varchar(8000),
   UserID varchar(50),
   id int
) 

insert into #TempStatus (NewValue,UserID,id) SELECT  Newvalue, UserID, id from #EmpltempChangeLog

Create Table #tempAllModulesClosed
(
  ClosedInUserModule int,
  UserID varchar(8)
)

insert into #tempAllModulesClosed (ClosedInUserModule, UserID)
Select count(EmplID),  H.Investigator as UserID From Empl H (NoLock) where H.sectstat in ('A','4','5','6','7','8') and 
Last_Worked>= @StartDate and Last_Worked< =@EndDate and H.Investigator is not null
group by H.Investigator	   

Create Table #tempAllModulesPending
(
  PendingOverall int
)

insert into #tempAllModulesPending (PendingOverall) Select count(EmplID) From Empl P (NoLock) inner JOin Appl Ap (NoLock) on P.APNO = Ap.APNO  where sectstat = '9' and  Ap.ApStatus not in ('F') and CLNO not in (3468 ) 

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
NULL [Edu Efforts],
NULL [PersRef Efforts],

(Select count(1) From dbo.#Empltmp1 X (NoLock) where  (InvestigatorAssigned>= @StartDate and InvestigatorAssigned< = @EndDate) and isnull(X.Investigator,'') = isnull(T.UserID,'')) [Empl Verifications Assigned],
 0 [Edu Verifications Assigned],
 0 [PersRef Verifications Assigned],

(Select count(1) From #EmpltempChangeLog2 K where  K.UserID = T.UserID) [Empl Updated WebStatus],
NULL [Edu Updated WebStatus],
NULL [PersRef Updated WebStatus],

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
Drop Table #Empltmp1
Drop Table #EmpltempChangeLog
Drop Table #EmpltempChangeLog2
Drop Table #EmpltempChangeLog3
Drop Table #EmpltempChangeLog4
Drop Table #tempUsers
Drop Table #tempstatus
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



	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT Off;

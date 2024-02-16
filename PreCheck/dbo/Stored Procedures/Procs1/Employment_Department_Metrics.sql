/*
-- =============================================
-- Author:	Prasanna 
-- Create date: 05/11/2020
-- Description:Copied & Modified SP Verification_Team_Production_Details_WithWorkNumber
-- Modified by Radhika Dereddy to add Education Efforts on 07/12/2021
-- EXEC [Employment_Department_Metrics] '06/09/2021','06/09/2021'
--------------------------------------------------
-- Modified By: Vairavan A
-- Modified Date: 08/16/2022
-- Description: Ticketno-57455 Employment Department Metrics
-- EXEC [Employment_Department_Metrics] '08/01/2022','08/10/2022'
-----------------------------------------------
-- =============================================
*/

CREATE PROC dbo.Employment_Department_Metrics
@StartDate DateTime,
@EndDate DateTime

AS


SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SET @EndDate = dateadd(s,-1,dateadd(d,1,@EndDate)) 


--STEP:1 Empl #tempChangeLog

SELECT  distinct  v.SectStat as NewValue, (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING ( ltrim(rtrim(UserID)) ,1 , 
len(ltrim(rtrim(UserID))) -5) end) + '(WKN)' as UserID,v.emplid as id into #EmpltempChangeLogWN1
FROM  dbo.Changelog c with(nolock)
JOIN  dbo.Integration_Verification_SourceCode i with(nolock) ON c.id = i.sectionkeyid
JOIN dbo.[Verification_RP_Logging_Empl] v  with(nolock) ON i.sectionkeyid = v.emplid
WHERE (c.changedate between @StartDate and @EndDate and i.refVerificationSource = 'WorkNumber' and i.DateTimStamp between @StartDate and @EndDate)
and (c.TableName = 'Empl.web_status' and (c.NewValue in (69))) 


SELECT  distinct  c.NewValue, 
(case when len(ltrim(rtrim(c.UserID))) <=8 then ltrim(rtrim(c.UserID)) else  SUBSTRING ( ltrim(rtrim(c.UserID)) ,1 , len(ltrim(rtrim(c.UserID))) -5) end) + '(WKN)' as UserID,i.sectionkeyid as id
into #EmpltempChangeLogWN2
FROM dbo.Changelog c with(nolock)
JOIN (
		SELECT    UserID, id, Max(changedate) as changedate
		FROM  dbo.Changelog with(nolock)
		group by userid, id, TableName
		having (max(changedate) between @StartDate and @EndDate)
		and (TableName = 'Empl.sectstat')
	)c1 ON c.UserID = c1.UserId and c.id = c1.id and c.changedate = c1.changedate
JOIN dbo.Integration_Verification_SourceCode i with(nolock) ON c1.id = i.sectionkeyid
WHERE (c1.changedate between @StartDate and @EndDate and i.refVerificationSource = 'WorkNumber' and i.DateTimStamp between @StartDate and @EndDate)
and (c.TableName = 'Empl.sectstat') 

SELECT NewValue, UserID, ID INTO #EmpltempChangeLog
from (
		select NewValue, UserID, ID from #EmpltempChangeLogWN1 with(nolock) where id not in (select id from #EmpltempChangeLogWN2)
		union
		select NewValue, UserID, ID from #EmpltempChangeLogWN2 with(nolock)
	)A

--insert into #EmpltempChangeLog
SELECT  distinct  v.SectStat as NewValue, (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING ( ltrim(rtrim(UserID)) ,1 , 
len(ltrim(rtrim(UserID))) -5) end) as UserID,v.emplid as id
into #EmpltempChangeLogNOTWN1
FROM  dbo.Changelog c  with(nolock)
JOIN  dbo.Integration_Verification_SourceCode i with(nolock) ON c.id = i.sectionkeyid
JOIN dbo.[Verification_RP_Logging_Empl] v with(nolock) ON i.sectionkeyid = v.emplid
WHERE (c.changedate between @StartDate and @EndDate and i.refVerificationSource = 'WorkNumber' and i.DateTimStamp between @StartDate and @EndDate)
and (c.TableName = 'Empl.web_status' and (c.NewValue in (69))) 


--insert into #EmpltempChangeLog
SELECT    c.Newvalue,(case when len(ltrim(rtrim(c.UserID))) <=8 then ltrim(rtrim(c.UserID)) else  SUBSTRING ( ltrim(rtrim(c.UserID)) ,1 , len(ltrim(rtrim(c.UserID))) -5) end) as UserID,c.id 
into #EmpltempChangeLogNOTWN2
FROM         dbo.ChangeLog c with (nolock)
JOIN (
		SELECT    UserID, id, Max(changedate) as changedate
		FROM  dbo.Changelog with(nolock)
		group by userid, id, TableName
		having (max(changedate) between @StartDate and @EndDate)
		and (TableName = 'Empl.sectstat')
	)c1 ON c.UserID = c1.UserId and c.id = c1.id and c.changedate = c1.changedate
WHERE     (c.TableName = 'Empl.SectStat') and c.UserID <> ''
and c.ChangeDate between @StartDate and @EndDate
order by c.UserID

insert into #EmpltempChangeLog
SELECT NewValue, UserID, ID 
from (
		select NewValue, UserID, ID from #EmpltempChangeLogNOTWN1 with(nolock) where id not in (select id from #EmpltempChangeLogNOTWN2)
		union
		select NewValue, UserID, ID from #EmpltempChangeLogNOTWN2 with(nolock)
)B


select UserID into #tempUsers1 from #EmpltempChangeLog 


--STEP:2 Empl #tmp1
Select ltrim(rtrim(investigator)) + '(WKN)' as Investigator,InvestigatorAssigned,web_Updated,sectstat,apno,emplid into #Empltmp1
From dbo.Empl with (nolock)
Where ((InvestigatorAssigned>= @StartDate and InvestigatorAssigned< = @EndDate)
OR (Last_Worked>= @StartDate and Last_Worked< = @EndDate))
and emplid in (
				SELECT sectionkeyid
				FROM  dbo.Integration_Verification_SourceCode with(nolock)
				WHERE refVerificationSource = 'WorkNumber' and DateTimStamp between @StartDate and @EndDate
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
FROM  dbo.ChangeLog with(nolock) 
where TableName =  'Empl.web_status'
and  ChangeDate between @StartDate and @EndDate
and Newvalue <> 0 and UserID <> ''
and id in (
			SELECT sectionkeyid
			FROM  dbo.Integration_Verification_SourceCode with(nolock)
			WHERE refVerificationSource = 'WorkNumber' and DateTimStamp between @StartDate and @EndDate
		  )

insert into #EmpltempChangeLog2
SELECT distinct (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING ( ltrim(rtrim(UserID)) ,1 , len(ltrim(rtrim(UserID))) -5) end) as UserID, id
FROM  dbo.ChangeLog with(nolock) where
TableName =  'Empl.web_status'
and  ChangeDate between @StartDate and @EndDate
and Newvalue <> 0 and UserID <> ''
order by UserID

select UserID into #tempUsers3 from #EmpltempChangeLog2


--STEP:4 Empl #tempChangeLog3
SELECT (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING ( ltrim(rtrim(UserID)) ,1 , len(ltrim(rtrim(UserID))) -5) end) + '(WKN)' as UserID,id into #EmpltempChangeLog3
FROM dbo.ChangeLog with(nolock) where
UserID like '%-empl'
and  ChangeDate between @StartDate and @EndDate
and UserID <> ''
and id in (
			SELECT sectionkeyid
			FROM  dbo.Integration_Verification_SourceCode with(nolock)
			WHERE refVerificationSource = 'WorkNumber' and DateTimStamp between @StartDate and @EndDate
		  )


Insert into #EmpltempChangeLog3
SELECT (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING ( ltrim(rtrim(UserID)) ,1 , len(ltrim(rtrim(UserID))) -5) end) as UserID,id
FROM         dbo.ChangeLog with(nolock) where
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
	union
Select  UserID from #tempUsers2
	union 
Select  UserID from #tempUsers3
	union 
Select  UserID from #tempUsers4
	union 
Select  UserID from #tempUsers5
)A

--,#tempUsers2,#tempUsers3,#tempUsers4,#tempUsers5
----------------------------------------------------------------------


----EDUCATION-----------------

--STEP:1 Edu #tempChangeLog
SELECT    Newvalue,UserID, id into #EdutempChangeLog
FROM   dbo.ChangeLog with(nolock)
WHERE     (TableName = 'Educat.SectStat')
and ChangeDate between @StartDate and @EndDate
order by UserID

--STEP:2 Edu #tmp1
Select Investigator,
web_Updated,sectstat into #Edutmp1
From dbo.Educat with(nolock)
Where (Last_Worked>= @StartDate and Last_Worked< = @EndDate)
order by Investigator asc

--STEP:3 Edu #tempChangeLog2
SELECT    Newvalue,UserID,id into #EdutempChangeLog2
FROM         dbo.ChangeLog with(nolock)  where
TableName =  'Educat.web_status'
and  ChangeDate between @StartDate and @EndDate
and Newvalue <> 0 
order by UserID

--STEP:4 Edu #tempChangeLog3
SELECT     (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING ( ltrim(rtrim(UserID)) ,1 , len(ltrim(rtrim(UserID))) -7) end) as UserID,id into #EdutempChangeLog3
FROM         dbo.ChangeLog with(nolock) where
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
FROM         dbo.ChangeLog with(nolock)
WHERE     (TableName = 'PersRef.SectStat')
and ChangeDate between @StartDate and @EndDate
order by UserID


--STEP:2 Persref #tmp1
Select Investigator,
web_Updated,sectstat into #PersReftmp1
From dbo.PersRef with(nolock)
Where (Last_Worked>= @StartDate and Last_Worked< = @EndDate)
order by Investigator asc

--STEP:3 Persref #tempChangeLog2
SELECT    Newvalue,UserID,id into #PersReftempChangeLog2
FROM         dbo.ChangeLog with(nolock) where
TableName =  'PersRef.web_status'
and  ChangeDate between @StartDate and @EndDate
and Newvalue <> 0 
order by UserID

--STEP:4 Persref #tempChangeLog3
SELECT    (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING ( ltrim(rtrim(UserID)) ,1 , len(ltrim(rtrim(UserID))) -8) end) as UserID,id into #PersReftempChangeLog3
FROM         dbo.ChangeLog with(nolock) where
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
Select count(EmplID),  H.Investigator as UserID From Empl H with(nolock) where H.sectstat in ('A','4','5','6','7','8','U','C') and 
Last_Worked>= @StartDate and Last_Worked< =@EndDate and H.Investigator is not null
group by H.Investigator	   
insert into #tempAllModulesClosed (ClosedInUserModule, UserID)
Select count(EducatID), I.Investigator as UserID From Educat I with(nolock)  where I.sectstat in ('A','4','5','6','7','8','U','C') and
Last_Worked>= @StartDate and Last_Worked< = @EndDate and I.Investigator is not null
group by I.Investigator

Create Table #tempPersRefModuleClosed
(
  ClosedInUserModule int,
  UserID varchar(8)
)

insert into #tempPersRefModuleClosed (ClosedInUserModule, UserID) 
Select count(PersRefID), J.Investigator as UserID From PersRef J with(nolock)  where J.sectstat in ('A','4','5','6','7','8','U','C') 
and Last_Worked>= @StartDate and Last_Worked< = @EndDate and J.Investigator is not null 
group by J.Investigator  

Create Table #tempAllModulesPending
(
  PendingOverall int
)

insert into #tempAllModulesPending (PendingOverall) Select count(EmplID) From Empl P with(nolock) inner JOin Appl Ap with(nolock) on P.APNO = Ap.APNO  where sectstat = '9' and  Ap.ApStatus not in ('F') and CLNO not in (3468 ) 
insert into #tempAllModulesPending (PendingOverall) Select count(EducatID) From Educat Q with(nolock) inner JOin Appl Ap with(nolock) on Q.APNO = Ap.APNO  where sectstat = '9' and  Ap.ApStatus not in ('F') and CLNO not in (3468 ) 

Create Table #tempPersRefModulePending
(
  PendingOverall int
)

insert into #tempPersRefModulePending (PendingOverall) Select count(PersRefID) From PersRef R with(nolock) inner JOin Appl Ap with(nolock) on R.APNO = Ap.APNO  where sectstat = '9' and  Ap.ApStatus not in ('F') and CLNO not in (3468 )  

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Create Table #TempVerificationProdDetails
(
	Investigator varchar(20),
	EmplEfforts int,
	EduEfforts int,
	PresRefEfforts int,
	PersRefVerifiedSeeAttached int,
	PersRefUnVerifiedSeeAttached int,
	Verified int,
	UnVerified int,
	SeeAttached int,
	Alert int,
	ClosedbyUser int
	
)

Insert into #TempVerificationProdDetails (Investigator, EmplEfforts, EduEfforts, PresRefEfforts,
		PersRefVerifiedSeeAttached,PersRefUnVerifiedSeeAttached,
		Verified,UnVerified,SeeAttached,Alert, 
		ClosedbyUser)

(Select T.UserID  Investigator, 
(select count(1) From #EmpltempChangeLog4 where  #EmpltempChangeLog4.UserID = T.UserID) [Empl Efforts],

(select count(1) From #EdutempChangeLog4 where  #EdutempChangeLog4.UserID = T.UserID) [Edu Efforts],

(select count(1) From #PersReftempChangeLog4 where  #PersReftempChangeLog4.UserID = T.UserID) [PersRefEffort's],


(select Sum(verified) as PersRefVerified from(
(Select count(1) as verified From #PersRefTempStatus B (NoLock)  where Newvalue = '4' and isnull(B.UserID,'') = isnull(T.UserID,''))
UNION ALL
(Select count(1) as verified From #PersRefTempStatus C (NoLock)  where Newvalue = '5' and isnull(C.UserID,'') = isnull(T.UserID,''))
)pv),

(select Sum(verified) as [PersRefUnVerified] from(
(Select count(1) as verified From #PersRefTempStatus B (NoLock)  where Newvalue = 'U' and isnull(B.UserID,'') = isnull(T.UserID,''))
UNION ALL
(Select count(1) as verified From #PersRefTempStatus C (NoLock)  where Newvalue = '6' and isnull(C.UserID,'') = isnull(T.UserID,''))
)puv),

(select Sum(verified) as total_Verified from(
(Select count(1) as verified From #TempStatus B (NoLock)  where Newvalue = '4' and isnull(B.UserID,'') = isnull(T.UserID,'')) 
UNION ALL
(Select count(1) as verified From #TempStatus C (NoLock)  where Newvalue = '5' and isnull(C.UserID,'') = isnull(T.UserID,''))
)v),

(select Sum(UnVerified) as total_unVerified from(
(Select count(1) as UnVerified From #TempStatus G (NoLock)  where Newvalue = 'U' and isnull(G.UserID,'') = isnull(T.UserID,'')) 
UNION ALL
(Select count(1) as UnVerified From #TempStatus D (NoLock)  where Newvalue = '6'  and isnull(D.UserID,'') = isnull(T.UserID,''))
)uv),

(Select count(1) From #TempStatus E (NoLock)  where Newvalue = '8'   and isnull(E.UserID,'') = isnull(T.UserID,'')) [SEE ATTACHED],

(select Sum(Alert) as total_Alert from(
(Select count(1) as Alert From #TempStatus H (NoLock)  where Newvalue = 'C' and isnull(H.UserID,'') = isnull(T.UserID,'')) 
UNION ALL
(Select count(1) as Alert From #TempStatus F (NoLock)  where Newvalue = '7'  and isnull(F.UserID,'') = isnull(T.UserID,''))
)a),


(Select count(1) From #TempStatus G (NoLock)  where G.Newvalue in ('A','4','5','6','8','7','U','C') and isnull(G.UserID,'') = isnull(T.UserID,'')) [Closed by User]

FROM #tempUsers T
Group By T.UserID)

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



--Code added for ticket id - 57455  starts here 
Create Table #TempVerificationProdDetails_temp
(
	Investigator varchar(20),
	EmplEfforts int,
	EduEfforts int,
	PresRefEfforts int,
	PersRefVerifiedSeeAttached int,
	PersRefUnVerifiedSeeAttached int,
	Verified int,
	UnVerified int,
	SeeAttached int,
	Alert int,
	ClosedbyUser int
	
)

Insert into #TempVerificationProdDetails_temp (Investigator, EmplEfforts, EduEfforts, PresRefEfforts,
		PersRefVerifiedSeeAttached,PersRefUnVerifiedSeeAttached,
		Verified,UnVerified,SeeAttached,Alert, 
		ClosedbyUser)
 
Select Investigator,
		sum(EmplEfforts) as EmplEfforts ,
		sum(EduEfforts) as EduEfforts,
		sum(PresRefEfforts) as PresRefEfforts ,
		sum(PersRefVerifiedSeeAttached) as PersRefVerifiedSeeAttached,
		sum(PersRefUnVerifiedSeeAttached) as PersRefUnVerifiedSeeAttached,
		sum(Verified) as Verified,
		sum(UnVerified) as UnVerified,
		sum(SeeAttached) as  UnVerified,
		sum(Alert) as Alert,
		sum(ClosedbyUser) as ClosedbyUser 
From #TempVerificationProdDetails
group by   Investigator 
--Code added for ticket id - 57455  ends here 

Select *
--From #TempVerificationProdDetails --Code commented for ticket id - 57455 
From #TempVerificationProdDetails_temp --Code added for ticket id - 57455 
where Investigator in(select userid from Users where empl=1 
and userid not in('ARefChex','Employ1','EMPLOYCH','Overseas','SJV','THORNGRE','TRAINING','MRobins','Cisive','KHunt'))


UNION ALL

Select 'Totals' Investigator, 
sum(EmplEfforts) as [Empl Efforts],
sum(EduEfforts) as [Edu Efforts],
sum(PresRefEfforts) as [PersRef Efforts],
sum(PersRefVerifiedSeeAttached) as [PersRef - Verified/See Attached],
sum(PersRefUnVerifiedSeeAttached) as [Pers Ref - UNVERIFIED/SEE ATTACHED],
sum(Verified) as [VERIFIED],
sum(UNVERIFIED) as [UNVERIFIED/SEE ATTACHED],
sum(SeeAttached) as [SEE ATTACHED],
sum(Alert) as [ALERT/SEE ATTACHED],
sum(ClosedbyUser) as [ClosedbyUser]
--From #TempVerificationProdDetails--Code commented for ticket id - 57455 
From #TempVerificationProdDetails_temp--Code added for ticket id - 57455 

UNION ALL

Select 'WNTotals' Investigator, 
sum(EmplEfforts) as [Empl Efforts],
sum(EduEfforts) as [Edu Efforts],
sum(PresRefEfforts) as [PersRef Efforts],
sum(PersRefVerifiedSeeAttached) as [PersRef - Verified/See Attached],
sum(PersRefUnVerifiedSeeAttached) as [Pers Ref - UNVERIFIED/SEE ATTACHED],
sum(Verified) as [VERIFIED],
sum(UnVerified) as [UNVERIFIED/SEE ATTACHED],
sum(SeeAttached) as [SEE ATTACHED],
sum(Alert) as [ALERT/SEE ATTACHED],
sum(ClosedbyUser) as [ClosedbyUser]
--From #TempVerificationProdDetails--Code commented for ticket id - 57455 
From #TempVerificationProdDetails_temp--Code added for ticket id - 57455 
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



-- =============================================
-- Author: Radhika Dereddy
-- Create date: 02/26/2020
-- Description: Pam/Michelle request and remove the Education and fine tune the report
-- EXEC [Verification_Team_Production_Details_With_WorkNumber] '02/20/2020', '02/20/2020'
-- =============================================

CREATE PROCEDURE [dbo].[Verification_Team_Production_Details_With_WorkNumber]
@StartDate DateTime,
@EndDate DateTime

AS
BEGIN

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SET @EndDate = dateadd(s,-1,dateadd(d,1,@EndDate)) 

Drop Table IF EXISTS #tempLogWN1
Drop Table IF EXISTS #tempLogWN2
Drop Table IF EXISTS #tempChangeLog
Drop Table IF EXISTS #tempUsers
Drop Table IF EXISTS #tempAllModulesClosed
Drop Table IF EXISTS #tempAllModulesPending
Drop Table IF EXISTS #EmpltempChangeLog2
Drop Table IF EXISTS #Empltmp1
Drop Table IF EXISTS #tempEfforts
DROP Table IF EXISTS #TempVerificationProdDetails



SELECT distinct v.SectStat as NewValue,
	 (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING ( ltrim(rtrim(UserID)) ,1 , len(ltrim(rtrim(UserID))) -5) end) + '(WKN)' as UserID,
	 v.emplid as id
into #tempLogWN1
FROM  dbo.Changelog c  (nolock)
JOIN  dbo.Integration_Verification_SourceCode i (nolock) ON c.id = i.sectionkeyid and i.refVerificationSource = 'WorkNumber'
JOIN dbo.[Verification_RP_Logging_Empl] v (nolock) ON i.sectionkeyid = v.emplid
WHERE c.changedate between @StartDate and @EndDate 
and i.DateTimStamp between @StartDate and @EndDate
and c.TableName = 'Empl.web_status' 
and c.NewValue in (69)

--SELECT * FROM #tempLogWN1


SELECT distinct c.NewValue, 
		(case when len(ltrim(rtrim(c.UserID))) <=8 then ltrim(rtrim(c.UserID)) else  SUBSTRING ( ltrim(rtrim(c.UserID)) ,1 , len(ltrim(rtrim(c.UserID))) -5) end) + '(WKN)' as UserID,
		i.sectionkeyid as id
into #tempLogWN2
FROM dbo.Changelog c  (nolock) 
JOIN (
		SELECT UserID, id, Max(changedate) as changedate FROM  dbo.Changelog (nolock)
		group by userid, id, TableName
		having (max(changedate) between @StartDate and @EndDate) and (TableName = 'Empl.sectstat')
	 )c1 ON c.UserID = c1.UserId and c.id = c1.id and c.changedate = c1.changedate
JOIN dbo.Integration_Verification_SourceCode i (nolock) ON c1.id = i.sectionkeyid and i.refVerificationSource = 'WorkNumber'
WHERE c1.changedate between @StartDate and @EndDate  
and i.DateTimStamp between @StartDate and @EndDate
and c.TableName = 'Empl.sectstat'

--select * from #tempLogWN2


SELECT NewValue, UserID, ID into #tempChangelog
from (
		select NewValue, UserID, ID from #tempLogWN1 where id not in (select id from #tempLogWN2)
		union
		select NewValue, UserID, ID from #tempLogWN2
)B



SELECT distinct REPLACE(USERID, '-empl','')as UserID, id into #tempEfforts
FROM dbo.ChangeLog 
where TableName like 'Empl.%'
and ChangeDate between @startDate and @EndDate 
order by UserID


SELECT DISTINCT UserID into #tempUsers 
FROM Users
WHERE Empl = 1 and Disabled = 0 AND CAM=0
ORDER BY UserID


Select count(EmplID) as ID, H.Investigator as UserID INTO #tempAllModulesClosed
From Empl H (NoLock)
where H.sectstat in ('A','4','5','6','7','8') and 
Last_Worked between @StartDate and @EndDate and H.Investigator is not null
group by H.Investigator	 

Select count(EmplID) as ID INTO #tempAllModulesPending 
From Empl P (NoLock) 
inner Join Appl Ap (NoLock) on P.APNO = Ap.APNO 
where sectstat = '9' and  Ap.ApStatus not in ('F') and CLNO not in (3468 ) 

SELECT distinct (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING ( ltrim(rtrim(UserID)) ,1 , len(ltrim(rtrim(UserID))) -5) end) + '(WKN)' as UserID,
id
into #EmpltempChangeLog2
FROM  dbo.ChangeLog 
where TableName =  'Empl.web_status'
and ChangeDate between @StartDate and @EndDate
and Newvalue <> 0 and UserID <> ''
and id in (
			SELECT sectionkeyid
			FROM  dbo.Integration_Verification_SourceCode
			WHERE refVerificationSource = 'WorkNumber' and DateTimStamp between @StartDate and @EndDate
		  )

insert into #EmpltempChangeLog2
SELECT distinct (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING ( ltrim(rtrim(UserID)) ,1 , len(ltrim(rtrim(UserID))) -5) end) as UserID, 
id
FROM  dbo.ChangeLog where
TableName =  'Empl.web_status'
and  ChangeDate between @StartDate and @EndDate
and Newvalue <> 0 and UserID <> ''
order by UserID

--select UserID into #tempUsers3 from #EmpltempChangeLog2


Select ltrim(rtrim(investigator)) + '(WKN)' as Investigator,InvestigatorAssigned,web_Updated,sectstat,apno,emplid into #Empltmp1
From dbo.Empl with (nolock)
Where ((InvestigatorAssigned>= @StartDate and InvestigatorAssigned< = @EndDate)
OR (Last_Worked>= @StartDate and Last_Worked< = @EndDate))
and emplid in (
				SELECT sectionkeyid
				FROM  dbo.Integration_Verification_SourceCode
				WHERE refVerificationSource = 'WorkNumber' and DateTimStamp between @StartDate and @EndDate
			  )

set IDENTITY_INSERT #Empltmp1 on
insert into #Empltmp1(Investigator,InvestigatorAssigned,web_Updated,sectstat,apno,emplid )
Select ltrim(rtrim(investigator)) as Investigator, InvestigatorAssigned,web_Updated,sectstat,apno,emplid 
From dbo.Empl with (nolock)
Where ((InvestigatorAssigned>= @StartDate and InvestigatorAssigned< = @EndDate)
OR (Last_Worked>= @StartDate and Last_Worked< = @EndDate))
order by Investigator asc




Create Table #TempVerificationProdDetails
(
	Investigator varchar(20),
	EmplEfforts int,
	EmplVerificationsAssigned int,
	EmplUpdatedWebStatus int,	
	Verified int,
	VerifiedSeeAttached int,
	UnVerifiedSeeAttached int,
	SeeAttached int,
	AlertSeeAttached int,
	ClosedbyUser int, 
	ClosedInUserModule int,
	PendingAssigned int,
	PendingOverall int
)

Insert into #TempVerificationProdDetails (Investigator, EmplEfforts,
		EmplVerificationsAssigned,
		EmplUpdatedWebStatus, 
		Verified,VerifiedSeeAttached,UnVerifiedSeeAttached,SeeAttached,AlertSeeAttached,
		ClosedbyUser, ClosedInUserModule, PendingAssigned,PendingOverall)

(Select T.UserID  Investigator, 
(select count(1) From #tempEfforts where #tempEfforts.UserID = T.UserID) [Empl Efforts],

(Select count(1) From #Empltmp1 X (NoLock) where  (InvestigatorAssigned>= @StartDate and InvestigatorAssigned< = @EndDate) and isnull(X.Investigator,'') = isnull(T.UserID,'')) [Empl Verifications Assigned],

(Select count(1) From #EmpltempChangeLog2 K where  K.UserID = T.UserID) [Empl Updated WebStatus],

(Select count(1) From #tempChangeLog B (NoLock)  where Newvalue = '4' and isnull(B.UserID,'') = isnull(T.UserID,'')) [VERIFIED],
(Select count(1) From #tempChangeLog C (NoLock)  where Newvalue = '5'  and isnull(C.UserID,'') = isnull(T.UserID,'')) [VERIFIED/SEE ATTACHED],
(Select count(1) From #tempChangeLog D (NoLock)  where Newvalue = '6'  and isnull(D.UserID,'') = isnull(T.UserID,'')) [UNVERIFIED/SEE ATTACHED],
(Select count(1) From #tempChangeLog E (NoLock)  where Newvalue = '8'   and isnull(E.UserID,'') = isnull(T.UserID,'')) [SEE ATTACHED],
(Select count(1) From #tempChangeLog F (NoLock)  where Newvalue = '7'  and isnull(F.UserID,'') = isnull(T.UserID,'')) [ALERT/SEE ATTACHED],
(Select count(1) From #tempChangeLog G (NoLock)  where G.Newvalue in ('A','4','5','6','8','7') and isnull(G.UserID,'') = isnull(T.UserID,'')) [Closed by User],
(Select Sum(ID) from #tempAllModulesClosed X1 where isnull(X1.UserID,'') = isnull(T.UserID,'')) [Closed In User Module],   
(Select count(1) From #tempChangeLog O (NoLock)  where Newvalue = '9'  and isnull(O.UserID,'') = isnull(T.UserID,'')) [Pending Assigned],
(Select sum(ID) From #tempAllModulesPending) [Pending Overall]
FROM #tempUsers T
Group By T.UserID)


Select * From #TempVerificationProdDetails

UNION ALL

Select 'Totals' Investigator, 
sum(EmplEfforts) as [Empl Efforts],
sum(EmplVerificationsAssigned) as [Empl Verifications Assigned],
sum(EmplUpdatedWebStatus) as [Empl Updated WebStatus],
sum(Verified) as [VERIFIED],
sum(VerifiedSeeAttached) as [VERIFIED/SEE ATTACHED],
sum(UnVerifiedSeeAttached) as [UNVERIFIED/SEE ATTACHED],
sum(SeeAttached) as [SEE ATTACHED],
sum(AlertSeeAttached) as [ALERT/SEE ATTACHED],
sum(ClosedbyUser) as [ClosedbyUser],
sum(ClosedInUserModule) as [ClosedInUserModule],
sum(PendingAssigned) as [PendingAssigned],
sum(PendingOverall) as [PendingOverall]
FROM #TempVerificationProdDetails

UNION ALL

Select 'WNTotals' Investigator, 
sum(EmplEfforts) as [Empl Efforts],
sum(EmplVerificationsAssigned) as [Empl Verifications Assigned],
sum(EmplUpdatedWebStatus) as [Empl Updated WebStatus],
sum(Verified) as [VERIFIED],
sum(VerifiedSeeAttached) as [VERIFIED/SEE ATTACHED],
sum(UnVerifiedSeeAttached) as [UNVERIFIED/SEE ATTACHED],
sum(SeeAttached) as [SEE ATTACHED],
sum(AlertSeeAttached) as [ALERT/SEE ATTACHED],
sum(ClosedbyUser) as [ClosedbyUser],
sum(ClosedInUserModule) as [ClosedInUserModule],
sum(PendingAssigned) as [PendingAssigned],
sum(PendingOverall) as [PendingOverall]
FROM #TempVerificationProdDetails
Where Investigator like '%(WKN)%'




END
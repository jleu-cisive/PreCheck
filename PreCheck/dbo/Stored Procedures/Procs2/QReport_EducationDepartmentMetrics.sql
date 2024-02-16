-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 07/15/2021
-- Description:	Create Education Department Metrics
-- EXEC [QReport_EducationDepartmentMetrics] '07/19/2021','07/19/2021'
-- =============================================
CREATE PROCEDURE [dbo].[QReport_EducationDepartmentMetrics]
	-- Add the parameters for the stored procedure here
@StartDate datetime ,
@EndDate datetime 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
SET @EndDate = dateadd(s,-1,dateadd(d,1,@EndDate)) 


--STEP:1 Edu #tempChangeLog
SELECT    Newvalue, 
(case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING ( ltrim(rtrim(UserID)) ,1 , len(ltrim(rtrim(UserID))) -7) end + '-Educat') as UserID, 
id into #EdutempChangeLog
FROM   dbo.ChangeLog
WHERE     (TableName = 'Educat.SectStat')
and ChangeDate between @StartDate and @EndDate
order by UserID


select UserID into #tempUsers1 from #EdutempChangeLog

--select * from #tempUsers1

--Select * from #EdutempChangeLog


--STEP:2 Edu #tmp1
Select 
(case when len(ltrim(rtrim(Investigator))) <=8 then ltrim(rtrim(Investigator)) else  SUBSTRING ( ltrim(rtrim(Investigator)) ,1 , len(ltrim(rtrim(Investigator))) -7) end + '-Educat') as UserID, 
web_Updated,sectstat into #Edutmp1
From dbo.Educat (NoLock)
Where (Last_Worked>= @StartDate and Last_Worked< = @EndDate)
order by Investigator asc


select UserID into #tempUsers2 from #Edutmp1

--select * from #Edutmp1

--STEP:3  #EdutempChangeLog2
SELECT    Newvalue,
(case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING ( ltrim(rtrim(UserID)) ,1 , len(ltrim(rtrim(UserID))) -7) end + '-Educat') as UserID,
id into #EdutempChangeLog2
FROM dbo.ChangeLog where
TableName =  'Educat.web_status'
and  ChangeDate between @StartDate and @EndDate
and Newvalue <> 0 
order by UserID

--Select * from #EdutempChangeLog2

select UserID into #tempUsers3 from #EdutempChangeLog2


--STEP:4 Edu #tempChangeLog3
SELECT (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING ( ltrim(rtrim(UserID)) ,1 , len(ltrim(rtrim(UserID))) -7) end + '-Educat') as UserID,
id
into #EdutempChangeLog3
FROM         dbo.ChangeLog where
( UserID like '%-educat')
and  ChangeDate between @StartDate and @EndDate
order by UserID

--select * from #EdutempChangeLog3

select UserID into #tempUsers4 from #EdutempChangeLog3

--select * from #tempUsers4


--STEP:5 Edu #tempChangeLog4
Select  distinct id,UserID into #EdutempChangeLog4 From #EdutempChangeLog3 

--Select * from #EdutempChangeLog4


Select distinct (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING ( ltrim(rtrim(UserID)) ,1 , len(ltrim(rtrim(UserID))) -7) end + '-Educat') as UserID into #tempUsers5
from Users Where Educat =1 and Disabled = 0 and CAM = 0 
order by UserID

--select * from #tempUsers5


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


--select * from #tempUsers


create table #TempStatus 
( 
   NewValue varchar(8000),
   UserID varchar(50),
   id int
) 

insert into #TempStatus (NewValue,UserID,id) 
SELECT  Newvalue, UserID, id from #EdutempChangeLog

--select * from #tempStatus

Create Table #tempAllModulesClosed
(
  ClosedInUserModule int,
  UserID varchar(8)
)

 
insert into #tempAllModulesClosed (ClosedInUserModule, UserID)
Select count(EducatID), I.Investigator as UserID From Educat I (NoLock)  where I.sectstat in ('A','4','5','6','7','8','U','C') and
Last_Worked>= @StartDate and Last_Worked< = @EndDate and I.Investigator is not null
group by I.Investigator



Create Table #tempAllModulesPending
(
  PendingOverall int
)

insert into #tempAllModulesPending (PendingOverall) 
Select count(EducatID) 
From Educat Q (NoLock)
inner JOin Appl Ap (NoLock) on Q.APNO = Ap.APNO  
where sectstat = '9' and  Ap.ApStatus not in ('F') and CLNO not in (3468 ) 



Create Table #TempVerificationProdDetails
(
	Investigator varchar(20),
	EduEfforts int,
	Verified int,
	UnVerified int,
	SeeAttached int,
	Alert int,
	ClosedbyUser int	
)

Insert into #TempVerificationProdDetails (Investigator, EduEfforts, 
		Verified,UnVerified,SeeAttached,Alert, 
		ClosedbyUser)

(
	Select T.UserID  Investigator, 
	(select count(1) From #EdutempChangeLog4 where  #EdutempChangeLog4.UserID = T.UserID) [Edu Efforts],
	(select Sum(verified) as total_Verified 
	  from(
			(Select count(1) as verified From #TempStatus B (NoLock)  where Newvalue = '4' and isnull(B.UserID,'') = isnull(T.UserID,'')) 
			UNION ALL
			(Select count(1) as verified From #TempStatus C (NoLock)  where Newvalue = '5' and isnull(C.UserID,'') = isnull(T.UserID,''))
			)
	v),

(select Sum(UnVerified) as total_unVerified
	 from(
			(Select count(1) as UnVerified From #TempStatus G (NoLock)  where Newvalue = 'U' and isnull(G.UserID,'') = isnull(T.UserID,'')) 
			UNION ALL
			(Select count(1) as UnVerified From #TempStatus D (NoLock)  where Newvalue = '6'  and isnull(D.UserID,'') = isnull(T.UserID,''))
			)
		uv),

(Select count(1) From #TempStatus E (NoLock)  where Newvalue = '8'   and isnull(E.UserID,'') = isnull(T.UserID,'')) [SEE ATTACHED],

(select Sum(Alert) as total_Alert
   from(
		(Select count(1) as Alert From #TempStatus H (NoLock)  where Newvalue = 'C' and isnull(H.UserID,'') = isnull(T.UserID,'')) 
		UNION ALL
		(Select count(1) as Alert From #TempStatus F (NoLock)  where Newvalue = '7'  and isnull(F.UserID,'') = isnull(T.UserID,''))
		)
	a),
(Select count(1) From #TempStatus G (NoLock)  where G.Newvalue in ('A','4','5','6','8','7','U','C') and isnull(G.UserID,'') = isnull(T.UserID,'')) [Closed by User]

FROM #tempUsers T
Group By T.UserID
)



SELECT SUBSTRING (T.Investigator ,1 , len(T.Investigator)-7) as Investigator,
 EduEfforts, Verified,UnVerified,SeeAttached,Alert, ClosedbyUser
 INTO #TempVerificationDetails
 FROM #TempVerificationProdDetails T

 SELECT distinct UPPER(ltrim(rtrim(T.Investigator))) as Investigator, 
	 Max(EduEfforts) EduEfforts, 
	 Max(Verified) Verified,
	 Max(UnVerified) UnVerified,
	 Max(SeeAttached)SeeAttached,
	 Max(Alert)Alert,
	 Max(ClosedbyUser) ClosedbyUser 
	INTO #tempEducationMetrics
 FROM #TempVerificationDetails T
 INNER JOIN USERS u on UPPER(T.Investigator)=UPPER(U.Userid) and U.Educat =1
 GROUP BY T.Investigator



SELECT Investigator, EduEfforts, Verified,UnVerified,SeeAttached,Alert, ClosedbyUser INTO #tempMetrics FROM
(
	SELECT T.Investigator, T.EduEfforts, T.Verified,T.UnVerified,T.SeeAttached,T.Alert, T.ClosedbyUser
	FROM #tempEducationMetrics T

	UNION ALL

	Select 'Totals' Investigator, 
	sum(EduEfforts) as [EduEfforts],
	sum(Verified) as [VERIFIED],
	sum(UNVERIFIED) as [UNVERIFIED],
	sum(SeeAttached) as [SEEATTACHED],
	sum(Alert) as [ALERT],
	sum(ClosedbyUser) as [ClosedbyUser]
	FROM #tempEducationMetrics A
) Q
WHERE Q.Investigator IS NOT NULL



SELECT * FROM #tempMetrics
WHERE Investigator in (select userid from Users where educat=1 
AND userid not in('EDUCAT1','NCH','OVERSEAS','REINVEST','FEEREQUE', 'EDUCAT2', 'FOLLOWUP', 'CCOOPER'))

Drop Table #TempVerificationProdDetails
Drop Table #TempVerificationDetails
DROP TABlE #tempEducationMetrics
DROP TABlE #tempMetrics
Drop Table #Edutmp1
Drop Table #EdutempChangeLog
Drop Table #EdutempChangeLog2
Drop Table #EdutempChangeLog3
Drop Table #EdutempChangeLog4

Drop Table #tempUsers
Drop Table #tempstatus
Drop Table #tempUsers1
Drop Table #tempUsers2
Drop Table #tempUsers3
Drop Table #tempUsers4
Drop Table #tempUsers5

Drop Table #tempAllModulesClosed
Drop Table #tempAllModulesPending



END


--Education_Verification_Status_QReport '07/06/2015','07/06/2015'
/*
EXEC [dbo].[Education_Verification_Status_QReport_Deepak] '08/6/2015', '08/24/2015'
EXEC [dbo].[Education_Verification_Status_QReport] '08/6/2015', '08/24/2015'
*/

CREATE PROCEDURE [dbo].[Education_Verification_Status_QReport_Deepak] 

@StartDate DateTime = '07/06/2015', 
@EndDate DateTime = '07/06/2015'

AS

--Declare @StartDate DateTime
--Declare @EndDate DateTime
--
--Set @StartDate = '08/29/2011'
--Set @EndDate = '08/29/2011'

--SELECT Newvalue,  SUBSTRING ( UserID ,1 , 8 ) UserID 
--	   into #tempChangeLog
--FROM dbo.ChangeLog(NOLOCK)
--WHERE TableName = 'Educat.SectStat'
--  and ChangeDate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))
--order by UserID

SELECT T.NewValue, T.UserID into #tempChangeLog
FROM
(
	SELECT Newvalue,  SUBSTRING ( UserID ,1 , 8 ) UserID
	FROM dbo.ChangeLog(NOLOCK)
	WHERE TableName = 'Educat.SectStat'
	  AND ChangeDate BETWEEN @StartDate AND dateadd(s,-1,dateadd(d,1,@EndDate))
	UNION ALL
	SELECT SectStat,'NCH' UserID
	FROM dbo.Verification_RP_Logging_Educat (NOLOCK)
	WHERE CreatedDate BETWEEN @StartDate AND dateadd(s,-1,dateadd(d,1,@EndDate))
	) AS T
ORDER BY T.UserID


Select	Investigator,--InvestigatorAssigned,
		web_Updated,sectstat into #tmp1
From dbo.Educat (NoLock)
Where --(InvestigatorAssigned>= @StartDate and InvestigatorAssigned< = dateadd(s,-1,dateadd(d,1,@EndDate)))
--OR 
(Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)))
order by Investigator asc


SELECT    Newvalue, SUBSTRING ( UserID ,1 , 8 ) UserID,id into #tempChangeLog2
FROM         dbo.ChangeLog where
TableName =  'Educat.web_status'
and  ChangeDate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))
and Newvalue <> 0 
order by UserID

SELECT    SUBSTRING ( UserID ,1 , 8 ) UserID,id into #tempChangeLog3
FROM         dbo.ChangeLog where
TableName like  'Educat.%' and UserID like '%-Educat'
and  ChangeDate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))
order by UserID
--
--CREATE TABLE #TEMPUser(
--	[Investigator] varchar(8) )
--
Select  distinct id,UserID into #tempChangeLog4 From #tempChangeLog3 

Select distinct UserID into #tempUsers from Users Where Educat = 1 and Disabled = 0 --(Commented by Radhika Dereddy on 04/07/2014 as per Milton's request to have all investiagtors incuded irrrespective of their activity each day)
order by UserID

Select Case When T.UserID is Null then 'UnAssigned' else T.UserID end Investigator, 
	(select count(1) From #tempChangeLog4 where  #tempChangeLog4.UserID = T.UserID) [Efforts], -- [Updates/Touches]commented by Radhika Dereddy on 03/25/2014 per Dana's request, 
	(Select count(1) From #tempChangeLog2 A where  A.UserID = T.UserID) [Education - Updated WebStatus],
	--(Select count(1) From #tmp1 A where web_Updated is not null and A.Investigator = T.UserID) [Verifications - Updated WebStatus],
	(Select count(1) From dbo.#tempChangeLog B (NoLock)  where Newvalue = '4'and isnull(B.UserID,'') = isnull(T.UserID,'')) [VERIFIED],
	(Select count(1) From dbo.#tempChangeLog C (NoLock)  where Newvalue = '5'  and isnull(C.UserID,'') = isnull(T.UserID,'')) [VERIFIED/SEE ATTACHED],
	(Select count(1) From dbo.#tempChangeLog D (NoLock)  where Newvalue = '6'  and isnull(D.UserID,'') = isnull(T.UserID,'')) [UNVERIFIED/SEE ATTACHED],
	(Select count(1) From dbo.#tempChangeLog E (NoLock)  where Newvalue = '8'  and isnull(E.UserID,'') = isnull(T.UserID,'')) [SEE ATTACHED],
	(Select count(1) From dbo.#tempChangeLog E1 (NoLock)  where E1.Newvalue in ('5','6','8') and isnull(E1.UserID,'') = isnull(T.UserID,'')) [Closed  by User],
	(Select count(1) From dbo.Educat E2 (NoLock)  where E2.sectstat in ('5','6','8') and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) and isnull(E2.Investigator,'') = isnull(T.UserID,'')) [Closed In  User Module],	   

	(Select count(1) From dbo.#tempChangeLog F (NoLock)  where Newvalue = '7' and isnull(F.UserID,'') = isnull(T.UserID,'')) [ALERT/SEE ATTACHED],
	--	   (Select count(1) From dbo.#tempChangeLog G (NoLock)  where Newvalue = '3'  and isnull(G.UserID,'') = isnull(T.UserID,'')) [COMPLETE/SEE ATTACHED],
	--	   (Select count(1) From dbo.#tempChangeLog H( NoLock)  where Newvalue = '2'  and isnull(H.UserID,'') = isnull(T.UserID,'')) [COMPLETE],
	(Select count(1) From dbo.#tempChangeLog X (NoLock)  where Newvalue = 'A'  and isnull(X.UserID,'') = isnull(T.UserID,'')) [EDUCATIONAL INSTITUTION CLOSED],
	(Select count(1) From dbo.#tempChangeLog I (NoLock)  where Newvalue = '9'  and isnull(I.UserID,'') = isnull(T.UserID,'')) [Pending - Assigned],
	(Select count(1) From dbo.Educat E (NoLock) inner JOin Appl A (NoLock) on E.APNO = A.APNO  where sectstat = '9' and  A.ApStatus not in ('F') ) [Pending - Overall]

	 --  (Select count(1) From dbo.Educat  (NoLock) where sectstat = '9') [Pending - Overall]
--From #tempChangeLog T --Commented on 04/07/2014 Rdereddy
FROM #tempUsers T
Group By T.UserID


UNION ALL
Select 'Totals' Investigator, 0 [Efforts],--[Updates/Touches] commented by Radhika Dereddy on 03/25/2014 per Dana's request,

		(Select count(1) From dbo.Educat A (NoLock)  where web_Updated is not null and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [Education - Updated WebStatus],
	   (Select count(1) From dbo.Educat B (NoLock)  where sectstat = '4' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [VERIFIED],
	   (Select count(1) From dbo.Educat C (NoLock)  where sectstat = '5'and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) ) [VERIFIED/SEE ATTACHED],
	   (Select count(1) From dbo.Educat D (NoLock)  where sectstat = '6' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [UNVERIFIED/SEE ATTACHED],
	   (Select count(1) From dbo.Educat E (NoLock)  where sectstat = '8' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [SEE ATTACHED],
	'' [Closed  by User],'' [Closed In  User Module],
	   (Select count(1) From dbo.Educat F (NoLock)  where sectstat = '7' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [ALERT/SEE ATTACHED],
--	   (Select count(1) From dbo.Educat G (NoLock)  where sectstat = '3' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [COMPLETE/SEE ATTACHED],
--	   (Select count(1) From dbo.Educat H (NoLock)  where sectstat = '2' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [COMPLETE],
	   (Select count(1) From dbo.Educat X (NoLock)  where sectstat = 'A' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [EDUCATIONAL INSTITUTION CLOSED],
	   (Select count(1) From dbo.Educat I (NoLock)  where sectstat = '9'and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) ) [Pending - Assigned],
	  -- (Select count(1) From dbo.Educat  (NoLock) where sectstat = '9') [Pending - Overall]
 (Select count(1) From dbo.Educat E (NoLock) inner JOin Appl A (NoLock) on E.APNO = A.APNO  where sectstat = '9' and  A.ApStatus not in ('F') ) [Pending - Overall]

Drop Table #tmp1

Drop Table #tempChangeLog
Drop Table #tempChangeLog2
--Drop Table #TEMPUser
Drop Table #tempChangeLog3
Drop Table #tempChangeLog4
DROP Table #tempUsers













/*********************************************************************
--- Modified by Amy Liu on 09/03/2020 for phase3 of project: IntranetModule: Status-SubStatus
--- EXEC [dbo].[Company_Education_Verification_Status_QReport] @StartDate = '08/01/2020', @EndDate = '08/31/2020'
*********************************************************************/

CREATE PROCEDURE [dbo].[Company_Education_Verification_Status_QReport] 

@StartDate DateTime = '01/12/2012', 
@EndDate DateTime = '01/12/2012'

AS

--Declare @StartDate DateTime
--Declare @EndDate DateTime

--Set @StartDate = '08/01/2020'
--Set @EndDate = '08/31/2020'

Select --'Totals' Totals, 

		(Select count(1) From dbo.Educat A (NoLock)  where web_Updated is not null and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [WEB_UPDATED],
	   (Select count(1) From dbo.Educat B (NoLock)  where sectstat = '4' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [VERIFIED],
	   (Select count(1) From dbo.Educat C (NoLock)  where sectstat = '5'and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) ) [VERIFIED/SEE ATTACHED],
	   (Select count(1) From dbo.Educat D (NoLock)  where sectstat = '6' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [UNVERIFIED/SEE ATTACHED],
	   (Select count(1) From dbo.Educat E (NoLock)  where sectstat = '8' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [SEE ATTACHED],
	   (Select count(1) From dbo.Educat F (NoLock)  where sectstat = '7' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [ALERT/SEE ATTACHED],
	   (Select count(1) From dbo.Educat G (NoLock)  where sectstat = '3' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [COMPLETE/SEE ATTACHED],
	   (Select count(1) From dbo.Educat H (NoLock)  where sectstat = '2' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [COMPLETE],
	   (Select count(1) From dbo.Educat I (NoLock)  where sectstat = '9'and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) ) [Pending - Assigned],

	   (Select count(1) From dbo.Educat I (NoLock)  where sectstat = 'C'and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [ALERT],
	   (Select count(1) From dbo.Educat I (NoLock)  where sectstat = 'U'and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [UNVERIFIED],
	   (Select count(1) From dbo.Educat I (NoLock)  where sectstat = 'R'and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [COMPLIANCEREINVESTIGATION],
	  -- (Select count(1) From dbo.Educat  (NoLock) where sectstat = '9') [Pending - Overall]
       (Select count(1) From dbo.Educat E (NoLock) inner JOin Appl A (NoLock) on E.APNO = A.APNO  where sectstat = '9' and  A.ApStatus not in ('F') ) [Pending - Overall]


--Drop Table #tmp1
--
--Drop Table #tempChangeLog








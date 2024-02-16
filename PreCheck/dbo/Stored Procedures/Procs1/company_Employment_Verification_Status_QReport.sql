









CREATE PROCEDURE [dbo].[company_Employment_Verification_Status_QReport] 

@StartDate DateTime = '1/1/2012', 
@EndDate DateTime = '1/31/2012'

AS


Select --'Totals' Total, 
(Select count(1) From dbo.Empl J (NoLock) where  (InvestigatorAssigned>= @StartDate and InvestigatorAssigned< = dateadd(s,-1,dateadd(d,1,@EndDate))) ) [Verifications Assigned],

		(Select count(1) From dbo.Empl A (NoLock)  where web_Updated is not null and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)))  [Verifications - Updated WebStatus],
	   (Select count(1) From dbo.Empl B (NoLock)  where sectstat = '4' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [VERIFIED],
	   (Select count(1) From dbo.Empl C (NoLock)  where sectstat = '5'and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) ) [VERIFIED/SEE ATTACHED],
	   (Select count(1) From dbo.Empl D (NoLock)  where sectstat = '6' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [UNVERIFIED/SEE ATTACHED],
	   (Select count(1) From dbo.Empl E (NoLock)  where sectstat = '8' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [SEE ATTACHED],
	   (Select count(1) From dbo.Empl F (NoLock)  where sectstat = '7' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [ALERT/SEE ATTACHED],
	   (Select count(1) From dbo.Empl G (NoLock)  where sectstat = '3' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [COMPLETE/SEE ATTACHED],
	   (Select count(1) From dbo.Empl H (NoLock)  where sectstat = '2' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [COMPLETE],
	   (Select count(1) From dbo.Empl I (NoLock)  where sectstat = '9'and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) ) [Pending - Assigned],

	   (Select count(1) From dbo.Empl I (NoLock)  where sectstat = 'C'and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) ) [ALERT],
	   (Select count(1) From dbo.Empl I (NoLock)  where sectstat = 'U'and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) ) [UNVERIFIED],

--	   (Select count(1) From dbo.Empl  (NoLock) where sectstat = '9') [Pending - Overall]
 (Select count(1) From dbo.Empl E (NoLock) inner JOin Appl A (NoLock) on E.APNO = A.APNO  where sectstat = '9' and  A.ApStatus not in ('F') ) [Pending - Overall]










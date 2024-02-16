










CREATE PROCEDURE [dbo].[company_ProfLicense_Verification_Status_QReport] 

@StartDate DateTime = '01/31/2012', 
@EndDate DateTime = '02/1/2012'

AS


Select

--count(1) [Verifications Assigned],
 --(Select count(1) From #tmp1 A where web_Updated is not null ) [Verifications - Updated WebStatus],
		(Select count(1) From dbo.ProfLic A (NoLock)  where web_Updated is not null and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)))  [Verifications - Updated WebStatus],
	   (Select count(1) From dbo.ProfLic B (NoLock)  where sectstat = '4' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [VERIFIED],
	   (Select count(1) From dbo.ProfLic C (NoLock)  where sectstat = '5'and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) ) [VERIFIED/SEE ATTACHED],
	   (Select count(1) From dbo.ProfLic D (NoLock)  where sectstat = '6' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [UNVERIFIED/SEE ATTACHED],
	   (Select count(1) From dbo.ProfLic E (NoLock)  where sectstat = '8' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [SEE ATTACHED],
	   (Select count(1) From dbo.ProfLic F (NoLock)  where sectstat = '7' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [ALERT/SEE ATTACHED],
	   (Select count(1) From dbo.ProfLic G (NoLock)  where sectstat = '3' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [COMPLETE/SEE ATTACHED],
	   (Select count(1) From dbo.ProfLic H (NoLock)  where sectstat = '2' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [COMPLETE],
	   (Select count(1) From dbo.ProfLic J (NoLock)  where sectstat = 'B'and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) ) [ALERT/BOARD ACTION],
	   (Select count(1) From dbo.ProfLic I (NoLock)  where sectstat = '9'and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) ) [Pending - Assigned],
--	   (Select count(1) From dbo.ProfLic  (NoLock) where sectstat = '9') [Pending - Overall]
(Select count(1) From dbo.Empl E (NoLock) inner JOin Appl A (NoLock) on E.APNO = A.APNO  where sectstat = '9' and  A.ApStatus not in ('F') ) [Pending - Overall]
--
--
--Drop Table #tempChangeLog
--
--Drop Table #tmp1










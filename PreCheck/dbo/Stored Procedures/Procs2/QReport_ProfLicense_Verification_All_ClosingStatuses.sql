-- =============================================
-- Author:		Sahithi Gangaraju 
-- Create date: 8/25/2020
-- Description: HDT#75243 Report for all closing statuse
-- EXEC [QReport_ProfLicense_Verification_All_ClosingStatuses] '08/01/2020', '08/20/2020'
-- =============================================
CREATE PROCEDURE [dbo].[QReport_ProfLicense_Verification_All_ClosingStatuses]
@StartDate DateTime,   
@EndDate DateTime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT    Newvalue,UserID into #tempChangeLog  
FROM  dbo.ChangeLog  
WHERE (TableName = 'ProfLic.SectStat')  
and ChangeDate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))  
order by UserID   
  
  
Select Investigator,web_Updated,sectstat into #tmp1  
From dbo.ProfLic (NoLock)  
Where (Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)))  
order by Investigator asc  
  
  

  
Select  T.UserID  Investigator,   
(Select count(1) From #tmp1 A where web_Updated is not null and A.Investigator = T.UserID) [Verifications - Updated WebStatus],  
(Select count(1) From #tempChangeLog B (NoLock)  where Newvalue = '4' and isnull(B.UserID,'') = isnull(T.UserID,'')) [VERIFIED],  
(Select count(1) From #tempChangeLog B (NoLock)  where Newvalue = 'U' and isnull(B.UserID,'') = isnull(T.UserID,'')) [UNVERIFIED],  
(Select count(1) From #tempChangeLog E (NoLock)  where Newvalue = '8'   and isnull(E.UserID,'') = isnull(T.UserID,'')) [SEE ATTACHED],  
(Select count(1) From #tempChangeLog E (NoLock)  where Newvalue = '3'   and isnull(E.UserID,'') = isnull(T.UserID,'')) [COMPLETE/SEE ATTACHED], 
(Select count(1) From #tempChangeLog E (NoLock)  where Newvalue = '5'   and isnull(E.UserID,'') = isnull(T.UserID,'')) [VERIFIED/SEE ATTACHED],
(Select count(1) From #tempChangeLog E (NoLock)  where Newvalue = '6'   and isnull(E.UserID,'') = isnull(T.UserID,'')) [UNVERIFIED/SEE ATTACHED],
(Select count(1) From #tempChangeLog E (NoLock)  where Newvalue = '7'   and isnull(E.UserID,'') = isnull(T.UserID,'')) [ALERT/SEE ATTACHED],
(Select count(1) From #tempChangeLog J (NoLock)  where Newvalue = 'C'  and isnull(J.UserID,'') = isnull(T.UserID,'')) [ALERT],  
(Select count(1) From #tempChangeLog J (NoLock)  where Newvalue = 'B'  and isnull(J.UserID,'') = isnull(T.UserID,'')) [ALERT/BOARD ACTION],  
((Select count(1) From #tempChangeLog B (NoLock)  where Newvalue = '4' and isnull(B.UserID,'') = isnull(T.UserID,'')) +
(Select count(1) From #tempChangeLog B (NoLock)  where Newvalue = 'U' and isnull(B.UserID,'') = isnull(T.UserID,'')) +
(Select count(1) From #tempChangeLog E (NoLock)  where Newvalue = '8'   and isnull(E.UserID,'') = isnull(T.UserID,'')) +
(Select count(1) From #tempChangeLog J (NoLock)  where Newvalue = 'C'  and isnull(J.UserID,'') = isnull(T.UserID,'')) +
(Select count(1) From #tempChangeLog J (NoLock)  where Newvalue = 'B'  and isnull(J.UserID,'') = isnull(T.UserID,'')))  [Closed  by User], 
(Select count(1) From dbo.ProfLic E2 (NoLock)  where E2.sectstat in ('5','6','8', 'B') and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) and isnull(E2.Investigator,'') = isnull(T.UserID,'')) [Closed In  User Module],      
(Select count(1) From #tempChangeLog I (NoLock)  where Newvalue = '9'  and isnull(I.UserID,'') = isnull(T.UserID,'')) [Pending - Assigned],    
(Select count(1) From dbo.ProfLic E (NoLock) inner JOin Appl A (NoLock) on E.APNO = A.APNO  where sectstat = '9' and  A.ApStatus not in ('F') ) [Pending - Overall]  
From  #tempChangeLog T  
Group By T.UserID    
  
UNION ALL 
 
Select 'Totals' Investigator,     
(Select count(1) From dbo.ProfLic A (NoLock)  where web_Updated is not null and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)))  [Verifications - Updated WebStatus],  
(Select count(1) From dbo.ProfLic B (NoLock)  where sectstat = '4' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [VERIFIED],  
(Select count(1) From dbo.ProfLic B (NoLock)  where sectstat = 'U' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [UNVERIFIED],  
(Select count(1) From dbo.ProfLic E (NoLock)  where sectstat = '8' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [SEE ATTACHED],  
(Select count(1) From dbo.ProfLic E (NoLock)  where sectstat = '3' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [COMPLETE/SEE ATTACHED], 
(Select count(1) From dbo.ProfLic E (NoLock)  where sectstat = '5' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [VERIFIED/SEE ATTACHED], 
(Select count(1) From dbo.ProfLic E (NoLock)  where sectstat = '6' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [UNVERIFIED/SEE ATTACHED], 
(Select count(1) From dbo.ProfLic E (NoLock)  where sectstat = '7' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [ALERT/SEE ATTACHED], 
(Select count(1) From dbo.ProfLic J (NoLock)  where sectstat = 'C' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [ALERT],  
(Select count(1) From dbo.ProfLic J (NoLock)  where sectstat = 'B' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [ALERT/BOARD ACTION],  
'' [Closed  by User],'' [Closed In  User Module],  
(Select count(1) From dbo.ProfLic I (NoLock)  where sectstat = '9'and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) ) [Pending - Assigned],  
(Select count(1) From dbo.ProfLic E (NoLock) inner JOin Appl A (NoLock) on E.APNO = A.APNO  where sectstat = '9' and  A.ApStatus not in ('F') ) [Pending - Overall]  
  
  
  
Drop Table #tempChangeLog    
Drop Table #tmp1   

END

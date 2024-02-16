------------------------------------------------------------------------------------------------
  
--Modified By Humera Ahmed on 6/3/2020 for HDT#72603 - Since we are no longer using "/See Attached" options, we need the QReport to reflect Alert, Unverified, and Alert/Board Action.  
--Modified by Doug DeGenaro on 6/3/2020 for HDT#75239 the "CLosed by User count" wasnt calculating correctly
-- Modified by Radhika dereddy on 01/05/2021 to Add Efforts.
-- EXEC [ProfLicense_Verification_Status_QReport] '12/01/2020', '12/31/2020'
 ------------------------------------------------------------------------------------------------
  
CREATE PROCEDURE [dbo].[ProfLicense_Verification_Status_QReport]   
 
@StartDate DateTime,   
@EndDate DateTime 
  
AS  
   
SELECT    Newvalue,UserID into #tempChangeLog  
FROM         dbo.ChangeLog  
WHERE     (TableName = 'ProfLic.SectStat')  
and ChangeDate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))  
order by UserID  
  
  
Select Investigator,web_Updated,sectstat into #tmp1  
From dbo.ProfLic (NoLock)  
Where (Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)))  
order by Investigator asc  
  
SELECT    SUBSTRING ( UserID ,1 , 8 ) UserID,id into #tempChangeLog3
FROM         dbo.ChangeLog (NoLock) where
TableName like  'ProfLic.%' 
and  ChangeDate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))
order by UserID  

 Select  distinct id,UserID into #tempChangeLog4 From #tempChangeLog3  

 
Select distinct UserID into #tempUsers from Users (NoLock) Where ProfLic = 1 and Disabled = 0 order by UserID
  
Select  T.UserID  Investigator, 
(select count(1) From #tempChangeLog4 where  #tempChangeLog4.UserID = T.UserID) [Efforts],  
 --(Select count(1) From dbo.#tmp1 J (NoLock) where  (InvestigatorAssigned>= @StartDate and InvestigatorAssigned< = dateadd(s,-1,dateadd(d,1,@EndDate))) and isnull(J.Investigator,'') = isnull(T.UserID,'')) [Verifications Assigned],  
(Select count(1) From #tmp1 A where web_Updated is not null and A.Investigator = T.UserID) [Verifications - Updated WebStatus],  
   (Select count(1) From #tempChangeLog B (NoLock)  where Newvalue = '4' and isnull(B.UserID,'') = isnull(T.UserID,'')) [VERIFIED],  
   (Select count(1) From #tempChangeLog B (NoLock)  where Newvalue = 'U' and isnull(B.UserID,'') = isnull(T.UserID,'')) [UNVERIFIED],  
    (Select count(1) From #tempChangeLog E (NoLock)  where Newvalue = '8'   and isnull(E.UserID,'') = isnull(T.UserID,'')) [SEE ATTACHED],  
    (Select count(1) From #tempChangeLog J (NoLock)  where Newvalue = 'C'  and isnull(J.UserID,'') = isnull(T.UserID,'')) [ALERT],  
     (Select count(1) From #tempChangeLog J (NoLock)  where Newvalue = 'B'  and isnull(J.UserID,'') = isnull(T.UserID,'')) [ALERT/BOARD ACTION],  
--(Select count(1) From dbo.#tempChangeLog E1 (NoLock)  where E1.Newvalue in ('4','5','6','7','8', 'B') and isnull(E1.UserID,'') = isnull(T.UserID,'')) [Closed  by User], 
((Select count(1) From #tempChangeLog B (NoLock)  where Newvalue = '4' and isnull(B.UserID,'') = isnull(T.UserID,'')) +
	  (Select count(1) From #tempChangeLog B (NoLock)  where Newvalue = 'U' and isnull(B.UserID,'') = isnull(T.UserID,'')) +
	   (Select count(1) From #tempChangeLog E (NoLock)  where Newvalue = '8'   and isnull(E.UserID,'') = isnull(T.UserID,'')) +
	   (Select count(1) From #tempChangeLog J (NoLock)  where Newvalue = 'C'  and isnull(J.UserID,'') = isnull(T.UserID,'')) +
	    (Select count(1) From #tempChangeLog J (NoLock)  where Newvalue = 'B'  and isnull(J.UserID,'') = isnull(T.UserID,'')))  [Closed  by User], 
   (Select count(1) From dbo.ProfLic E2 (NoLock)  where E2.sectstat in ('5','6','8', 'B') and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) and isnull(E2.Investigator,'') = isnull(T.UserID,'')) [Closed In  User Module],  
    
  
--    (Select count(1) From #tempChangeLog G (NoLock)  where Newvalue = '3'  and isnull(G.UserID,'') = isnull(T.UserID,'')) [COMPLETE/SEE ATTACHED],  
--    (Select count(1) From #tempChangeLog H( NoLock)  where Newvalue = '2'   and isnull(H.UserID,'') = isnull(T.UserID,'')) [COMPLETE],  
    (Select count(1) From #tempChangeLog I (NoLock)  where Newvalue = '9'  and isnull(I.UserID,'') = isnull(T.UserID,'')) [Pending - Assigned],  
    --(Select count(1) From dbo.ProfLic  (NoLock) where sectstat = '9') [Pending - Overall]  
(Select count(1) From dbo.ProfLic E (NoLock) inner JOin Appl A (NoLock) on E.APNO = A.APNO  where sectstat = '9' and  A.ApStatus not in ('F') ) [Pending - Overall]  
From  #tempUsers T  
Group By T.UserID  
  
  
UNION ALL  
Select 'Totals' Investigator,   0 [Efforts], 
  
--count(1) [Verifications Assigned],  
 --(Select count(1) From #tmp1 A where web_Updated is not null ) [Verifications - Updated WebStatus],  
  (Select count(1) From dbo.ProfLic A (NoLock)  where web_Updated is not null and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)))  [Verifications - Updated WebStatus],  
    (Select count(1) From dbo.ProfLic B (NoLock)  where sectstat = '4' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [VERIFIED],  
     (Select count(1) From dbo.ProfLic B (NoLock)  where sectstat = 'U' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [UNVERIFIED],  
    (Select count(1) From dbo.ProfLic E (NoLock)  where sectstat = '8' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [SEE ATTACHED],  
    (Select count(1) From dbo.ProfLic J (NoLock)  where sectstat = 'C' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [ALERT],  
    (Select count(1) From dbo.ProfLic J (NoLock)  where sectstat = 'B' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [ALERT/BOARD ACTION],  
 '' [Closed  by User],'' [Closed In  User Module],  
--    (Select count(1) From dbo.ProfLic G (NoLock)  where sectstat = '3' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [COMPLETE/SEE ATTACHED],  
--    (Select count(1) From dbo.ProfLic H (NoLock)  where sectstat = '2' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [COMPLETE],  
    (Select count(1) From dbo.ProfLic I (NoLock)  where sectstat = '9'and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) ) [Pending - Assigned],  
--    (Select count(1) From dbo.ProfLic  (NoLock) where sectstat = '9') [Pending - Overall]  
(Select count(1) From dbo.ProfLic E (NoLock) inner JOin Appl A (NoLock) on E.APNO = A.APNO  where sectstat = '9' and  A.ApStatus not in ('F') ) [Pending - Overall]  
  
  
  
Drop Table #tempChangeLog  
Drop Table #tempChangeLog3
Drop Table #tempChangeLog4  
Drop Table #tmp1   
  
  

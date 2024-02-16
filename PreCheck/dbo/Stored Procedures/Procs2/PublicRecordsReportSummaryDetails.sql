------------------------------------------------------------------------------------------------  
-- Modified By - Radhika Dereddy on 03/05/2018  
-- Requester - Misty Smallwood  
-- Modified By - Deepak Vodethela on 11/06/2020  
-- Modified By - Prasanna on 05/03/2022 for HDT#46965 Modify existing Qreport   
-- Requester - Misty Smallwood  
/*  
--Please modify the current report to include the additional items.   
--I want it to track anytime someone changes the status of the record.  
--Currently it provides the investigators names in the first column but it does not include  
--any of the records that are processed by automation or systems.   
--If possible, I would like those to be included as well.   
--If we record on the back end "which"  (name of) vendor makes the change, then they would be listed individually preferably.  
--If we can't, then just enter "Vendor" in the name field. Same with "AIMS agents", Integrations(Family Watch Dog)   
--for sex offenders, System, and anything else that may trigger a change in the status. the only status I want excluded is Needs Review, as those records are at the AI level still.  
*/  
-- EXEC [dbo].[PublicRecordsReportSummaryDetails] '10/20/2021', '10/21/2021'  
--------------------------------------------------------------------------------------------------------  
-- Modified By: Vairavan A  
-- Modified Date: 09/13/2022  
-- Description: Ticketno-46965 Modify existing Qreport - Public Records Report Summary  
-- EXEC [dbo].[PublicRecordsReportSummaryDetails] '07/22/2022', '07/22/2022'  
-- EXEC [dbo].[PublicRecordsReportSummaryDetails] '09/14/2022', '09/14/2022'  
--------------------------------------------------------------------------------------------------------  
-- Modified By: Shashank Bhoi  
-- Modified Date: 11/10/2022  
-- Description: Ticketno-71997 this Q-report is not loading for 10/31/2022.  
-- EXEC [dbo].[PublicRecordsReportSummaryDetails] '10/31/2022', '10/31/2022'  
--------------------------------------------------------------------------------------------------- 
-- Modified By: Arindam Mitra  
-- Modified Date: 05/30/2023  
-- Description: Ticketno-66955 Incorrect reporting for "See Attached" column.  
-- EXEC [dbo].[PublicRecordsReportSummaryDetails] '05/17/2023', '05/17/2023'  
--------------------------------------------------------------------------------------------------- 
CREATE PROCEDURE [dbo].[PublicRecordsReportSummaryDetails]   
  
@StartDate DateTime = '5/1/2022',   
@EndDate DateTime = '5/1/2022'  
  
AS  
  
Drop Table IF EXISTS #tempChangelog  
Drop Table IF EXISTS #tempResults  
  
  
  
--Step 1: Get all the Userid and the newvalues (crimstatus) for the Crim's from the changelog between the date range mentioned.  
--CREATE Table #tempChangeLog (UserID varchar(8), NewValue varchar(8000), LogDate DATETIME, ID VARCHAR(15), SourceValue VARCHAR(10))	--Code commented for fix against ticket no - 71997   
CREATE Table #tempChangeLog (UserID varchar(50), OldValue varchar(8000), NewValue varchar(8000), LogDate DATETIME, ID VARCHAR(15), SourceValue VARCHAR(10))  --Code added for fix against ticket no - 71997  
    
Insert into #tempChangelog(UserID, OldValue, NewValue,LogDate, ID,SourceValue)    
Select userid, OldValue, newvalue,changedate AS LogDate,ID, 'CrimStatus' AS SourceValue    
  From dbo.changelog with(NoLock)    
 Where TableName = 'Crim.Clear' and (changedate>= @StartDate and changedate< = dateadd(s,-1,dateadd(d,1,@EndDate)))    
order by userid asc   
    
    
--Step 2: Get all the AIMS agents from the Changelog    
Insert into #tempChangelog(UserID, OldValue, NewValue, LogDate, ID, SourceValue)    
Select userid, OldValue, newvalue, changedate AS LogDate, ID,'AIMS' AS SourceValue    
  From dbo.changelog with(NoLock)    
 Where TableName = 'Crim.Status' and (changedate>= @StartDate and changedate< = dateadd(s,-1,dateadd(d,1,@EndDate)))    
order by userid asc     
   
    
--Step 3: Get the investigator and Crim status for the Crim's from the IRIS result log table between the date range mentioned to the changelog    
Insert into #tempChangelog(UserID, OldValue, NewValue,LogDate, ID, SourceValue)    
Select Investigator, Clear AS OldValue, Clear,LogDate, CrimID AS ID,'IRIS' AS SourceValue    
From dbo.IRIS_ResultLog with (Nolock)    
Where (LogDate>= @StartDate and LogDate< = dateadd(s,-1,dateadd(d,1,@EndDate)))     
order by Investigator   
  
--Create Table #tempResults(UserID varchar(8), Clear int, Record_Found int, More_Info_Needed int, Ordered int, Ready_To_Order int,  --Code commented for fix against ticket no - 71997   
Create Table #tempResults(UserID varchar(50), Clear int, Record_Found int, More_Info_Needed int, Ordered int, Ready_To_Order int,	--Code added for fix against ticket no - 71997
Transferred_Record int, Needs_Research int, Waiting int, Error_Getting_Results int, Error_Sending_Results int, Ordering int, Vendor_Reviewed int,   
Alias_Name_Ordered int, Needs_QA int, Review_Reportability int, Reinvestigations int, Clear_Internal int,Cancelled_by_Client_Incomplete_Results int,  
Cancelled_InternalError_Incomplete_Results int, SeeAttached int, Do_Not_ReReport int, Do_Not_Report int, Completed int)  
  
--SELECT #tempChangelog.UserID, #tempChangelog.NewValue   
--FROM #tempChangelog   
--INNER JOIN  
-- (SELECT SourceValue,UserID,ID, MAX(LogDate) MAXLogDate FROM #tempChangeLog GROUP BY SourceValue,UserID,ID) AS MaxLogDateLog  
-- ON MaxLogDateLog.SourceValue = #tempChangelog.SourceValue  
-- AND MaxLogDateLog.UserID  = #tempChangelog.UserID  
-- AND MaxLogDateLog.MAXLogDate = #tempChangelog.LogDate  
  
--SELECT UserID, NewValue   
--FROM #tempChangelog   

select T.*
into  #tempChangelog1
From #tempChangelog T  
	 INNER JOIN  
	(SELECT SourceValue,UserID,ID, MAX(LogDate) MAXLogDate FROM #tempChangeLog GROUP BY SourceValue,UserID,ID ) AS MaxLogDateLog  
ON MaxLogDateLog.SourceValue = T.SourceValue  
AND MaxLogDateLog.UserID  = T.UserID  
AND MaxLogDateLog.MAXLogDate = T.LogDate  
--where t.UserID = 'ABuracke'

Insert into #tempResults  
Select T.UserID,   
  (Select count(distinct ID) From #tempChangelog1 A where newvalue ='T'  and a.SourceValue in('CrimStatus','AIMS','IRIS') and a.OldValue <> '' and A.UserID = T.UserID) [Clear],    
  (Select count(distinct ID) From #tempChangelog1 B (NoLock)  where newvalue ='F'  and b.SourceValue in('CrimStatus','AIMS','IRIS') and b.OldValue <> '' and isnull(B.UserID,'') = isnull(T.UserID,'')) [Record_Found],    
  (Select count(distinct ID) From #tempChangelog1 C (NoLock)  where newvalue ='P'   and c.SourceValue in('CrimStatus','AIMS','IRIS') and c.OldValue <> '' and isnull(C.UserID,'') = isnull(T.UserID,'')) [More_Info_Needed],        
  (Select count(distinct ID) From #tempChangelog1 D (NoLock)  where newvalue ='O' and isnull(D.UserID,'') = isnull(T.UserID,'')) [Ordered],  
  (Select count(distinct ID) From #tempChangelog1 E (NoLock)  where newvalue ='R' and isnull(E.UserID,'') = isnull(T.UserID,'')) [Ready_To_Order],  
  (Select count(distinct ID) From #tempChangelog1 F (NoLock)  where newvalue ='I' and isnull(F.UserID,'') = isnull(T.UserID,'')) [Transferred_Record],  
  (Select count(distinct ID) From #tempChangelog1 G (NoLock)  where newvalue ='Z' and isnull(G.UserID,'') = isnull(T.UserID,'')) [Needs_Research],  
  (Select count(distinct ID) From #tempChangelog1 H (NoLock)  where newvalue ='W' and isnull(H.UserID,'') = isnull(T.UserID,'')) [Waiting],  
  (Select count(distinct ID) From #tempChangelog1 I (NoLock)  where newvalue ='X' and isnull(I.UserID,'') = isnull(T.UserID,'')) [Error_Getting_Results],  
  (Select count(distinct ID) From #tempChangelog1 J (NoLock)  where newvalue ='E' and isnull(J.UserID,'') = isnull(T.UserID,'')) [Error_Sending_Results],  
  (Select count(distinct ID) From #tempChangelog1 K (NoLock)  where newvalue ='M' and isnull(K.UserID,'') = isnull(T.UserID,'')) [Ordering],  
  (Select count(distinct ID) From #tempChangelog1 L (NoLock)  where newvalue ='V' and isnull(L.UserID,'') = isnull(T.UserID,'')) [Vendor_Reviewed],  
  (Select count(distinct ID) From #tempChangelog1 M (NoLock)  where newvalue ='N' and isnull(M.UserID,'') = isnull(T.UserID,'')) [Alias_Name_Ordered],  
  (Select count(distinct ID) From #tempChangelog1 N (NoLock)  where newvalue ='Q' and isnull(N.UserID,'') = isnull(T.UserID,'')) [Needs_QA],  
  (Select count(distinct ID) From #tempChangelog1 O (NoLock)  where newvalue ='D' and isnull(O.UserID,'') = isnull(T.UserID,'')) [Review_Reportability],  
  (Select count(distinct ID) From #tempChangelog1 P (NoLock)  where newvalue ='G' and isnull(P.UserID,'') = isnull(T.UserID,'')) [Reinvestigations],  
  (Select count(distinct ID) From #tempChangelog1 Q (NoLock)  where newvalue ='B' and isnull(Q.UserID,'') = isnull(T.UserID,'')) [Clear_Internal],  
  (Select count(distinct ID) From #tempChangelog1 R (NoLock)  where newvalue ='C' and isnull(R.UserID,'') = isnull(T.UserID,'')) [Cancelled_by_Client_Incomplete_Results],  
  (Select count(distinct ID) From #tempChangelog1 S (NoLock)  where newvalue ='A' and isnull(S.UserID,'') = isnull(T.UserID,'')) [Cancelled_InternalError_Incomplete_Results],  
  (Select count(distinct ID) From #tempChangelog1 SA (NoLock)  where newvalue ='S' and isnull(SA.UserID,'') = isnull(T.UserID,'')) [SeeAttached], --Code added against ticket# 66955
  (Select count(distinct ID) From #tempChangelog1 U (NoLock)  where newvalue ='J' and isnull(U.UserID,'') = isnull(T.UserID,'')) [Do_Not_ReReport],  
  (Select count(distinct ID) From #tempChangelog1 V (NoLock)  where newvalue ='K' and isnull(V.UserID,'') = isnull(T.UserID,'')) [Do_Not_Report],  
  (Select count(distinct ID) From #tempChangelog1 W (NoLock)  where newvalue ='1' and isnull(W.UserID,'') = isnull(T.UserID,'')) [Completed]  
From #tempChangelog1 T  
Group By T.UserID  
  
/*
Insert into #tempResults  
Select T.UserID,   
  /* code commented for fix against ticket no - 46965 starts  
  (Select count(1) From #tempChangelog A where newvalue ='T' and A.UserID = T.UserID) [Clear],  
  (Select count(1) From #tempChangelog B (NoLock)  where newvalue ='F' and isnull(B.UserID,'') = isnull(T.UserID,'')) [Record_Found],  
  (Select count(1) From #tempChangelog C (NoLock)  where newvalue ='P' and isnull(C.UserID,'') = isnull(T.UserID,'')) [More_Info_Needed], */  
  -- code commented for fix against ticket no - 46965 ends  
  --code added for fix against ticket no - 46965 starts  
  (Select count(distinct ID) From #tempChangelog A where newvalue ='T'  and a.SourceValue in('CrimStatus','AIMS','IRIS') and a.OldValue <> '' and A.UserID = T.UserID) [Clear],    
  (Select count(distinct ID) From #tempChangelog B (NoLock)  where newvalue ='F'  and b.SourceValue in('CrimStatus','AIMS','IRIS') and b.OldValue <> '' and isnull(B.UserID,'') = isnull(T.UserID,'')) [Record_Found],    
  (Select count(distinct ID) From #tempChangelog C (NoLock)  where newvalue ='P'   and c.SourceValue in('CrimStatus','AIMS','IRIS') and c.OldValue <> '' and isnull(C.UserID,'') = isnull(T.UserID,'')) [More_Info_Needed],     
  --code added for fix against ticket no - 46965 ends      
  (Select count(1) From #tempChangelog D (NoLock)  where newvalue ='O' and isnull(D.UserID,'') = isnull(T.UserID,'')) [Ordered],  
  (Select count(1) From #tempChangelog E (NoLock)  where newvalue ='R' and isnull(E.UserID,'') = isnull(T.UserID,'')) [Ready_To_Order],  
  (Select count(1) From #tempChangelog F (NoLock)  where newvalue ='I' and isnull(F.UserID,'') = isnull(T.UserID,'')) [Transferred_Record],  
  (Select count(1) From #tempChangelog G (NoLock)  where newvalue ='Z' and isnull(G.UserID,'') = isnull(T.UserID,'')) [Needs_Research],  
  (Select count(1) From #tempChangelog H (NoLock)  where newvalue ='W' and isnull(H.UserID,'') = isnull(T.UserID,'')) [Waiting],  
  (Select count(1) From #tempChangelog I (NoLock)  where newvalue ='X' and isnull(I.UserID,'') = isnull(T.UserID,'')) [Error_Getting_Results],  
  (Select count(1) From #tempChangelog J (NoLock)  where newvalue ='E' and isnull(J.UserID,'') = isnull(T.UserID,'')) [Error_Sending_Results],  
  (Select count(1) From #tempChangelog K (NoLock)  where newvalue ='M' and isnull(K.UserID,'') = isnull(T.UserID,'')) [Ordering],  
  (Select count(1) From #tempChangelog L (NoLock)  where newvalue ='V' and isnull(L.UserID,'') = isnull(T.UserID,'')) [Vendor_Reviewed],  
  (Select count(1) From #tempChangelog M (NoLock)  where newvalue ='N' and isnull(M.UserID,'') = isnull(T.UserID,'')) [Alias_Name_Ordered],  
  (Select count(1) From #tempChangelog N (NoLock)  where newvalue ='Q' and isnull(N.UserID,'') = isnull(T.UserID,'')) [Needs_QA],  
  (Select count(1) From #tempChangelog O (NoLock)  where newvalue ='D' and isnull(O.UserID,'') = isnull(T.UserID,'')) [Review_Reportability],  
  (Select count(1) From #tempChangelog P (NoLock)  where newvalue ='G' and isnull(P.UserID,'') = isnull(T.UserID,'')) [Reinvestigations],  
  (Select count(1) From #tempChangelog Q (NoLock)  where newvalue ='B' and isnull(Q.UserID,'') = isnull(T.UserID,'')) [Clear_Internal],  
  
  (Select count(1) From #tempChangelog R (NoLock)  where newvalue ='C' and isnull(R.UserID,'') = isnull(T.UserID,'')) [Cancelled_by_Client_Incomplete_Results],  
  (Select count(1) From #tempChangelog S (NoLock)  where newvalue ='A' and isnull(S.UserID,'') = isnull(T.UserID,'')) [Cancelled_InternalError_Incomplete_Results],  
  --(Select count(1) From #tempChangelog T (NoLock)  where newvalue ='S' and isnull(T.UserID,'') = isnull(T.UserID,'')) [SeeAttached], --Code commented against ticket# 66955
  (Select count(1) From #tempChangelog SA (NoLock)  where newvalue ='S' and isnull(SA.UserID,'') = isnull(T.UserID,'')) [SeeAttached], --Code added against ticket# 66955
  (Select count(1) From #tempChangelog U (NoLock)  where newvalue ='J' and isnull(U.UserID,'') = isnull(T.UserID,'')) [Do_Not_ReReport],  
  (Select count(1) From #tempChangelog V (NoLock)  where newvalue ='K' and isnull(V.UserID,'') = isnull(T.UserID,'')) [Do_Not_Report],  
  (Select count(1) From #tempChangelog W (NoLock)  where newvalue ='1' and isnull(W.UserID,'') = isnull(T.UserID,'')) [Completed]  
From #tempChangelog T  
INNER JOIN  
 (SELECT SourceValue,UserID,ID, MAX(LogDate) MAXLogDate FROM #tempChangeLog GROUP BY SourceValue,UserID,ID) AS MaxLogDateLog  
 ON MaxLogDateLog.SourceValue = T.SourceValue  
 AND MaxLogDateLog.UserID  = T.UserID  
 AND MaxLogDateLog.MAXLogDate = T.LogDate  
Group By T.UserID  
*/
  
  
select * from #tempResults   
  
UNION ALL  
  
Select 'Totals' UserID,   
sum([Clear]),  
sum([Record_Found]),  
sum([More_Info_Needed]),  
sum([Ordered]),  
sum([Ready_To_Order]),  
sum([Transferred_Record]),  
sum([Needs_Research]),  
sum([Waiting]),  
sum([Error_Getting_Results]),  
sum([Error_Sending_Results]),  
sum([Ordering]),  
sum([Vendor_Reviewed]),  
sum([Alias_Name_Ordered]),  
sum([Needs_QA]),  
sum([Review_Reportability]),  
sum([Reinvestigations]),  
sum([Clear_Internal]),  
sum([Cancelled_by_Client_Incomplete_Results]),  
sum([Cancelled_InternalError_Incomplete_Results]),  
sum([SeeAttached]),  
sum([Do_Not_ReReport]),  
sum([Do_Not_Report]),  
sum([Completed])  
from #tempResults  
  

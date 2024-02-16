------------------------------------------------------------------------------------------------  
-- Requester - Misty Smallwood  
-- Created By - Vairavan A on 06/12/2023  
-- Ticket No. - 97728 - Create new Qreport and name it "Public Records Report Summary Details with Jurisdiction  
---Unit Testing
--Exec [dbo].[PublicRecordsReportSummaryDetailswithJurisdiction]  '05/01/2023','06/13/2023',NULL
---------------------------------------------------------------------------------------------------

--Exec [dbo].[PublicRecordsReportSummaryDetailswithJurisdiction]  '06/13/2023','06/13/2023','AAggarwa'
--EXEC [dbo].[PublicRecordsReportSummaryDetails] '06/13/2023','06/13/2023'

CREATE PROCEDURE [dbo].[PublicRecordsReportSummaryDetailswithJurisdiction]   
@StartDate DateTime,   
@EndDate DateTime, 
@userid  Varchar(100) = NULL
AS  
Set Nocount on  

Drop Table IF EXISTS #tempChangelog  
Drop Table IF EXISTS #tempResults  
Drop Table IF EXISTS #tmp1
Drop Table IF EXISTS #tmp
  
If @userid = ''
  select @userid = NULL
  
--Step 1: Get all the Userid and the newvalues (crimstatus) for the Crim's from the changelog between the date range mentioned.  

CREATE Table #tempChangeLog (UserID varchar(50), OldValue varchar(8000), NewValue varchar(8000), LogDate DATETIME, ID VARCHAR(15), SourceValue VARCHAR(10)) 
    
Insert into #tempChangelog(UserID, OldValue, NewValue,LogDate, ID,SourceValue)    
Select userid, OldValue, newvalue,changedate AS LogDate,ID, 'CrimStatus' AS SourceValue    
  From dbo.changelog with(NoLock)    
 Where TableName = 'Crim.Clear' and (changedate>= cast(@StartDate as date) and changedate< = cast(@EndDate+1 as date)) 
 and userid = isnull(@userid,userid)  


--Step 2: Get all the AIMS agents from the Changelog    
Insert into #tempChangelog(UserID, OldValue, NewValue, LogDate, ID, SourceValue)
Select userid, OldValue, newvalue, changedate AS LogDate, ID,'AIMS' AS SourceValue    
  From dbo.changelog with(NoLock)    
 Where TableName = 'Crim.Status' and (changedate>= cast(@StartDate as date) and changedate< = cast(@EndDate+1 as date))
 and userid = isnull(@userid,userid)   

    
--Step 3: Get the investigator and Crim status for the Crim's from the IRIS result log table between the date range mentioned to the changelog    
Insert into #tempChangelog(UserID, OldValue, NewValue,LogDate, ID, SourceValue)
Select Investigator, Clear AS OldValue, Clear,LogDate, CrimID AS ID,'IRIS' AS SourceValue    
From dbo.IRIS_ResultLog with (Nolock)    
Where (LogDate>= cast(@StartDate as date) and LogDate< = cast(@EndDate+1 as date))
and Investigator = isnull(@userid,Investigator) 


Select  T.UserID,T.ID as Crim_ID,T.SourceValue,T.LogDate,
	   Case when T.newvalue ='T'  and T.OldValue<>''   then  'Clear'
			when T.newvalue ='F'  and T.OldValue<>''   then  'Record Found'
			when T.newvalue ='P'   and T.OldValue<>''  then  'More Information Needed'
			when T.newvalue ='O' then  'Ordered'
			when T.newvalue ='R' then  'Ready To Order'
			when T.newvalue ='I' then  'Transferred Record'
			when T.newvalue ='Z' then  'Needs Research'
			when T.newvalue ='W' then  'Waiting'
			when T.newvalue ='X' then  'Error Getting Results'
			when T.newvalue ='E' then  'Error Sending Results'
			when T.newvalue ='M' then  'Ordering'
			when T.newvalue ='V' then  'Vendor Reviewed'
			when T.newvalue ='N' then  'Alias Name Ordered'
			when T.newvalue ='Q' then  'Needs QA'
			when T.newvalue ='D' then  'Review Reportability'
			when T.newvalue ='G' then  'Reinvestigations'
			when T.newvalue ='B' then  'Clear Internal'
			when T.newvalue ='C' then  'Cancelled by Client Incomplete Results'
			when T.newvalue ='A' then  'Cancelled InternalError Incomplete Results'
			when T.newvalue ='S' then  'SeeAttached'
			when T.newvalue ='J' then  'Do Not ReReport'
			when T.newvalue ='K' then  'Do Not Report'
			when T.newvalue ='1' then  'Completed' 
			else NULL end as Crim_Status
into #tmp1
From #tempChangelog T  
INNER JOIN  
 (SELECT SourceValue,UserID,ID, MAX(LogDate) MAXLogDate FROM #tempChangeLog GROUP BY SourceValue,UserID,ID) AS MaxLogDateLog  
 ON MaxLogDateLog.SourceValue = T.SourceValue  
 AND MaxLogDateLog.UserID  = T.UserID  
 AND MaxLogDateLog.MAXLogDate = T.LogDate  
 
 select   distinct * 
	   into #tmp 
 from #tmp1
  
Select  distinct t.UserID,convert(varchar(10),cast(Ordered as datetime),101) as Date,convert(varchar(10),cast(Ordered as datetime),108) as Time,C.Apno,C.County as Jurisdiction,t.Crim_ID,t.Crim_Status
from crim C with(nolock) 
	 right join
	 #tmp t 
on( c.CrimID = t.Crim_ID --and t.SourceValue = 'CrimStatus'
) where  t.Crim_Status is not null
order by 1 asc,t.Crim_ID asc
  

Set Nocount off



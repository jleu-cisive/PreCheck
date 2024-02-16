


-- =============================================
-- Author:		Douglas DeGeanro
-- Create date: 07/29/2012
-- Description:	This procedure is used in the reference pro integration.  It updates the empl
-- table from using a staging table
-- =============================================
  
  -- =============================================
-- Edited By:		Douglas DeGeanro
-- Edit date: 08/01/2012
-- Description:	Updated procedure to use a variable for the retrieving of the date 
-- =============================================

 -- =============================================
-- Edited By:		Douglas DeGeanro
-- Edit date: 08/03/2012
-- Description:	Added education update information in and changed stored proc name to make more sense
-- =============================================

-- =============================================
-- Edited By:		Douglas DeGeanro
-- Edit date: 08/14/2012
-- Description:	Added cleanup section to do miscellaneous clean up actions
-- =============================================

-- =============================================
-- Edited By:		Douglas DeGeanro
-- Edit date: 08/15/2012
-- Description:	Updated parameter to only receive a date.
-- also updated cleanup section to include education as well
-- =============================================
  
-- =============================================
-- Edited By:		Douglas DeGeanro
-- Edit date: 08/28/2012
-- Description:	Updated Education and Employment pub notes, to write over with what Reference Pro sends us
-- =============================================

-- =============================================
-- Edited By:		Douglas DeGeanro
-- Edit date: 08/29/2012
-- Description:	Changes so it is now joining reference pros notes with what we have (newest first) for testing with ernie
-- =============================================

-- =============================================
-- Edited By:		Santosh Chapyala
-- Edit date: 09/17/2012
-- Description:	public notes appeneded instead of overwriting
-- =============================================    
  
--dbo.Verification_UpdateFromStaging  '8/15/2012 1:24:19 PM';
--select * from empl where web_updated = '2012-08-15 12:41:21.000';
--select * from educat where web_updated = '2012-08-15 12:41:21.000';
--select top 7 * from empl order by web_updated desc

CREATE procedure [dbo].[Verification_UpdateFromStaging_GetNext]
as  
  
declare @insertDate datetime
declare @updateDate datetime

--select * from dbo.[Verification_Staging_Empl] where CreatedDate >= '08/15/2012 10:47'
if (select count(1) from dbo.[Verification_Staging_Empl]) > 0
BEGIN


INSERT INTO [ChangeLog](TableName,ID,OldValue,NewValue,ChangeDate,UserID)
select 'appl.Apstatus',a.apno,'F','P',getdate() ,IsNull(stg.SourceType,'REFPRO') from APPL a join dbo.[Verification_Staging_Empl] stg 
on a.APNO = stg.APNO	
and apstatus ='F'

--INSERT INTO [ChangeLog](TableName,ID,OldValue,NewValue,ChangeDate,UserID)
--select 'appl.Apstatus',apno,'F','P',getdate() ,'REFPRO' from APPL where APNO in  
--	(select distinct apno from dbo.[Verification_Staging_Empl])
--	and apstatus ='F'

	-- updates the appl table from Final to Pending if   
	update appl  
	set apstatus ='P'   
	where apno in  
	(select distinct apno from dbo.[Verification_Staging_Empl] )
	and apstatus ='F'




	
	--We update the temp table only for the cancelled ones
		update dbo.Verification_Staging_Empl
		set 
			Private_notes = IsNull(cast(public_notes as nvarchar(max)),'') + char(10) + char(13) + IsNull(cast(Private_Notes as nvarchar(max)),'') ,
			public_notes = null
		where Web_Status = 64 and Public_notes is not null 
						
		
	
	  

	

update e
 set From_V = (Case When ((t.FromDate <> '' or t.ToDate <> '') and t.SourceType = 'WorkNumber') then t.FromDate 
                   When t.SourceType = '' then IsNull(t.FromDate,e.From_V) 
				   Else  e.From_V end
				   ),

   To_V = (Case When ((t.FromDate <> '' or t.ToDate <> '') and t.SourceType = 'WorkNumber') then t.ToDate
                When (t.SourceType = '') then IsNull(t.ToDate,e.To_V) 
			    Else e.To_V end
				),  

   Position_V = (Case When ((t.FromDate <> '' or t.ToDate <> '') and t.SourceType = 'WorkNumber') then t.Position 
                      When (t.SourceType = '') then IsNull(t.Position,e.Position_V) 
					  Else e.Position_V end), 
					   
  Salary_V = IsNull(t.Salary,e.Salary_V),    
  RFL = IsNull(t.RFL,e.RFL),    
  Ver_By = IsNull(t.Ver_By,e.Ver_By),    
  Title = IsNull(t.Title,e.Title),    

   Pub_Notes = isnull(t.Public_Notes,'') + char(10) + char(13) + isnull(cast(e.Pub_Notes as varchar(max)),''),  
  -- Pub_Notes = IsNull(t.Public_Notes,e.Pub_Notes),  
  Web_Status = t.Web_Status,    
  SectStat = t.SectStat, 
 Priv_Notes = isnull(t.Private_Notes,'') + char(10) + char(13) + isnull(cast(e.Priv_Notes as varchar(max)),''),     
 
  IsOnReport = IsNull(t.IsOnReport,e.IsOnReport),  
  web_updated = t.CreatedDate, 
  InUse = null      
 FROM    
 dbo.empl e inner join dbo.[Verification_Staging_Empl] t on e.emplid = t.emplid

 update dbo.Integration_Verification_SourceCode
 set IsChecked = 1    
 FROM    
 dbo.Integration_Verification_SourceCode i inner join dbo.[Verification_Staging_Empl] t on i.SectionKeyID = t.emplid
 where t.sectstat = 5 --or t.Web_Status = 60

 Set @updateDate = getdate();

 update dbo.ApplSections_Followup 
set Repeat_Followup = 1,
    CompletedBy = e.investigator,
    CompletedOn = @updateDate 
from dbo.ApplSections_Followup(nolock) af join Verification_Staging_Empl (nolock) vs
on af.ApplSectionID = vs.emplid
join empl(nolock) e on vs.emplid = e.emplid
where af.Repeat_Followup = 0 and vs.web_status = 74

INSERT INTO dbo.ApplSections_Followup (
			ApplSectionID,
			Apno,
			SectionID,
			Reason,
			CreatedBy,
			CreatedOn,
			FollowupOn,
			IsCompleted,
			Repeat_Followup)

	select distinct vs.emplid,
			e.Apno,
			'empl',
			'Follow-up Interval',
			isnull(e.investigator, 'WNWINServ'),
			CURRENT_TIMESTAMP,
			@updateDate,
			0,
			0
			 from  Verification_Staging_Empl (nolock) vs 

join empl(nolock) e on vs.emplid = e.emplid
where vs.web_status = 74 
--and vs.emplid not in (
--select ApplSectionID from dbo.ApplSections_Followup(nolock) af join 
--Verification_Staging_Empl (nolock) vs1 
--on af.ApplSectionID = vs1.emplid)


UPDATE dbo.EmplGetNextStaging
        SET FollowUpOn = @updateDate,
                web_status = 74
        FROM dbo.EmplGetNextStaging (nolock) eg
		JOIN Verification_Staging_Empl (nolock) vs
		ON eg.EmplId = vs.EmplID
where vs.web_status = 74 
 --AND CLNO IN (11404, 1932, 1937, 9044, 8317, 10107, 2167, 3062, 1023, 2821, 1934, 2331)-- Temp Change for 01/18 only

INSERT INTO dbo.EmplGetNextStaging (
			[APNO]
           ,[EmplID]
           ,[Employer]
           ,[EmployerID]
           ,[ApDate]
           ,[IsOnReport]
           ,[Rush]
           ,[SectStat]
           ,[ApStatus]
           ,[web_status]
           ,[OkToContact]
           ,[HighProfile]
           ,[PrecheckChallenge]
           ,[Affiliate]
           ,[CLNO]
           ,[ClientName]
           ,[Investigator]
           ,[Last_Updated]
           ,[ApplInUse]
           ,[EmplInvestigatorID1]
           ,[EmplInvestigatorID2]
           ,[EmplInvestigatorID3]
           ,[EmplInvestigatorID4]
           ,[ApplicationTimeZone]
           ,[TimeZone]
           ,[QueueType]
           ,[TransitionalState]
           ,[AppPickedUpDate]
           ,[StagingRunDate]
           ,[FollowUpOn])

	select distinct 
			e.apno
           ,e.EmplID
           ,e.Employer
           ,e.[EmployerID] as [EmployerID]
           ,a.ApDate as [ApDate]
           ,e.[IsOnReport] as [IsOnReport]
           ,a.Rush as [Rush]
           ,e.[SectStat] as [SectStat]
           ,a.ApStatus as [ApStatus]
           ,e.[web_status]
           ,e.[IsOkToContact] as [OkToContact]
           ,c.[HighProfile] as [HighProfile]
           ,a.[PrecheckChallenge] as [PrecheckChallenge]
           ,null as [Affiliate]
           ,a.clno as [CLNO]
           ,c.name as [ClientName]
           ,e.[Investigator]
           ,e.[Last_Updated] as [Last_Updated]
           ,null as [ApplInUse]
           ,null as [EmplInvestigatorID1]
           ,null as [EmplInvestigatorID2]
           ,null as [EmplInvestigatorID3]
           ,null as [EmplInvestigatorID4]
           ,null as [ApplicationTimeZone]
           ,dbo.fnGetTimeZone(e.zipcode,e.city,e.State) as [TimeZone]
           ,'FollowUps' as [QueueType]
           ,null as [TransitionalState]
           ,null as [AppPickedUpDate]
           ,null as [StagingRunDate]
           ,@updateDate as [FollowUpOn]
			 from  Verification_Staging_Empl (nolock) vs 

join empl(nolock) e on vs.emplid = e.emplid
join appl (nolock) a on a.apno = e.apno
join client (nolock) c on c.clno = a.clno
--join dbo.EmplGetNextStaging(nolock) egs on egs.emplid = e.emplid
--join DBO.[fnGetSupportedTimeZonesByTime] (convert(time,CURRENT_TIMESTAMP)) Z on egs.TimeZone = Z.TimeZone
where vs.web_status = 74 and vs.emplid not in (
				select eg.EmplID from dbo.EmplGetNextStaging(nolock) eg join 
				Verification_Staging_Empl (nolock) vs1 
				on eg.emplid = vs1.emplid)
 --AND a.CLNO IN (11404, 1932, 1937, 9044, 8317, 10107, 2167, 3062, 1023, 2821, 1934, 2331) -- Temp Change for 01/18 only


        
	set @insertDate = CURRENT_TIMESTAMP	  	
			
	-- log from staging table
	 INSERT INTO [dbo].[Verification_RP_Logging_Empl]
			   ([EmplId]
			   ,[FromDate]
			   ,[ToDate]
			   ,[Position]
			   ,[Salary]
			   ,[RFL]
			   ,[Ver_By]
			   ,[Title]
			   ,[Web_Status]
			   ,[SectStat]
			   ,[Private_Notes]
			   ,[Public_Notes]
			   ,[Alias1_First]
			   ,[Alias1_Middle]
			   ,[Alias1_Last]
			   ,[Alias2_First]
			   ,[Alias2_Middle]
			   ,[Alias2_Last]
			   ,[Alias3_First]
			   ,[Alias3_Middle]
			   ,[Alias3_Last]
			   ,[APNO]
			   ,[IsOnReport]
			   ,[CreatedDate]
			   ,[SourceType])
	SELECT [EmplId]
		  ,[FromDate]
		  ,[ToDate]
		  ,[Position]
		  ,[Salary]
		  ,[RFL]
		  ,[Ver_By]
		  ,[Title]
		  ,[Web_Status]
		  ,[SectStat]
		  ,[Private_Notes]
		  ,[Public_Notes]
		  ,[Alias1_First]
		  ,[Alias1_Middle]
		  ,[Alias1_Last]
		  ,[Alias2_First]
		  ,[Alias2_Middle]
		  ,[Alias2_Last]
		  ,[Alias3_First]
		  ,[Alias3_Middle]
		  ,[Alias3_Last]
		  ,[APNO]
		  ,[IsOnReport]
		  ,@insertDate
		  ,IsNull([SourceType],'REFPRO')

	   FROM [dbo].[Verification_Staging_Empl]
		


		-- empty out staging table if succesful
		if ((Select Count(*) from [Verification_RP_Logging_Empl] where CreatedDate = @insertDate)= (Select Count(*) from [Verification_Staging_Empl]))
			Truncate table [Verification_Staging_Empl]
END









	
	
	




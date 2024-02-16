
create procedure [dbo].[Verification_UpdateFromWorkNumberStaging]
as  
  
declare @insertDate datetime

--select * from dbo.[Verification_Staging_Empl] where CreatedDate >= '08/15/2012 10:47'
if (select count(1) from dbo.[Verification_Staging_WorkNumber]) > 0
BEGIN

INSERT INTO [ChangeLog](TableName,ID,OldValue,NewValue,ChangeDate,UserID)
select 'appl.Apstatus',apno,'F','P',getdate() ,'WorkNumber' from APPL where APNO in  
	(select distinct apno from dbo.[Verification_Staging_Empl] )
	and apstatus ='F'

	-- updates the appl table from Final to Pending if   
	update appl  
	set apstatus ='P'   
	where apno in  
	(select distinct apno from dbo.[Verification_Staging_WorkNumber] )
	and apstatus ='F'




	
	--We update the temp table only for the cancelled ones
		update dbo.Verification_Staging_WorkNumber
		set 
			Private_notes = IsNull(cast(public_notes as nvarchar(max)),'') + char(10) + char(13) + IsNull(cast(Private_Notes as nvarchar(max)),'') ,
			public_notes = null
		where Web_Status = 64 and Public_notes is not null 
						
		
	
	  

	

update e
 set From_V = IsNull(t.FromDate,e.From_V) ,    
  To_V = IsNull(t.ToDate,e.To_V),    
  Position_V = IsNull(t.Position,e.Position_V),    
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
 dbo.empl e inner join dbo.[Verification_Staging_WorkNumber] t on e.emplid = t.emplid

 update dbo.Integration_Verification_SourceCode
 set IsChecked = 1    
 FROM    
 dbo.Integration_Verification_SourceCode i inner join dbo.[Verification_Staging_WorkNumber] t on i.SectionKeyID = t.emplid
 where t.sectstat = 5 --or t.Web_Status = 60


	set @insertDate = CURRENT_TIMESTAMP	  	
			
	-- log from staging table
	 INSERT INTO [dbo].[Verification_WorkNumber_Logging]
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
			   ,[CreatedDate])
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
	   FROM [dbo].[Verification_Staging_WorkNumber]
		


		-- empty out staging table if succesful
		if ((Select Count(*) from [Verification_WorkNumber_Logging] where CreatedDate = @insertDate)= (Select Count(*) from [Verification_Staging_WorkNumber]))
			Truncate table [Verification_Staging_WorkNumber]
END




	
	
	



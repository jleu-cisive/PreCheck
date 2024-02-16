

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

create procedure [dbo].[Verification_UpdateFromStaging06162015]
as  
  
declare @insertDate datetime

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

------------Education---------------------
--if (@section = 'Education')
if (@insertDate is null)
	set @insertDate = CURRENT_TIMESTAMP	

if (select count(1) from dbo.[Verification_Staging_Educat]) > 0
BEGIN

INSERT INTO [ChangeLog](TableName,ID,OldValue,NewValue,ChangeDate,UserID)
select 'appl.Apstatus',apno,'F','P',getdate() ,'REFPRO' from APPL where APNO in  
	(select distinct apno from dbo.[Verification_Staging_Educat] )
	and apstatus ='F'

  -- updates the appl table from Final to Pending if   
update appl  
set apstatus ='P'   
where apno in  
	(select distinct apno from dbo.[Verification_Staging_Educat] )
and apstatus ='F'  
  
--We update the temp table only for the cancelled ones
update dbo.Verification_Staging_Educat
		set 
			Private_notes = IsNull(cast(public_notes as nvarchar(max)),'') + char(10) + char(13) + IsNull(cast(Private_Notes as nvarchar(max)),'') ,
			public_notes = null
		where Web_Status = 64 and Public_Notes is not null



update e
set From_V = IsNull(t.FromDate,e.From_V),    
 To_V = IsNull(t.ToDate,e.To_V) ,   
 Degree_V = IsNull(t.Degree,e.Degree_V),  
 Studies_V = IsNull(t.Studies,e.Studies_V),  
 city = IsNull(t.City,e.City),  
 Phone = IsNull(t.Phone,e.Phone),  
 State = IsNull(t.State,e.State),  
 School = IsNull(t.School,e.School),    
 Contact_Name = IsNull(t.Ver_By,e.Contact_Name),    
 Contact_Title = IsNull(t.Title,e.Contact_Title),  
   Pub_Notes = isnull(t.Public_Notes,'') + char(10) + char(13) + isnull(cast(e.Pub_Notes as varchar(max)),''),  
--Pub_Notes = IsNull(t.Public_Notes,e.Pub_Notes),    
 Web_Status = t.Web_Status,    
 SectStat = t.SectStat,   
Priv_Notes = isnull(t.Private_Notes,'') + char(10) + char(13) + isnull(cast(e.Priv_Notes as varchar(max)),''),   
 --Priv_Notes = cast(Priv_Notes as varchar(max)) + '\r\n' + IsNull(t.Private_Notes,e.Priv_Notes),    
 IsOnReport = IsNull(t.IsOnReport,e.IsOnReport) ,  
 web_updated = t.CreatedDate    
 FROM dbo.Educat e inner join dbo.[Verification_Staging_Educat] t on e.educatid = t.educatid



INSERT INTO [dbo].[Verification_RP_Logging_Educat]
           ([EducatId]
           ,[FromDate]
           ,[ToDate]
           ,[Degree]
           ,[Studies]
           ,[City]
           ,[Phone]
           ,[School]
           ,[State]
           ,[SectStat]
           ,[Web_Status]
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
           ,[Ver_By]
           ,[Title])
           SELECT [EducatId]
      ,[FromDate]
      ,[ToDate]
      ,[Degree]
      ,[Studies]
      ,[City]
      ,[Phone]
      ,[School]
      ,[State]
      ,[SectStat]
      ,[Web_Status]
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
      ,[Ver_By]
      ,[Title]
  FROM [dbo].[Verification_Staging_Educat]
  
  
  if ((Select Count(*) from [Verification_RP_Logging_Educat] where CreatedDate = @insertDate)= (Select Count(*) from [Verification_Staging_Educat]))
       Truncate table [Verification_Staging_Educat]
       

  

						
		
		
END









	
	
	



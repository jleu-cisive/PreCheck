


-- =============================================  
-- Author:  Douglas DeGenaro  
-- Create date: 03/11/2013  
-- Description: Updates the corresponding table based on the staging table  
-- =============================================  
--select * from dbo.PrecheckFramework_ApplStaging where folderId = 'OASIS_TEST'  
--dbo.PrecheckFramework_UpdateFromStaging 'OASIS_TEST',2110603,'ApplicationData'  
--select * from appl where apno = 2110603  
--truncate table dbo.PrecheckFramework_ApplStaging   
--dbo.PrecheckFramework_UpdateFromStaging '0111010101023','2188057','ddegenaro','Employment'  
CREATE PROCEDURE [dbo].[PrecheckFramework_UpdateFromStaging_bkp02192014]
 -- Add the parameters for the stored procedure here  
 @folderId varchar(50),   
 @apno int,  
 @userName varchar(8) = null,  
 @sectionList varchar(100) = null,
 @DateEntered Datetime = null,
 @UnLockAppl Bit = 1
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
 DECLARE @flag int  
 DECLARE @count int  
 DECLARE @sectionOption varchar(50)  
 declare @ssn varchar(11)  
 declare @dob datetime  
 declare @apstatus varchar(2)  
   
 declare @id int  
 declare @BigCounty varchar(75)
 declare @CLNO int  
  
   

 --SET @count = (select count(*) from fn_Split(@sectionList,'|'));  
 --SET @flag = 0  
 --WHILE (@flag <= @count)  
 --BEGIN  
  -- Insert new records if we have dont have sectionIds  
 --SET @sectionOption = (SELECT value FROM fn_Split(@sectionList,'|') WHERE idx = @flag);   
   
 declare @crimid int
 IF (charindex('UnlockAppl',@sectionList) > 0)  
	set @SectionList = REPLACE(@SectionList,'UnlockAppl','')


 --If Credit is Ordered, send an email to the distribution list to notify them to run the candidate's Credit history
 --moved this logic to create orders -schapyala 08/05/2013
 --IF (charindex('Order_Credit',@sectionList) > 0)  
	--BEGIN
	--	IF (SELECT count(apno) FROM dbo.Credit WHERE apno = @apno and RepType='C') = 0  
	--	 BEGIN
	--		Declare @msg nvarchar(500), @Sub nvarchar(200)

 --			Select @msg = 'This is to inform you that Client:  ' + cast(Name as nvarchar)+ '(' + cast(A.CLNO as nvarchar) + ') requires/requested Credit to be ordered for Report# ' + cast(@apno as varchar) + '; ' + char(9) + char(13)+ char(9) + char(13) +   'Applicant: ' + A.First + ' ' + A.Last  + char(9) + char(13)+ char(9) + char(13) +   'Thank you.'
	--		From DBO.APPL A inner join DBO.Client C on A.CLNO = C.CLNO
	--		Where APNO = @apno

	--		Set @Sub = 'Credit Requested For Report# ' + cast(@apno as varchar) + '; Requested By: ' + @userName

	--		EXEC msdb.dbo.sp_send_dbmail    @from_address=N'CreditReports@PreCheck.com', @recipients=N'CreditReports@PreCheck.com', @subject= @Sub,   @body=@msg ;
	--	 END
	--END
 
  --Start orders  
 if (PATINDEX('%Order_%',@sectionList) > 0)
	exec dbo.PrecheckFramework_CreateOrders @sectionList,@apno,@userName


 --truncate Username to 8 characters --should be relaxed later
  if (@userName is not null)
	set @userName = Left(@userName,8)

 IF (SELECT count(FolderId) from dbo.PrecheckFramework_ApplAliasStaging where @folderId = folderId and apno = @apno and CreatedDate >= @DateEntered) > 0
 BEGIN
		
	
	
	
	
	insert into dbo.ApplAlias
	(
	Apno,
	First,
	Middle,
	Last,
	IsMaiden,
	AddedBy)
	select 
	@Apno,
	First,
	Middle,
	Last,
	IsMaiden,
	@userName	
	from 
		dbo.PrecheckFramework_ApplAliasStaging  
         where IsNull(SectionID,'') = ''  
    and apno = @apno  
	and CreatedDate >= @DateEntered
	and Deleted = 0
	
	--added on 05/02/2013 to delete entries that are set for deleted in the staging table
	delete 
		alias
	FROM     
       [dbo].[ApplAlias] alias         
       JOIN   
       [dbo].[PrecheckFramework_ApplAliasStaging] stg   
       ON  
       stg.Apno = alias.Apno and 
      stg.SectionId = alias.ApplAliasId   
      where          
       stg.CreatedDate >= @DateEntered	
       and stg.Deleted = 1 
	
	
				

	update
		alias	
	set 
		First = stg.First,
		Middle = stg.Middle,
		Last = stg.Last,		
		IsMaiden = stg.IsMaiden
	FROM     
       [dbo].[ApplAlias] alias         
       JOIN   
       [dbo].[PrecheckFramework_ApplAliasStaging] stg   
       ON  
       stg.Apno = alias.Apno and stg.SectionId = alias.ApplAliasId   
      where   
       IsNull(stg.SectionID,'') <> '' and stg.FolderId = @folderId  	
       and stg.CreatedDate >= @DateEntered
       
       DELETE FROM   
      [dbo].[PrecheckFramework_ApplAliasStaging]   
        WHERE   
         FolderId = @FolderId and apno = @apno 
 
 END
       
 IF (charindex('ApplicationData',@sectionList) > 0)  
 BEGIN       
  IF (SELECT count(folderId) FROM [dbo].[PrecheckFramework_ApplStaging] WHERE @folderId = folderId and apno = @apno 	and CreatedDate >= @DateEntered) > 0  
  BEGIN   
  
	  UPDATE   
		a   
	   SET   
		First = t.First, 
		clno = t.clno, 
		Last = t.Last,  
		Middle = t.Middle,  
		Generation = t.Generation,   
		SSN = t.SSN,  
		GetNextDate = t.GetNextDate, 
		SubStatusID = Case When isnull(t.GetNextDate,'') = '' then 28 else 7 end,
		DOB = t.DOB,  
		  Last_Updated = CURRENT_TIMESTAMP,  
		  StartDate = Case When isnull(t.StartDate,'') = '' then a.StartDate else t.StartDate end ,  
		  Addr_Num = t.Addr_Num,  
		  Addr_Street = t.Addr_Street,    
		  Addr_Apt = t.Addr_Apt,          
		  Addr_Dir = t.Addr_Dir,  
		  Attn = Case When isnull(t.Attn,'') = '' then a.Attn else left(t.Attn,25) end , 
		  City = t.City, 
		  State = t.State,      
		  Zip = t.Zip,      
		  Rush = isnull(t.Rush,0),       
		  Recruiter_Email = t.Recruiter_Email ,    
		  Email = t.Email,  
		  Phone = t.Phone,  
		  FreeReport = isnull(t.FreeReport,0),  
		  Alias1_First=t.Alias1_First,     
		  Alias1_Middle=t.Alias1_Middle,       
		  Alias1_Last=t.Alias1_Last,    
		  Alias1_Generation =t.Alias1_Generation,  
		  Alias2_First=t.Alias2_First,  
		  Alias2_Middle =t.Alias2_Middle,  
		  Alias2_Last=t.Alias2_Last,  
		  Alias2_Generation =t.Alias2_Generation,   
		Alias3_First  =t.Alias3_First,    
		  Alias3_Middle=t.Alias3_Middle,   
		  Alias3_Last=t.Alias3_Last,        
		  Alias3_Generation=t.Alias3_Generation,        
		  Alias4_First=t.Alias4_First,  
		  Alias4_Middle=t.Alias4_Middle,     
		  Alias4_Last =t.Alias4_Last,      
		  Alias4_Generation =t.Alias4_Generation,      
		  Priv_Notes = cast(t.Priv_Notes as varchar(max)),-- + CHAR(13) + IsNull(cast(a.Priv_Notes as varchar(max)),''),        
		  DL_Number=t.DL_Number,    
		  DL_State=t.DL_State,  
		  Pos_Sought=t.Pos_Sought,      
		  Special_Instructions = cast(t.Special_Instructions as varchar(max)),-- + CHAR(13) + IsNull(cast(a.Special_Instructions as varchar(max)),''),         
		  PrecheckChallenge=isnull(t.PrecheckChallenge,0),        
		  Investigator= Case When isnull(a.Investigator,'') = '' then left(t.Investigator,8) else  a.Investigator end ,
		  UserID=Case When isnull(t.UserID,'') = '' then a.UserID else t.UserID end ,        
		  ApStatus=t.ApStatus,  
		  PackageId=t.PackageId,  
		  Rel_Attached = t.Rel_Attached,  
		  DeptCode=t.DeptCode,     
		  OrigCompDate =Case when isnull(t.OrigCompDate,'') ='' then a.OrigCompDate else t.OrigCompDate end,     
		  CompDate =Case when isnull(t.CompDate,'') ='' then a.CompDate else t.CompDate end,   
		  I94=Case when isnull(t.I94,'') ='' then a.I94 else t.I94 end,   
		  ReOpenDate=Case when isnull(t.ReOpenDate,'') ='' then a.ReOpenDate else t.ReOpenDate end,       
		  Pub_Notes = cast(t.Pub_Notes as varchar(max)),-- + IsNull(cast(a.Pub_Notes as varchar(max)),''),  
		  NeedsReview=Case When Isnull(t.NeedsReview,'')='' then a.NeedsReview else t.NeedsReview end,
		  ClientAPNO = Case When Isnull(a.ClientAPNO,'')='' then t.ClientAPNO else a.ClientAPNO end,
		  ClientApplicantNO = (Case When  Isnull(a.ClientAPNO,'')='' then a.ClientApplicantNO 
								   when Isnull(a.ClientAPNO,'') = t.ClientAPNO then a.ClientApplicantNO 
		                           When  Isnull(a.ClientApplicantNO,'')='' then t.ClientAPNO else a.ClientApplicantNO end)
	   FROM  
		dbo.Appl a  
	   JOIN  
		[dbo].[PrecheckFramework_ApplStaging] t  
	   ON   
		 t.Apno = a.Apno    
	   WHERE t.FolderId = @folderId  
	   and  t.CreatedDate >= @DateEntered      
   
  
 
           
		DELETE FROM   
		[dbo].[PrecheckFramework_ApplStaging]   
		WHERE   
		FolderId = @FolderId and apno = @apno  

  END   
   
          
    END  
      
 IF (charindex('Employment',@sectionList) > 0)  
  BEGIN  
   IF (SELECT COUNT(folderId) FROM dbo.PrecheckFramework_EmplStaging WHERE @folderId = folderId and CreatedDate >= @DateEntered) > 0   
   BEGIN  
    --This takes care of the inserts  
    INSERT INTO [dbo].[Empl]  
         ([Apno]  
         ,[Employer]  
         ,[Location]  
         ,[SectStat]  
         ,[Worksheet]  
         ,[Phone]  
         ,[Supervisor]  
         ,[SupPhone]  
         ,[Dept]  
         ,[RFL]  
         ,[DNC]  
         ,[SpecialQ]  
         ,[Ver_Salary]  
         ,[From_A]  
         ,[To_A]  
         ,[Position_A]  
         ,[Salary_A]  
         ,[From_V]  
         ,[To_V]  
         ,[Position_V]  
         ,[Salary_V]  
         ,[Emp_Type]  
         ,[Rel_Cond]  
         ,[Rehire]  
         ,[Ver_By]  
         ,[Title]  
         ,[Priv_Notes]  
         ,[Pub_Notes]  
         ,[web_status]  
         ,[web_updated]  
         ,[Includealias]  
         ,[Includealias2]  
         ,[Includealias3]  
         ,[Includealias4]  
         ,[PendingUpdated]  
         ,[Time_In]  
         ,[Last_Updated]  
         ,[city]  
       ,[state]  
         ,[zipcode]  
         ,[Investigator]  
         ,[EmployerID]  
         ,[InvestigatorAssigned]  
         ,[PendingChanged]  
         ,[TempInvestigator]  
         ,[InUse]  
         ,[CreatedDate]  
         ,[EnteredBy]  
         ,[EnteredDate]  
         ,[IsCamReview]  
         ,[Last_Worked]  
         ,[ClientEmployerID]  
         ,[AutoFaxStatus]  
         ,[IsOnReport]  
         ,[IsHidden]  
         ,[IsHistoryRecord]  
         ,[EmploymentStatus]  
         ,[IsOKtoContact]  
         ,[OKtoContactInitial]  
         ,[EmplVerifyID]  
         ,[GetNextDate]  
         ,[SubStatusID]  
         ,[ClientAdjudicationStatus]  
         ,[ClientRefID]  
         ,[IsIntl]  
         ,[DateOrdered]  
         ,[OrderId]  
         ,[AdverseRFL]  
         ,Email)  
         select   
         [Apno]  
         ,[Employer]  
         ,[Location]  
         ,IsNull([SectStat],'0') as SectStat  
         ,IsNull([Worksheet],1) as WorkSheet  
         ,[Phone]  
         ,[Supervisor]  
         ,[SupPhone]  
         ,[Dept]  
         ,[RFL]  
         ,IsNull([DNC],0) as DNC  
         ,IsNull([SpecialQ],0) as SpecialQ  
         ,IsNull([Ver_Salary],0) as Ver_Salary  
         ,[From_A]  
         ,[To_A]  
         ,[Position_A]  
         ,[Salary_A]  
         ,[From_V]  
         ,[To_V]  
         ,[Position_V]  
         ,[Salary_V]  
         ,IsNull([Emp_Type],'N') as Emp_Type  
         ,IsNull([Rel_Cond],'N') as Rel_Cond  
         ,[Rehire]  
         ,[Ver_By]  
         ,[Title]  
         ,[Priv_Notes]  
         ,[Pub_Notes]  
         ,Isnull([web_status],0) as web_status  
         ,IsNull([web_updated],Current_Timestamp) as web_updated  
         ,IsNull([Includealias],'y') as [Includealias]  
         ,IsNull([Includealias2],'y') as [Includealias2]  
         ,IsNull([Includealias3],'y') as [Includealias3]  
         ,IsNull([Includealias4],'y') as [Includealias4]  
         ,[PendingUpdated]  
         ,IsNull([Time_In],Current_Timestamp) as Time_In  
         ,[Last_Updated]  
         ,[city]  
         ,[state]  
         ,[zipcode]  
         ,[Investigator]  
         ,[EmployerID]  
         ,[InvestigatorAssigned]  
         ,[PendingChanged]  
         ,[TempInvestigator]  
         ,NULL --@userName as InUse  
         ,IsNull([CreatedDate],Current_Timestamp) as CreatedDate  
         ,[EnteredBy]  
         ,[EnteredDate]  
         ,IsNull([IsCamReview],0) as IsCamReview  
         ,[Last_Worked]  
         ,[ClientEmployerID]  
         ,[AutoFaxStatus]  
         ,IsNull([IsOnReport],0) as IsOnReport  
         ,IsNull([IsHidden],0) as IsHidden  
         ,IsNull([IsHistoryRecord],0) as IsHistoryRecord  
         ,[EmploymentStatus]  
         ,IsNull([IsOKtoContact],0) as [IsOKtoContact]  
         ,[OKtoContactInitial]  
         ,[EmplVerifyID]  
         ,[GetNextDate]  
         ,[SubStatusID]  
         ,[ClientAdjudicationStatus]  
         ,[ClientRefID]  
         ,IsNull([IsIntl],0) as IsIntl  
         ,[DateOrdered]  
         ,[OrderId]  
         ,[AdverseRFL]  
         ,Email  
         from dbo.PrecheckFramework_EmplStaging  
         where IsNull(SectionID,'') = ''  
         and apno = @apno   
		 and FolderId = @folderId 
	     and CreatedDate >= @DateEntered 
          
        -- This takes care of the updates  
        UPDATE  e  
         SET   
          [Employer] = stg.Employer  
         ,[Location] = stg.Location  
         ,[city] = stg.city  
         ,[state] = stg.[state]  
         ,[zipcode] = stg.[zipcode]  
         ,[Position_A] = stg.[Position_A]  
         ,[Position_V] = stg.[Position_V]  
         ,[SpecialQ] = IsNull(stg.[SpecialQ],0)  
         ,[Ver_Salary] = IsNull(stg.[Ver_Salary],0)  
         ,[AdverseRFL] = IsNull(stg.AdverseRFL,0)  
         ,[From_A] = stg.[From_A]  
         ,[To_A] = stg.[To_A]  
          ,[From_V] = stg.[From_V]  
         ,[To_V] = stg.[To_V]  
         ,[Dept] = stg.[Dept]  
          ,[DNC] = IsNull(stg.[DNC],0)         
         ,[RFL] = stg.[RFL]  
         ,[Phone] = stg.Phone  
          ,[Supervisor] = stg.[Supervisor]  
         ,[SupPhone] = stg.[SupPhone]  
          ,Priv_Notes = cast(stg.Priv_Notes as varchar(max))-- + CHAR(13) + IsNull(cast(e.Priv_Notes as varchar(max)),'')  
          ,Pub_Notes = cast(stg.Pub_Notes as varchar(max))-- + CHAR(13) + IsNull(cast(e.Pub_Notes as varchar(max)),'')  
         ,[IsOnReport] = IsNull(stg.[IsOnReport],0)  
            ,[IsHidden] = IsNull(stg.[IsHidden],0)  
         ,[IsHistoryRecord] = IsNull(stg.[IsHistoryRecord],0)  
         ,[Title] = stg.[Title]  
         ,[Emp_Type] = IsNull(stg.[Emp_Type],'N')
         ,[Rel_Cond] = IsNull(stg.[Rel_Cond],'N')  
         ,[Rehire] = stg.[Rehire]  
         ,[web_status] = Isnull(stg.[web_status],0)  
          ,[SectStat] = IsNull(stg.[SectStat],'0')  
          ,[Worksheet] = IsNull(stg.[Worksheet],1)   
         ,[Ver_By] = stg.[Ver_By]  
         ,[IsOKtoContact] = IsNull(stg.[IsOKtoContact],0)  
         --,[Apno] = stg.Apno,e.Apno)  
         ,[Investigator] = stg.[Investigator]  
           ,[IsIntl] = IsNull(stg.IsIntl,0)
         --,[CreatedDate] = IsNull(stg.[CreatedDate],Current_Timestamp)  
         ,[IsCamReview] = IsNull(stg.[IsCamReview],0)  
         --,[Time_In] = IsNull(stg.[Time_In],Current_Timestamp)           
         ,[InUse] = null -- @UserName
		 , InUse_TimeStamp=NULL  
         ,[Includealias] = IsNull(stg.[Includealias],'y')  
         ,[Includealias2] = IsNull(stg.[Includealias2],'y')  
            ,[Includealias3] = IsNull(stg.[Includealias3],'y')  
            ,[Includealias4] = IsNull(stg.[Includealias4],'y')  
            ,[web_updated] = IsNull(stg.[web_updated],Current_Timestamp)  
            ,Email = stg.Email            
       FROM  
       [dbo].[Empl] e         
       JOIN   
       [dbo].[PrecheckFramework_EmplStaging] stg   
       ON  
       stg.Apno = e.Apno and stg.SectionId = e.EmplId   
      where   
       IsNull(stg.SectionID,'') <> '' and stg.FolderId = @folderId 
	   and stg.CreatedDate >= @DateEntered 
	            
        DELETE FROM   
         [dbo].[PrecheckFramework_EmplStaging]   
        WHERE   
         FolderId = @FolderId and apno = @apno 
		 --and IsNull(SectionId,'') <> ''  
     END  
	  IF (charindex('LockAppl',@sectionList) = 0) 
	  Begin
		  Update [dbo].[Empl]
		   Set Inuse = NULL, InUse_TimeStamp=NULL
		   WHERE apno = @apno and Inuse = @UserName
	  End
          
  END  
      
    -- Personal Reference ----  
    IF (charindex('PersRef',@sectionList) > 0)  
    BEGIN  
     IF (SELECT count(folderId) FROM [dbo].[PrecheckFramework_PersRefStaging] WHERE @folderId = folderId and apno = @apno and CreatedDate >= @DateEntered ) > 0  
     BEGIN  
     Update pr  
     set  [IsCAMReview] = IsNull(stg.[IsCAMReview],0)                   
        ,IsHidden = IsNull(stg.IsHidden,0)  
       ,Name = stg.Name         
       ,Investigator = stg.Investigator        
       ,IsOnReport = IsNull(stg.IsOnReport,0)  
       ,Phone = stg.Phone  
       ,Rel_V = stg.Rel_V  
       ,Years_V = stg.Years_V         
       ,Priv_Notes = cast(stg.Priv_Notes as varchar(max))  
       ,Pub_Notes = cast(stg.Pub_Notes as varchar(max))  
       ,Web_Status = IsNull(stg.Web_Status,0)  
      ,SectStat = IsNull(stg.SectStat,'0')  
       ,InUse = null -- @UserName
	   , InUse_TimeStamp=NULL  
       ,Email = stg.Email  
       ,JobTitle = stg.JobTitle  
       FROM  
      [dbo].[PersRef] pr         
     JOIN   
      [dbo].[PrecheckFramework_PersRefStaging] stg   
     ON  
      stg.Apno = pr.Apno and stg.SectionId = pr.PersRefId   
      where   
       IsNull(stg.SectionID,'') <> '' and stg.FolderId = @folderId 
	   and stg.CreatedDate >= @DateEntered    
  
        
      Insert Into dbo.PersRef  
     (  
      [APNO]  
       ,[SectStat]  
       ,[Worksheet]  
       ,[Name]  
       ,[Phone]  
       ,[Rel_V]  
       ,[Years_V]  
       ,[Priv_Notes]  
       ,[Pub_Notes]  
       ,[Last_Updated]  
       ,[Investigator]  
       ,[Emplid]  
       ,[PendingUpdated]  
       ,[Web_Status]  
       ,[web_updated]  
       ,[time_in]  
       ,[InUse]  
       ,[CreatedDate]  
       ,[Last_Worked]  
       ,[IsCAMReview]  
       ,[IsOnReport]  
       ,[IsHidden]  
       ,[IsHistoryRecord]  
       ,[ClientAdjudicationStatus]  
       ,Email  
       ,JobTitle)   
     select  
     [APNO]  
       ,IsNull([SectStat],'0')  
       ,IsNull([Worksheet],1)  
       ,[Name]  
       ,[Phone]  
       ,[Rel_V]  
       ,[Years_V]  
       ,[Priv_Notes]  
       ,[Pub_Notes]  
       ,[Last_Updated]  
       ,[Investigator]  
       ,[Emplid]  
       ,[PendingUpdated]  
       ,IsNull([Web_Status],0)  
       ,[web_updated]  
       ,Current_Timestamp  
       ,null --[InUse]  
       ,Current_Timestamp  
       ,[Last_Worked]  
       ,IsNull([IsCAMReview],0)  
       ,IsNull([IsOnReport],0)  
       ,IsNull([IsHidden],0)  
       ,IsNull([IsHistoryRecord],0)  
       ,[ClientAdjudicationStatus]  
       ,Email  
       ,JobTitle  
      FROM [dbo].[PrecheckFramework_PersRefStaging]  
      where IsNull(SectionID,'') = ''  
      and apno = @apno  
	  and FolderId = @folderId 
	  and CreatedDate >= @DateEntered 

	   --Update [dbo].PersRef
	   --Set Inuse = NULL, InUse_TimeStamp=NULL
	   --WHERE Inuse = @UserName
       
        DELETE FROM   
         [dbo].[PrecheckFramework_PersRefStaging]   
        WHERE   
         FolderId = @FolderId and apno = @apno 
		 --and IsNull(SectionId,'') <> ''  

      END  
	    IF (charindex('LockAppl',@sectionList) = 0) 
		Begin
			Update [dbo].PersRef
			Set Inuse = NULL, InUse_TimeStamp=NULL		
			WHERE apno = @apno and Inuse = @UserName
		End
    END  
      
    IF (charindex('Licensing',@sectionList) > 0)  
    BEGIN  
     IF (SELECT count(folderId) FROM [dbo].[PrecheckFramework_ProfLicStaging] WHERE @folderId = folderId and apno = @apno and CreatedDate >= @DateEntered ) > 0  
     BEGIN  
     Update pl  
     set  
         Lic_Type = stg.Lic_Type     
        ,Lic_Type_V = stg.Lic_Type_V  
        ,Lic_No = stg.Lic_No    
        ,Lic_No_V = stg.Lic_No_V  
        ,State  = stg.State        
        ,State_V = stg.State_V  
        ,Contact_Name = stg.Contact_Name   
        ,Contact_Title = stg.Contact_Title     
        ,Contact_Date = stg.Contact_Date  
        ,Investigator = stg.Investigator  
        ,Expire = stg.Expire  
      ,Expire_V = stg.Expire_V  
        ,[Year] = stg.[Year]      
        ,Year_V = stg.Year_V  
        ,[Status] = stg.[Status]  
        ,Status_A = stg.Status_A  
        ,Organization = stg.Organization  
        ,Priv_Notes = cast(stg.Priv_Notes as varchar(max))  
        ,Pub_Notes = cast(stg.Pub_Notes as varchar(max))  
        ,IsOnReport = IsNull(stg.IsOnReport,0)    
        ,IsHidden = IsNull(stg.IsHidden,0)  
		,IsCAMReview = IsNull(stg.IsCAMReview,0)  
        ,Web_Status = IsNull(stg.Web_Status,0)     
        ,SectStat = IsNull(stg.SectStat,'0')  
         ,InUse = null --@UserName 
		 , InUse_TimeStamp=NULL 
        ,DisclosedPastAction = IsNull(stg.DisclosedPastAction,0) 
           
        FROM  
       [dbo].[ProfLic] pl         
       JOIN   
       [dbo].[PrecheckFramework_ProfLicStaging] stg   
       ON  
       stg.Apno = pl.Apno and stg.SectionId = pl.ProfLicId   
      where   
       IsNull(stg.SectionID,'') <> '' and stg.FolderId = @folderId  and stg.Apno = @apno 
	   and stg.CreatedDate >= @DateEntered  
             
       Insert into dbo.ProfLic  
       (         
         [Apno]  
         ,[SectStat]  
         ,[Worksheet]  
         ,[Lic_Type]  
         ,[Lic_No]  
         ,[Year]  
         ,[Expire]  
         ,[State]  
         ,[Status]  
         ,[Priv_Notes]  
         ,[Pub_Notes]  
         ,[Web_status]  
         ,[includealias]  
         ,[includealias2]  
         ,[includealias3]  
         ,[includealias4]  
         ,[pendingupdated]  
         ,[web_updated]  
         ,[time_in]  
         ,[Organization]  
         ,[Contact_Name]  
         ,[Contact_Title]  
         ,[Contact_Date]  
         ,[Investigator]  
         ,[Last_Updated]  
         ,[InUse]  
         ,[CreatedDate]  
         ,[Status_A]  
         ,[ToPending]  
         ,[FromPending]  
         ,[Last_Worked]  
         ,[IsCAMReview]  
         ,[IsOnReport]  
         ,[IsHidden]  
         ,[IsHistoryRecord]  
         ,[ClientAdjudicationStatus]  
         ,[ClientRefID]  
         ,[Lic_Type_V]  
         ,[Lic_No_V]  
         ,[State_V]  
         ,[Expire_V]  
         ,[Year_V]  
         ,[GenerateCertificate]  
         ,[CertificateAvailabilityStatus]  
         ,DisclosedPastAction          
       )  
       SELECT   
        [Apno]  
        ,IsNull(SectStat,'0')  
        ,IsNull(WorkSheet,1)  
        ,[Lic_Type]  
        ,[Lic_No]  
        ,[Year]  
        ,[Expire]  
        ,[State]  
        ,[Status]  
        ,[Priv_Notes]  
        ,[Pub_Notes]  
        ,IsNull(Web_Status,0)  
        ,[includealias]  
        ,[includealias2]  
        ,[includealias3]  
        ,[includealias4]  
        ,[pendingupdated]  
        ,[web_updated]  
        ,Current_Timestamp  
        ,[Organization]  
        ,[Contact_Name]  
        ,[Contact_Title]  
        ,[Contact_Date]  
        ,[Investigator]  
        ,[Last_Updated]  
        ,null --@userName as InUse  
        ,Current_Timestamp  
        ,[Status_A]  
        ,[ToPending]  
        ,[FromPending]  
        ,[Last_Worked]  
        ,IsNull([IsCAMReview],0)  
        ,IsNull([IsOnReport],0)  
        ,IsNull([IsHidden],0)  
        ,IsNull([IsHistoryRecord],0)  
        ,[ClientAdjudicationStatus]  
        ,[ClientRefID]  
        ,[Lic_Type_V]  
        ,[Lic_No_V]  
        ,[State_V]  
        ,[Expire_V]  
        ,[Year_V]  
        ,IsNull([GenerateCertificate],0)  
        ,IsNull([CertificateAvailabilityStatus],2)  
        ,DisclosedPastAction  
       from dbo.PrecheckFramework_ProfLicStaging plstg  
       where IsNull(SectionID,'') = ''  
        and apno = @apno
		and plstg.FolderId = @folderId 
	    and plstg.CreatedDate >= @DateEntered   

	   --Update [dbo].ProfLic
	   --Set Inuse = NULL, InUse_TimeStamp=NULL
	   --WHERE Inuse = @UserName
         
        DELETE FROM   
         [dbo].[PrecheckFramework_ProfLicStaging]   
        WHERE   
         FolderId = @FolderId and apno = @apno 
		 --and IsNull(SectionId,'') <> ''  

     END  
	  
	   IF (charindex('LockAppl',@sectionList) = 0) 
	   Begin
			Update [dbo].ProfLic
			Set Inuse = NULL, InUse_TimeStamp=NULL
			WHERE apno = @apno and Inuse = @UserName
	   End
  END  
      
    IF (charindex('PublicRecords',@sectionList) > 0)  
    BEGIN                                   
     declare @CNTY_NO int,@IsHistoryRecord bit  , @StagingId int
     IF (SELECT count(folderId) FROM dbo.PrecheckFramework_PublicRecordsStaging WHERE folderId = @folderId  and apno = @apno and CreatedDate >= @DateEntered  ) > 0  
     BEGIN  
        
      --Select distinct @CLNO = clno From dbo.Appl a join dbo.PrecheckFramework_PublicRecordsStaging c on a.Apno = c.Apno where c.Apno = @apno       
        
      create table #tmpCrim ( id int identity,CNTY_NO int,IsHistoryRecord BIT,StagingId int)  
        
      insert into #tmpCrim		
      Select  CNTY_NO, IsNull(IsHistoryRecord,0),PublicRecordsStagingId
       From dbo.PrecheckFramework_PublicRecordsStaging   
      Where FolderId = @FolderId and apno = @apno and IsNull(SectionId,'') = ''
	  AND   CreatedDate >= @DateEntered    
        
      --Select @CNTY_NO = CNTY_NO,@IsHistoryRecord = IsHistoryRecord   
      --From #tmpCrim  
         
        
      --perform an insert/update  
       select @id = 0
	     
       while @id < (select max(id) from #tmpCrim)  
       begin  
                         select @id = @id + 1  

                         select @CNTY_NO = CNTY_NO,@StagingId = StagingId 
                                   from   #tmpCrim  
                                   where  #tmpCrim.id = @id                                     
                                 
                                                                    
                                   exec  createcrim  @apno, @CNTY_NO, @crimid OUTPUT 
                                   if (select count(1) from dbo.Crim where Crimid = @crimid) = 0
										set @crimid = (select top 1 crimid from dbo.crim where apno = @apno and cnty_no = @cnty_no order by crimenteredtime desc)                                    
                                     
                                   update dbo.PrecheckFramework_PublicRecordsStaging Set SectionID = @crimid  
                                   Where PublicRecordsStagingId = @StagingId
								 
       End  
        
      UPDATE   
       pubrec  
      SET   
       County = prstg.County  
       ,Clear = prstg.Clear  
       ,Ordered = prstg.Ordered  
       ,Name = prstg.Name  
       ,DOB = prstg.DOB  
       ,SSN = prstg.SSN  
       ,CaseNo = prstg.CaseNo  
       ,Date_Filed = prstg.Date_Filed  
       ,Degree = Case When prstg.Clear = 'R' Then NULL Else prstg.Degree  END
       ,Offense = prstg.Offense  
       ,Disposition = prstg.Disposition  
       ,Sentence = prstg.Sentence  
       ,Fine = prstg.Fine  
       ,Disp_Date = prstg.Disp_Date  
       ,Priv_Notes = cast(prstg.Priv_Notes as varchar(max))  
       ,Pub_Notes = cast(prstg.Pub_Notes as varchar(max))  
       ,IsHistoryRecord = prstg.IsHistoryRecord  
       ,IsHidden = IsNull(prstg.IsHidden,0)  
       ,InUse = null --prstg.InUse  
       ,Report = cast(prstg.Report as varchar(max))  
       ,[CRIM_SpecialInstr] = cast(prstg.[CRIM_SpecialInstr] as varchar(max))  
       ,[Last_Updated] =  Current_Timestamp  
	   ,AdmittedRecord = IsNull(prstg.AdmittedRecord,0)
	    FROM  
       [dbo].[Crim] pubrec         
       JOIN   
       [dbo].[PrecheckFramework_PublicRecordsStaging] prstg   
       ON  
       prstg.Apno = pubrec.Apno and prstg.SectionId = pubrec.CrimId   
      where IsNull(prstg.SectionID,'') <> ''  
	  and prstg.FolderId = @folderId 
	  and prstg.CreatedDate >= @DateEntered 
        
		DELETE FROM   
			[dbo].[PrecheckFramework_PublicRecordsStaging]  
		WHERE  FolderId = @FolderId and apno = @apno 
		and    CreatedDate >= @DateEntered



                 
     END 
	 
	 --Temp solution to update sex offender
	 --added USFederal, FedBankruptcy, and USCivil to this logic - schapyala 02/05/14
	 Update [dbo].[Crim]
	 Set Clear = 'R'
	 Where cnty_no in (2480,2738,229,2737) AND Apno = @apno and Isnull(Clear,'')=''	  
    END  
            
	IF (charindex('Education',@sectionList) > 0)  
    BEGIN  
      IF (SELECT count(folderId) FROM [dbo].[PrecheckFramework_EducatStaging] WHERE @folderId = folderId and apno = @apno and CreatedDate >= @DateEntered) > 0  
      BEGIN  
        
        UPDATE edu  
        SET  
        [School] = edstg.[School]            
       ,[State] = edstg.[State]  
       ,[Phone] = edstg.[Phone]  
       ,[Degree_A] = edstg.[Degree_A]  
       ,[Studies_A] = edstg.[Studies_A]  
       ,[From_A] = edstg.[From_A]  
       ,[To_A] = edstg.[To_A]  
       ,[Name] = edstg.[Name]  
       ,[Degree_V] = edstg.[Degree_V]  
       ,[Studies_V] = edstg.[Studies_V]  
       ,[From_V] = edstg.[From_V]  
       ,[To_V] = edstg.[To_V]  
       ,[Contact_Name] = edstg.[Contact_Name]  
       ,[Contact_Title] = edstg.[Contact_Title]  
       ,[Contact_Date] = edstg.[Contact_Date]  
       ,[Investigator] = edstg.[Investigator]  
       ,Priv_Notes = cast(edstg.Priv_Notes as varchar(max))-- + CHAR(13) + IsNull(cast(edu.Priv_Notes as varchar(max)),'')  
       ,Pub_Notes = cast(edstg.Pub_Notes as varchar(max))-- + CHAR(13) + IsNull(cast(edu.Pub_Notes as varchar(max)),'')  
       ,[web_status] = Isnull(edstg.[web_status],0)  
       ,[SectStat] = IsNull(edstg.[SectStat],'0')  
       ,[Worksheet] = IsNull(edstg.[Worksheet],1)  
       ,[Includealias] = IsNull(edstg.[Includealias],'y')  
       ,[Includealias2] = IsNull(edstg.[Includealias2],'y')  
       ,[Includealias3] = IsNull(edstg.[Includealias3],'y')  
       ,[Includealias4] = IsNull(edstg.[Includealias4],'y')  
      -- ,[pendingupdated] = <pendingupdated, datetime,>  
       ,[web_updated] = IsNull(edstg.[web_updated],Current_Timestamp)  
       --,[Time_In] = IsNull(edstg.[Time_In],Current_Timestamp)           
       ,[InUse] = null --@userName  
	   , InUse_TimeStamp=NULL
       --,[Last_Updated] = <Last_Updated, datetime,>  
       ,[city] = edstg.[city]  
       ,[zipcode] = edstg.[zipcode]  
       ,[CampusName] = edstg.[CampusName]       
      --,[CreatedDate] = IsNull(edstg.[CreatedDate],Current_Timestamp)  
       --,[ToPending] = <ToPending, datetime,>  
       --,[FromPending] = <FromPending, datetime,>  
       --,[Completed] = <Completed, bit,>  
       --,[Last_Worked] = <Last_Worked, datetime,>  
       --,[SchoolID] = <SchoolID, int,>  
        ,[IsCamReview] = IsNull(edstg.[IsCamReview],0)  
       ,[IsOnReport] = IsNull(edstg.[IsOnReport] ,0) 
       ,[IsHidden] = IsNull(edstg.[IsHidden],0)  
       ,[IsHistoryRecord] = IsNull(edstg.[IsHistoryRecord],0)  
       ,[HasGraduated] = IsNull(edstg.[HasGraduated],0)  
       ,[HighestCompleted] = edstg.[HighestCompleted]  
       --,[EducatVerifyID] = <EducatVerifyID, int,>  
       --,[GetNextDate] = <GetNextDate, datetime,>  
       --,[SubStatusID] = <SubStatusID, int,>  
       ,[ClientAdjudicationStatus] = IsNull(edstg.[ClientAdjudicationStatus],edu.[ClientAdjudicationStatus])  
       --,[ClientRefID] = <ClientRefID, varchar(25),>  
       ,[IsIntl] = Isnull(edstg.[IsIntl],0)  
       --,[DateOrdered] = <DateOrdered, datetime,>  
       --,[OrderId] = <OrderId, varchar(20),>  
       FROM  
       [dbo].[Educat] edu         
       JOIN   
       [dbo].[PrecheckFramework_EducatStaging] edstg   
       ON  
       edstg.Apno = edu.Apno and edstg.SectionId = edu.EducatId   
      where IsNull(edstg.SectionID,'') <> ''  
	  and edstg.FolderId = @folderId 
	  and edstg.CreatedDate >= @DateEntered 
        
      INSERT INTO  dbo.Educat  
      (                
        [APNO]  
        ,[School]  
        ,[SectStat]  
        ,[Worksheet]  
        ,[State]  
        ,[Phone]  
        ,[Degree_A]  
        ,[Studies_A]  
        ,[From_A]  
        ,[To_A]  
        ,[Name]  
        ,[Degree_V]  
        ,[Studies_V]  
        ,[From_V]  
        ,[To_V]  
        ,[Contact_Name]  
        ,[Contact_Title]  
        ,[Contact_Date]  
        ,[Investigator]  
        ,[Priv_Notes]  
        ,[Pub_Notes]  
        ,[web_status]  
        ,[includealias]  
        ,[includealias2]  
        ,[includealias3]  
        ,[includealias4]  
        ,[pendingupdated]  
        ,[web_updated]  
        ,[Time_In]  
        ,[Last_Updated]  
        ,[city]  
        ,[zipcode]  
        ,[CampusName]  
        ,[InUse]  
        ,[CreatedDate]  
        ,[ToPending]  
        ,[FromPending]  
        ,[Completed]  
        ,[Last_Worked]  
        ,[SchoolID]  
        ,[IsCAMReview]  
        ,[IsOnReport]  
        ,[IsHidden]  
        ,[IsHistoryRecord]  
        ,[HasGraduated]  
        ,[HighestCompleted]  
        ,[EducatVerifyID]  
        ,[GetNextDate]  
        ,[SubStatusID]  
        ,[ClientAdjudicationStatus]  
        ,[ClientRefID]  
        ,[IsIntl]  
        ,[DateOrdered]  
        ,[OrderId]  
      )        
         select                    
        [APNO]  
        ,[School]  
        ,IsNull([SectStat],0)  
        ,IsNull([Worksheet],1)  
        ,[State]  
        ,[Phone]  
        ,[Degree_A]  
        ,[Studies_A]  
        ,[From_A]  
        ,[To_A]  
        ,[Name]  
        ,[Degree_V]  
        ,[Studies_V]  
        ,[From_V]  
        ,[To_V]  
        ,[Contact_Name]  
        ,[Contact_Title]  
        ,[Contact_Date]  
        ,[Investigator]  
        ,[Priv_Notes]  
        ,[Pub_Notes]  
        ,IsNull([web_status],0)  
        ,IsNull([includealias],'y')  
        ,IsNull([includealias2],'y')  
        ,IsNull([includealias3],'y')  
        ,IsNull([includealias4],'y')  
        ,[pendingupdated]  
        ,[web_updated]  
        ,IsNull([Time_In],Current_Timestamp)  
        ,[Last_Updated]  
        ,[city]  
        ,[zipcode]  
        ,[CampusName]  
        ,null --@userName as InUse  
        ,IsNull([CreatedDate],Current_Timestamp)  
        ,[ToPending]  
        ,[FromPending]  
        ,[Completed]  
        ,[Last_Worked]  
        ,[SchoolID]  
        ,IsNull([IsCAMReview],0)  
        ,IsNull([IsOnReport],0)  
        ,IsNull([IsHidden],0)  
        ,IsNull([IsHistoryRecord],0)  
        ,IsNull([HasGraduated],0)  
        ,[HighestCompleted]  
        ,[EducatVerifyID]  
        ,[GetNextDate]  
        ,[SubStatusID]  
        ,[ClientAdjudicationStatus]  
        ,[ClientRefID]  
        ,IsNull([IsIntl],0)  
        ,[DateOrdered]  
        ,[OrderId]          
       from dbo.PrecheckFramework_EducatStaging e  
       where IsNull(SectionID,'') = ''  
        and apno = @apno 
		and e.FolderId = @folderId 
	    and e.CreatedDate >= @DateEntered 	
		
	   --Update [dbo].Educat
	   --Set Inuse = NULL, InUse_TimeStamp=NULL
	   --WHERE Inuse = @UserName			 
          
        DELETE FROM   
         [dbo].[PrecheckFramework_EducatStaging]   
        WHERE   
         FolderId = @FolderId and apno = @apno 
		 --and IsNull(SectionId,'') <> ''  
     END   
       
	    IF (charindex('LockAppl',@sectionList) = 0) 
		Begin
		   Update [dbo].Educat
		   Set Inuse = NULL, InUse_TimeStamp=NULL
		   WHERE apno = @apno and Inuse = @UserName		
	   End
   END  
        
   -- MVR  
   IF (charindex('MVR',@sectionList) > 0)  
   BEGIN  
     --IF (SELECT count(folderId) FROM dbo.PrecheckFramework_MVRPIDSCStaging mvrstg WHERE @folderId = folderId and apno = @apno and Type='MVR') > 0  
     --BEGIN  
  
     Update   
      mvr  
     set      
      [SectStat] = mvrstg.SectStat  
      --,Report = IsNull(mvrstg.Report,IsNull(cast(mvr.Report as varchar(max)),''))  
      ,Report = IsNull(mvrstg.Report,mvr.Report)  
      --,[Web_status] = mvrstg.Web_Status     
      ,[InUse] = null --@UserName 
	   ,IsHidden = mvrstg.IsHidden         
     FROM  
      [dbo].[DL] mvr  
     JOIN   
      dbo.PrecheckFramework_MVRPIDSCStaging mvrstg   
     ON  
      mvrstg.Apno = mvr.Apno   
     where   
      mvrstg.Apno = @apno 
	  and mvrstg.[Type] = 'MVR' 
	  and mvrstg.FolderId = @FolderId 
	  and mvrstg.CreatedDate >= @DateEntered 	       
    
      DELETE FROM   
       dbo.PrecheckFramework_MVRPIDSCStaging   
      WHERE   
       FolderId = @FolderId and IsNull(Apno,'') <> '' and Type = 'MVR'                        

   END         
        
      
 IF (charindex('SanctionCheck',@sectionList) > 0)  
   BEGIN  
     --IF (SELECT count(folderId) FROM dbo.PrecheckFramework_MVRPIDSCStaging mvrstg WHERE folderId = @folderId  and apno = @apno and Type='SC') > 0  
     --BEGIN  
  
     Update   
      sc  
     set      
      [SectStat] = mvrstg.SectStat  
      --,Report = IsNull(IsNull(mvrstg.Report,''),IsNull(cast(sc.Report as varchar(max)),''))            
      ,Report = IsNull(mvrstg.Report,sc.Report)            
      ,[InUse] = null --@UserName 
	   ,IsHidden = mvrstg.IsHidden         
     FROM  
      [dbo].[MedInteg] sc  
     INNER JOIN   
      dbo.PrecheckFramework_MVRPIDSCStaging mvrstg   
     ON  
      mvrstg.Apno = sc.Apno   
     --and   
     -- mvrstg.FolderId = @FolderId       
     where mvrstg.Apno = @apno   
      and mvrstg.[Type] = 'SC'   
      and mvrstg.FolderId = @FolderId 
	  and mvrstg.CreatedDate >= @DateEntered       
   
     DELETE FROM   
      dbo.PrecheckFramework_MVRPIDSCStaging   
     WHERE   
      FolderId = @FolderId and IsNull(Apno,'') <> '' and Type = 'SC'  

  END    
      
  IF (charindex('Credit',@sectionList) > 0)  
   BEGIN  
     IF (SELECT count(folderId) FROM dbo.PrecheckFramework_MVRPIDSCStaging mvrstg WHERE folderId = @folderId and apno = @apno and Type='CR' and CreatedDate >= @DateEntered) > 0  
     BEGIN  
     Update   
      cr  
     set      
      [SectStat] = mvrstg.SectStat  
      --,Report = IsNull(mvrstg.Report,IsNull(cast(cr.Report as varchar(max)),''))  
      ,Report = IsNull(mvrstg.Report,cr.Report)                      
      ,[InUse] = null --@UserName 
	   ,IsHidden = mvrstg.IsHidden         
     FROM  
      [dbo].[Credit] cr  
     JOIN   
      dbo.PrecheckFramework_MVRPIDSCStaging mvrstg   
     ON  
      mvrstg.Apno = cr.Apno   
     --and   
     -- mvrstg.FolderId = @FolderId       
     where mvrstg.Apno = @apno   
      and mvrstg.[Type] = 'CR'   
      and mvrstg.FolderId = @FolderId  
      and CR.RepType = 'C' 
	  and mvrstg.CreatedDate >= @DateEntered
	   
                
 
      DELETE FROM   
       dbo.PrecheckFramework_MVRPIDSCStaging   
      WHERE   
       FolderId = @FolderId and IsNull(Apno,'') <> '' and Type = 'CR'  
      
     END  
   END  

     
     
   IF (charindex('PositiveID',@sectionList) > 0)  
   BEGIN  
     IF (SELECT count(folderId) FROM dbo.PrecheckFramework_MVRPIDSCStaging mvrstg WHERE  folderId = @folderId  and apno = @apno and Type='PID' and CreatedDate >= @DateEntered ) > 0  
     BEGIN  
     Update   
      cr  
     set      
      [SectStat] = mvrstg.SectStat  
      --,Report = IsNull(mvrstg.Report,IsNull(cast(cr.Report as varchar(max)),''))  
      ,Report = IsNull(mvrstg.Report,cr.Report)  
      ,[InUse] = null --@UserName
	  ,IsHidden = mvrstg.IsHidden     
     FROM  
      [dbo].[Credit] cr  
     JOIN   
      dbo.PrecheckFramework_MVRPIDSCStaging mvrstg   
     ON  
      mvrstg.Apno = cr.Apno   
     --and   
     -- mvrstg.FolderId = @FolderId       
     where mvrstg.Apno = @apno  
      and  mvrstg.[Type] = 'PID'   
      and  mvrstg.FolderId = @FolderId    
      and  CR.RepType = 'S'    
	  and  mvrstg.CreatedDate >= @DateEntered 	   
   
      DELETE FROM   
       dbo.PrecheckFramework_MVRPIDSCStaging   
      WHERE   
       FolderId = @FolderId and IsNull(Apno,'') <> '' and Type = 'PID'  
                  
     END  

END  
  
  
       --UNLOCK app (Master Lock)    
   if (@UnLockAppl = 1)  
	  update dbo.Appl  
	  set InUse = NULL  
	  where apno = @apno     
  
    
    
END  



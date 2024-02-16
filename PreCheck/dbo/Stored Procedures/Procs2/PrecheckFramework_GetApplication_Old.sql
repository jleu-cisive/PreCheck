﻿
-- =============================================      
-- Author:  Doug DeGenaro      
-- Create date: 09/07/2012      
-- Description: Get Application data by application number      
-- =============================================      
    
    
  --select * from fn_Split(@sectionList,'|')  
  --  select ssn from appl where apno = 1884529  
 --   insert into empl(employer,apno)values('NewEmpl1',1884529)  
 --   insert into empl(employer,apno)values('AnotherEmpl',1869955)  
 -- insert into educat(school,apno)values('NewSchool',1884529)  
 --  insert into ProfLic(Lic_Type,apno)values('RN',1884529)  
 --insert into PersRef(Name,Rel_V,apno) values ('Test','Supervisor',1884529)  
 --insert into DL(apno,sectstat,report,web_status) values (1884529,'9','this is a test',0);  
   
   
 --  insert into ProfLic(Lic_Type,apno)values('CNA2',1884529)  
-- =============================================      
--select * from appl where apno = 1884529  
--select * from dl where apno = 1884529  
-- Author:  Doug DeGenaro      
-- Updated date: 09/25/2012      
-- Description: Added IsOnReport,IsHidden,SectionIds, Emp_type,Rel_Cond,Rehire,Ver_By      
-- =============================================      
--[dbo].[PrecheckFramework_GetApplication] 2188058,1,'Education','ddegenaro',0  
/*   
update dbo.Empl set InUse = null where apno = 1884529;  
update dbo.Educat set InUse = null where apno = 1884529;      
update dbo.PersRef set InUse = null where apno =  1884529;  
update dbo.ProfLic set InUse = null where apno = 1884529;  
update dbo.Appl set InUse = null where apno = 1884529   
update dbo.Educat set InUse = null where educatid = 1414951  
*/  
CREATE PROCEDURE [dbo].[PrecheckFramework_GetApplication_Old](@apno int = null,@includeHistory bit,@sectionList varchar(100) = null,@username varchar(20) = null,@lockAppl bit = 0)      
AS      
      
SET NOCOUNT ON;      
   
declare @flag int  
declare @count int  
declare @sectionOption varchar(50)  
declare @ssn varchar(30)  
  
if (IsNull(@username,'') = '')  
 set @username = ''  

 if (@userName is not null)
	set @userName = Left(@userName,8)
  
set @ssn = (select top 1 ssn from dbo.appl where apno = @apno order by apdate desc)  
if (charindex('AllSections',@sectionList) > 0)  
 set @sectionList = 'ApplicationData|Employment|Education|Licensing|PersRef|Credit|MVR|SanctionCheck|PublicRecords'  
--if (@ssn = null)  
-- exec dbo.PrecheckFramework_GetByApno @apno;  
--else  
set @count = (select count(*) from fn_Split(@sectionList,'|'));  
set @flag = 0  
SET ARITHABORT ON  
-- Change to pull custom client data for US_ONCOLOGY  
    IF(SELECT COUNT(Apno) from dbo.ApplClientData where Apno = @apno) > 0  
  SELECT   
   'ApplClientData' as SectionName,  
   APNO,   
   NewTable.RequestXML.query('data(ClientData1)') AS ClientData1,  
   NewTable.RequestXML.query('data(ClientData2)') AS ClientData2,   
   NewTable.RequestXML.query('data(ClientData3)') AS  ClientData3  
  FROM applclientdata CROSS APPLY XMLD.nodes('//CustomClientData') AS NewTable(RequestXML)  
  WHERE  
   apno = @apno  
SET ARITHABORT OFF  

 IF (SELECT COUNT(Apno) from dbo.ApplAlias where Apno = @apno) > 0
     BEGIN
		SELECT 'ApplAlias' as SectionName,ApplAliasID as SectionId,First,Middle,Last,Generation from dbo.ApplAlias 
		where Apno = @apno --and IsNull(Deleted,0) = 0     
     END
--exec PrecheckFramework_GetByApno @apno  
while (@flag <= @count)  
BEGIN   
 set @sectionOption = (select value from fn_Split(@sectionList,'|') where idx = @flag);      
      
      
    
     
      
      
    ---------- Application ----------------  
    if (@sectionOption = 'ApplicationData')  
    Begin   
 IF (SELECT COUNT(Apno) FROM dbo.Appl WHERE Apno = @apno) > 0  
 BEGIN          
 Select * into #tmpAppl from  
 (  
  SELECT         
     'Application' as SectionName        
     ,Apno  
     ,CLNO        
     ,First        
     ,Middle        
     ,Last
     ,Generation
     ,DOB        
     ,CreatedDate        
     ,Last_Updated        
     ,StartDate        
     ,SSN        
     ,Addr_Num        
     ,Addr_Street        
     ,Addr_Apt        
     ,Addr_Dir        
     ,IsNull(Attn,'') as Attn        
     ,City
     ,State        
     ,Zip        
     ,Rush        
     ,Recruiter_Email        
     ,IsNull(Email,'') as Applicant_Email        
     ,Phone      
     ,IsNull(FreeReport,0) as FreeReport          
     ,Alias1_First        
     ,Alias1_Middle        
     ,Alias1_Last        
     ,Alias1_Generation           
     ,Alias2_First        
     ,Alias2_Middle        
     ,Alias2_Last        
     ,Alias2_Generation        
     ,Alias3_First        
     ,Alias3_Middle        
     ,Alias3_Last        
     ,Alias3_Generation        
     ,Alias4_First        
     ,Alias4_Middle        
     ,Alias4_Last        
     ,Alias4_Generation  
     ,IsNull(Rel_Attached,0) as  Rel_Attached 
     ,IsNull(Priv_Notes,'') as Priv_Notes        
     ,EnteredBy        
     ,DL_Number        
     ,DL_State        
     ,Pos_Sought          
     ,Special_Instructions        
     ,IsNull(PrecheckChallenge,0) as PrecheckChallenge     
     ,IsNull(Investigator,'') as Investigator      
     ,IsNull(UserID,'') as CAM        
     ,ApDate        
     ,ApStatus   
     ,IsNull(PackageId,'') as PackageId  
     ,IsNull(DeptCode,'') as DeptCode       
     ,EnteredVia             
     ,OrigCompDate        
     ,CompDate        
     ,IsNull(I94,'') as I94        
     ,ReOpenDate        
     ,Pub_Notes  
     ,IsNull(NeedsReview,'') as NeedsReview           
     ,case when IsNull(InUse,'') = @UserName then null else  IsNull(InUse,'') end as InUse
	 ,GetNextDate                
    FROM         
     dbo.Appl (nolock)         
    WHERE         
     apno = @apno  
   ) tbl  
     
   if (@lockAppl = 1)  
   Begin  
   --commented the temp update to return a null when the current user is claiming the lock
  --update #tmpAppl set InUse = @UserName   
  --where apno = @apno and IsNull(InUse,'') = ''    
       
  --Update empls in use from temp table  
  update dbo.Appl  
  set InUse = @username  
  where apno = @apno and IsNull(InUse,'') = ''        
   End    
     
   -- Return results  
  select * from #tmpAppl   
    
  --Drop table, we are done  
  drop table #tmpAppl              
        
         
    END      
  
           
 declare @credit int          
 declare @mvr int          
 declare @sanctioncheck int          
  
 set @credit = 0  
 set @mvr = 0  
 set @sanctioncheck = 0          
 select @credit = isnull((select count(1) from dbo.Credit where APNO = @apno),0)          
 select @mvr = isnull((select count(1) from dbo.Crim where APNO = @apno),0)          
 select @sanctioncheck = IsNull((select count(1) from MEDINTEG where @apno = @apno),0)          
          
 if @mvr > 0 set @mvr = 1          
 if @credit > 0 set @credit= 1          
 if @sanctioncheck > 0 set @sanctioncheck= 1          
          
 select 'Orders' as SectionName,@credit as order_credit, @mvr as order_mvr,@sanctioncheck as order_sanctioncheck,null as Order_FedBankruptcy,null as Order_NewspaperArticle,null as Order_PositiveID,null as Order_USCivil,null as Order_USFederal          
  --exec PrecheckFramework_GetByApno @apno  
 End  
      
    if (@sectionOption = 'Counts')  
    Begin  
  select 'Counts' as SectionName,Section,SectionCount from  
  (  
   select 'Employment' as Section,count(EmplId) as SectionCount from dbo.Empl where apno = @apno  
   Union All  
   select 'Education' as Section,count(EducatId) as SectionCount from dbo.Educat where apno = @apno  
   Union All  
   select 'Licensing' as Section,count(ProfLicId) as SectionCount from dbo.ProfLic where apno = @apno  
   Union All  
   select 'PersonalReference' as Section,count(PersRefId) as SectionCount from dbo.PersRef where apno = @apno  
   Union All  
   select 'MVR' as Section,count(apno) as SectionCount from dbo.DL where apno = @apno
   Union All
   select 'Credit' as Section,count(apno) as SectionCount from dbo.Credit where apno = @apno and RepType = 'C'
   Union All
   select 'PID' as Section,count(apno) as SectionCount from dbo.Credit where apno = @apno and RepType = 'S'
   Union All
   select 'SanctionCheck' as Section,count(apno) as SectionCount from dbo.MedInteg where apno = @apno
   --select 'PublicRecords' as Section,count(CrimId) as SectionCount from dbo.Crim where apno = @apno     
  ) secTbl  
  group by Section,SectionCount  
 End  
                  
    ---------- EMPLOYMENT ----------------  
    IF (@sectionOption = 'Employment')  
 BEGIN  
  IF (SELECT COUNT(Apno) FROM dbo.Empl WHERE Apno = @apno) > 0         
  BEGIN      
   Select * into #tmpEmployment from  
   (  
   SELECT       
    'Employment' as SectionName      
    ,'Current' as RecordType          
    ,RTRIM(LTRIM(Employer)) as Employer      
    ,RTRIM(LTRIM(Location)) as Location      
    ,RTRIM(LTRIM(City)) as City      
    ,State      
    ,zipcode      
    ,IsNull(Position_A,'') as Position_A   
    ,IsNull(Position_V,'') as Position_V       
    ,IsNull(Ver_Salary,0) as Ver_Salary      
    ,IsNull(SpecialQ,0) as SpecialQ   
    ,IsNull(AdverseRFL,0) as AdverseRFL        
    ,IsNull(From_A,'') as From_A      
    ,IsNull(To_A,'') as To_A      
    ,IsNull(From_V,'') as From_V      
    ,IsNull(To_V,'') as To_V      
    ,Dept      
    ,IsNull(DNC,0) as DNC      
    ,IsNull(RFL,'') as RFL  
    ,IsNull(Phone,'') as EmployerPhone         
    ,RTRIM(LTRIM(Supervisor)) as Supervisor      
    ,RTRIM(LTRIM(SupPhone)) as SupPhone      
    ,IsNull(cast(Priv_Notes as varchar(max)),'') as Priv_Notes  
    ,IsNull(cast(Pub_Notes as varchar(max)),'') as Pub_Notes  
    ,EmplId as SectionId      
    ,IsNull(IsOnReport,0) as IsOnReport      
    ,IsNull(IsHidden,0) as IsHidden      
    ,IsNull(Title,'') as Title      
    ,IsNull(Emp_Type,'') as Emp_Type      
    ,IsNull(Rel_Cond,'') as Rel_Cond         
    ,IsNull(Rehire,'') as Rehire         
    ,IsNull(Web_Status,0) as Web_Status  
    ,IsNull(SectStat,'0') as SectStat    
    ,IsNull(Ver_By,'') as Ver_By      
    ,IsNull(IsOkToContact,0) as ContactPresentEmpl   
    ,@apno as Apno    
    ,Investigator as Investigator      
    ,null as ApDate       
    --,IsNull(InUse,'') as InUse 
    --------------------------------------------
    ,case when @lockAppl = 1
    then
    case when RTRIM(LTRIM(isnull(Inuse,''))) = ''
    then null
    else
    case when RTRIM(LTRIM(Inuse)) = @username 
    then null
    else
     InUse end
     end
    else
    InUse 
       end as InUse
   ------------------------------------------------  
    ,Email
    ,IsNull(IsIntl,0) as IsIntl        
   FROM       
    dbo.Empl      
   WHERE       
    Apno = @apno      
   UNION ALL      
   SELECT       
    'Employment' as SectionName      
    ,'Previous' as RecordType         
    ,RTRIM(LTRIM(Employer)) as Employer      
    ,RTRIM(LTRIM(Location)) as Location      
    ,RTRIM(LTRIM(e.City)) as City      
    ,e.State      
    ,zipcode      
    ,IsNull(Position_A,'') as Position_A    
    ,IsNull(Position_V,'') as Position_V     
    ,IsNull(Ver_Salary,0) as Ver_Salary      
    ,IsNull(SpecialQ,0) as SpecialQ   
    ,IsNull(AdverseRFL,0) as AdverseRFL        
    ,IsNull(From_A,'') as From_A      
    ,IsNull(To_A,'') as To_A      
    ,IsNull(From_V,'') as From_V      
    ,IsNull(To_V,'') as To_V      
    ,Dept      
    ,IsNull(DNC,0) as DNC    
    ,IsNull(e.RFL,'') as RFL             
    ,IsNull(e.Phone,'') as EmployerPhone     
    ,RTRIM(LTRIM(Supervisor)) as Supervisor      
    ,RTRIM(LTRIM(SupPhone)) as SupPhone      
    ,IsNull(cast(e.Priv_Notes as varchar(max)),'') as Priv_Notes   
    ,IsNull(cast(e.Pub_Notes as varchar(max)),'') as Pub_Notes     
     ,EmplId as SectionId      
    ,IsNull(IsOnReport,0) as IsOnReport      
    ,IsNull(IsHidden,0) as IsHidden      
    ,IsNull(Title,'') as Title      
    ,IsNull(Emp_Type,'') as Emp_Type      
    ,IsNull(Rel_Cond,'') as Rel_Cond         
    ,IsNull(Rehire,'') as Rehire         
    ,IsNull(Web_Status,0) as Web_Status  
    ,IsNull(SectStat,'0') as SectStat    
    ,IsNull(Ver_By,'') as Ver_By      
    ,IsNull(IsOkToContact,0) as ContactPresentEmpl  
    ,e.apno as Apno  
    ,e.Investigator as Investigator       
    ,a.Apdate        
    ,IsNull(e.InUse,'') as InUse
    ,e.Email
	 ,IsNull(e.IsIntl,0) as IsIntl        
     FROM       
     dbo.Empl e      
     INNER JOIN Appl a on e.APNO = a.APNO       
     WHERE a.SSN = @SSN and e.Apno <> @apno and @includeHistory = 1   
     --Added by schapyala on 02/18/2013  
     and IsNull(IsOnReport,0) = 1 --only include records that were on past reports  
     and IsNull(IsHidden,0) = 0   --only include records that were not marked as unused  
     --order by a.Apdate desc  
     ) tbl           
   if (@lockAppl = 1)  
    begin
 --Update the temp table's inuse if not null  
  --update #tmpEmployment set InUse = @UserName   
  --where RecordType = 'Current' and apno = @apno and IsNull(InUse,'') = ''    
       
  --Update empls in use from temp table  
  update dbo.Empl  
  set InUse = 
    case when RTRIM(LTRIM(isnull(Inuse,''))) = ''
    then @username
    else
     InUse
    end ,
	Inuse_Timestamp = Current_Timestamp
  where apno = @apno and IsNull(InUse,'') = '' 
  end 

  --update dbo.Empl  
  --set InUse = @username,Inuse_Timestamp = Current_Timestamp  
  --where apno = @apno and IsNull(InUse,'') = ''
  --end
  --EmplId in (select SectionId from #tmpEmployment   
  -- where RecordType = 'Current' and IsNull(InUse,'') = '' and apno = @apno)  
          
  -- Return results  
  select * from #tmpEmployment   
    
  --Drop table, we are done  
  drop table #tmpEmployment         
  END  
  END  
    
    
    
    
  IF (@sectionOption = 'Education')  
  BEGIN  
  IF (SELECT COUNT(Apno) FROM dbo.Educat WHERE Apno = @apno) > 0    
  BEGIN  
  Select * into #tmpEducation from  
  (  
  SELECT       
    'Education' as SectionName    
    ,'Current' as RecordType         
    ,RTRIM(LTRIM(School)) as School      
    ,IsNull(Degree_A,'') as Degree_A      
    ,IsNull(Studies_A,'') as Studies_A  
    ,IsNull(Degree_V,'') as Degree_V      
    ,IsNull(Studies_V,'') as Studies_V  
    ,IsNull(Contact_Name,'') as ContactName  
    ,IsNull(Contact_Title,'') as ContactTitle            
    ,Contact_Date as ContactDate            
    ,IsNull(From_A,'') as From_A      
    ,IsNull(To_A,'') as To_A      
    ,IsNull(From_V,'') as From_V      
    ,IsNull(To_V,'') as To_V      
    ,CampusName         
    ,RTRIM(LTRIM(City)) as City      
    ,State      
    ,zipcode      
    ,IsNull(Name,'') as Name      
    ,IsNull(cast(Priv_Notes as varchar(max)),'') as Priv_Notes  
    ,IsNull(cast(Pub_Notes as varchar(max)),'') as Pub_Notes              
    ,EducatId as SectionId      
    ,IsNull(IsOnReport,0) as IsOnReport      
    ,IsNull(IsHidden,0) as IsHidden    
    ,IsNull(Web_Status,0) as Web_Status  
    ,IsNull(SectStat,'0') as SectStat    
    ,@apno as Apno      
    ,IsNull(Investigator,'') as Investigator  
    ,null as ApDate  
    --,IsNull(InUse,'') as InUse
    --------------------------------------------
    ,case when @lockAppl = 1
    then
    case when RTRIM(LTRIM(isnull(Inuse,''))) = ''
    then null
    else
    case when RTRIM(LTRIM(Inuse)) = @username 
    then null
    else
     InUse end
     end
    else
    InUse 
       end as InUse
   ------------------------------------------------  
    ,IsNull(IsIntl,0) as IsIntl          
    FROM       
    dbo.Educat  
    WHERE       
    Apno = @apno                
   Union All      
   SELECT      
    'Education' as SectionName      
    ,'Previous' as RecordType      
    ,RTRIM(LTRIM(School)) as School      
    ,IsNull(Degree_A,'') as Degree_A      
    ,IsNull(Studies_A,'') as Studies_A   
     ,IsNull(Degree_V,'') as Degree_V      
    ,IsNull(Studies_V,'') as Studies_V  
    ,IsNull(Contact_Name,'') as ContactName  
    ,IsNull(Contact_Title,'') as ContactTitle            
    ,Contact_Date as ContactDate               
    ,IsNull(From_A,'') as From_A      
    ,IsNull(To_A,'') as To_A      
    ,IsNull(From_V,'') as From_V      
    ,IsNull(To_V,'') as To_V      
    ,CampusName         
    ,RTRIM(LTRIM(e.City)) as City      
    ,e.State as State      
    ,zipcode      
    ,IsNull(Name,'') as Name      
     ,IsNull(cast(e.Priv_Notes as varchar(max)),'') as Priv_Notes  
     ,IsNull(cast(e.Pub_Notes as varchar(max)),'') as Pub_Notes            
    ,EducatId as SectionId      
    ,IsNull(IsOnReport,0) as IsOnReport      
    ,IsNull(IsHidden,0) as IsHidden  
    ,IsNull(Web_Status,0) as Web_Status  
    ,IsNull(SectStat,'0') as SectStat    
    ,e.apno as Apno  
    ,IsNull(e.Investigator,'') as Investigator    
    ,a.Apdate         
    ,IsNull(e.InUse,'') as InUse
    ,IsNull(e.IsIntl,0) as IsIntl  
  FROM dbo.Educat e       
    inner join Appl a on e.APNO = a.APNO       
    Where a.SSN = @SSN and e.Apno <> @apno and @includeHistory =1    
  --Added by schapyala on 02/18/2013  
  and IsNull(IsOnReport,0) = 1 --only include records that were on past reports  
  and IsNull(IsHidden,0) = 0   --only include records that were not marked as unused    
    --order by a.ApDate desc  
    ) tbl  
   if (@lockAppl = 1)  
    begin    
 --Update the temp table's inuse if not null  
  --update #tmpEducation set InUse = @UserName   
  --where RecordType = 'Current' and apno = @apno and IsNull(InUse,'') = ''    
       
  --Update empls in use from temp table  
  update dbo.Educat  
  set InUse = 
    case when RTRIM(LTRIM(isnull(Inuse,''))) = ''
    then @username
    else
     InUse
    end,
	Inuse_Timestamp = Current_Timestamp
  where apno = @apno and IsNull(InUse,'') = ''
  end
  --EmplId in (select SectionId from #tmpEmployment   
  -- where RecordType = 'Current' and IsNull(InUse,'') = '' and apno = @apno)  
          
  -- Return results  
  select * from #tmpEducation   
    
  --Drop table, we are done  
  drop table #tmpEducation        
      END  
      END  
              
      IF (@sectionOption = 'Licensing')  
      BEGIN    
   IF (SELECT COUNT(Apno) FROM dbo.ProfLic WHERE Apno = @apno) > 0   
   BEGIN  
   Select * into #tmpProfLic from  
  (         
  SELECT      
    'Licensing' as SectionName      
    ,'Current' as RecordType          
    ,ProfLicId as SectionId      
    ,Lic_Type         
   ,IsNull(Lic_Type_V,'') as Lic_Type_V      
   ,Lic_No      
   ,IsNull(Lic_No_V,'') as Lic_No_V      
   ,State      
   ,IsNull(State_V,'') as State_V  
   ,IsNull(Contact_Name,'') as ContactName      
   ,IsNull(Contact_Title,'') as ContactTitle      
   ,Case when cast(Contact_Date as varchar(20)) = '1/1/1900' then null else Contact_Date end as ContactDate
   --,IsNull(Contact_Date,'') as ContactDate   
   ,IsNull(Investigator,'') as Investigator     
   ,Convert(VarChar,Expire,101) as Expire      
    ,Convert(VarChar,Expire_V,101) as Expire_V       
   ,[Year]      
   ,IsNull(Year_V,'') as Year_V      
   ,IsNull([Status],'') as [Status]  
   ,IsNull(Status_A,'') as Status_A  
   ,IsNull(Organization,'') as Organization      
   ,IsNull(cast(Priv_Notes as varchar(max)),'') as Priv_Notes  
   ,IsNull(cast(Pub_Notes as varchar(max)),'') as Pub_Notes     
   ,IsNull(IsOnReport,0) as IsOnReport      
   ,IsNull(IsHidden,0) as IsHidden  
   ,@apno as Apno      
   ,IsNull(Web_Status,0) as Web_Status     
 ,IsNull(SectStat,'0') as SectStat   
 --,IsNull(InUse,'') as InUse
 --------------------------------------------
    ,case when @lockAppl = 1
    then
    case when RTRIM(LTRIM(isnull(Inuse,''))) = ''
    then null
    else
    case when RTRIM(LTRIM(Inuse)) = @username 
    then null
    else
     InUse end
     end
    else
    InUse 
       end as InUse
   ------------------------------------------------  
 ,IsNull(DisclosedPastAction,0) as  DisclosedPastAction           
  FROM       
   dbo.ProfLic            
  WHERE       
   Apno = @apno        
  UNION ALL             
  SELECT      
    'Licensing' as SectionName      
    ,'Previous' as RecordType          
    ,ProfLicId as SectionId      
    ,Lic_Type         
   ,IsNull(Lic_Type_V,'') as Lic_Type_V      
   ,Lic_No      
   ,IsNull(Lic_No_V,'') as Lic_No_V      
   ,l.State      
   ,IsNull(State_V,'') as State_V    
   ,IsNull(Contact_Name,'') as ContactName      
   ,IsNull(Contact_Title,'') as ContactTitle      
   ,IsNull(Contact_Date,'') as ContactDate  
   ,IsNull(l.Investigator,'') as Investigator        
   ,Convert(VarChar,Expire,101) as Expire      
   ,Convert(VarChar,Expire_V,101) as Expire_V         
   ,[Year]      
   ,IsNull(Year_V,'') as Year_V      
  ,IsNull([Status],'') as [Status]  
   ,IsNull(Status_A,'') as Status_A   
   ,IsNull(Organization,'') as Organization      
   ,IsNull(cast(l.Priv_Notes as varchar(max)),'') as Priv_Notes  
   ,IsNull(cast(l.Pub_Notes as varchar(max)),'') as Pub_Notes        
   ,IsNull(IsOnReport,0) as IsOnReport      
   ,IsNull(IsHidden,0) as IsHidden  
   ,l.apno as Apno   
   ,IsNull(l.Web_Status,0) as Web_Status  
    ,IsNull(l.SectStat,'0') as SectStat    
      ,IsNull(l.InUse,'') as InUse  
       ,IsNull(l.DisclosedPastAction,0) as  DisclosedPastAction     
  FROM       
   dbo.ProfLic l      
   inner join Appl a on l.APNO = a.APNO       
   Where a.SSN = @SSN and l.Apno <> @apno and @includeHistory =1    
 --Added by schapyala on 02/18/2013  
 and IsNull(IsOnReport,0) = 1 --only include records that were on past reports  
 and IsNull(IsHidden,0) = 0)  --only include records that were not marked as unused  
 tbl  
   
  if (@lockAppl = 1)  
    begin
 --Update the temp table's inuse if not null  
  --update #tmpProfLic set InUse = @UserName   
  --where RecordType = 'Current' and apno = @apno and IsNull(InUse,'') = ''    
       
  --Update empls in use from temp table  
  update dbo.ProfLic  
  set InUse = 
    case when RTRIM(LTRIM(isnull(Inuse,''))) = ''
    then @username
    else
     InUse
    end,
	Inuse_Timestamp = Current_Timestamp
  where apno = @apno and IsNull(InUse,'') = ''
  end
  --EmplId in (select SectionId from #tmpEmployment   
  -- where RecordType = 'Current' and IsNull(InUse,'') = '' and apno = @apno)  
          
  -- Return results  
  select * from #tmpProfLic   
    
  --Drop table, we are done  
  drop table #tmpProfLic        
 END  
   END            
     
    IF (@sectionOption = 'PersRef')  
    BEGIN  
    IF (SELECT COUNT(Apno) FROM dbo.PersRef WHERE Apno = @apno) > 0   
    BEGIN              
 SELECT * into #tmpPersRef from   
 (select     
   'PersRef' as SectionName      
    ,'Current' as RecordType      
   ,PersRefId as SectionId      
   ,IsNull(IsHidden,0) as IsHidden      
   ,IsNull(Name,'') as Name    
   ,IsNull(Investigator,'') as Investigator  
   ,@apno as Apno           
   ,IsNull(IsOnReport,0) as IsOnReport      
   ,Phone      
   ,Rel_V as Rel_V      
   ,Years_V      
   ,IsNull(cast(Priv_Notes as varchar(max)),'') as Priv_Notes  
   ,IsNull(cast(Pub_Notes as varchar(max)),'') as Pub_Notes     
   ,IsNull(Web_Status,0) as Web_Status  
  ,IsNull(SectStat,'0') as SectStat  
   --,IsNull(InUse,'') as InUse
   --------------------------------------------
    ,case when @lockAppl = 1
    then
    case when RTRIM(LTRIM(isnull(Inuse,''))) = ''
    then null
    else
    case when RTRIM(LTRIM(Inuse)) = @username 
    then null
    else
     InUse end
     end
    else
    InUse 
       end as InUse
   ------------------------------------------------  
   ,Email
   ,JobTitle   
  FROM       
   dbo.PersRef      
  WHERE      
   apno = @apno      
  UNION ALL      
   SELECT      
   'PersRef' as SectionName      
   ,'Previous' as RecordType      
   ,PersRefId as SectionId      
   ,IsNull(IsHidden,0) as IsHidden      
   ,IsNull(Name,'') as Name  
   ,IsNull(p.Investigator,'') as Investigator   
   ,p.apno as Apno            
   ,IsNull(IsOnReport,0) as IsOnReport      
   ,p.Phone      
   ,Rel_V as Rel_V      
   ,Years_V      
   ,IsNull(cast(p.Priv_Notes as varchar(max)),'') as Priv_Notes  
   ,IsNull(cast(p.Pub_Notes as varchar(max)),'') as Pub_Notes      
   ,IsNull(p.Web_Status,0) as Web_Status  
   ,IsNull(p.SectStat,'0') as SectStat  
   ,IsNull(p.InUse,'') as InUse   
   ,p.Email
   ,p.JobTitle      
  FROM       
   dbo.PersRef p      
   inner join Appl a on p.APNO = a.APNO       
   Where a.SSN = @SSN and p.Apno <> @apno and @includeHistory =1                       
 --Added by schapyala on 02/18/2013  
 and IsNull(IsOnReport,0) = 1 --only include records that were on past reports  
 and IsNull(IsHidden,0) = 0)   --only include records that were not marked as unused  
 tbl  
    if (@lockAppl = 1)  
    begin
 --Update the temp table's inuse if not null  
  --update #tmpPersRef set InUse = @UserName   
  --where RecordType = 'Current' and apno = @apno and IsNull(InUse,'') = ''    
       
  --Update empls in use from temp table  
  update dbo.PersRef  
  set InUse = 
    case when RTRIM(LTRIM(isnull(Inuse,''))) = ''
    then @username
    else
     InUse
    end ,
	Inuse_Timestamp = Current_Timestamp
  where apno = @apno and IsNull(InUse,'') = ''
  end
  --EmplId in (select SectionId from #tmpEmployment   
  -- where RecordType = 'Current' and IsNull(InUse,'') = '' and apno = @apno)  
          
  -- Return results  
  select * from #tmpPersRef   
    
  --Drop table, we are done  
  drop table #tmpPersRef        
 END  
    END  
     
   IF (@sectionOption = 'Credit')  
   BEGIN     
    IF (SELECT COUNT(Apno) FROM dbo.Credit WHERE Apno = @apno) > 0               
 SELECT      
   'Credit' as SectionName      
    ,'Current' as RecordType      
   ,Apno  
   ,RepType as ReportType  
   ,IsNull(SectStat,'0') as SectStat       
   ,Report  
   ,PositiveIDReport as ReportXml          
  FROM       
   dbo.Credit      
  WHERE      
   apno = @apno      
  UNION ALL      
   SELECT      
   'Credit' as SectionName      
   ,'Previous' as RecordType      
   ,c.Apno   
   ,c.RepType as ReportType           
   ,IsNull(c.SectStat,'0') as SectStat  
   ,c.Report  
   ,c.PositiveIDReport as ReportXml         
  FROM       
    dbo.Credit c       
   inner join Appl a on c.APNO = a.APNO       
   Where a.SSN = @SSN and c.Apno <> @apno and @includeHistory =1   
 --Added by schapyala on 02/18/2013  
 and IsNull(IsHidden,0) = 0   --only include records that were not marked as unused   
   END  
   
   
     
     
   IF (@sectionOption = 'SanctionCheck')  
   BEGIN     
    IF (SELECT COUNT(Apno) FROM dbo.Medinteg WHERE Apno = @apno) > 0               
 SELECT      
   'SanctionCheck' as SectionName      
    ,'Current' as RecordType      
   ,Apno     
   ,IsNull(SectStat,'0') as SectStat       
   ,Report  
   ,IsNull(InUse,'') as InUse     
  FROM       
   dbo.Medinteg      
  WHERE      
   apno = @apno      
  UNION ALL      
   SELECT      
   'SanctionCheck' as SectionName      
    ,'Current' as RecordType      
   ,m.Apno     
   ,IsNull(m.SectStat,'0') as SectStat       
   ,m.Report  
   ,IsNull(m.InUse,'') as InUse          
  FROM       
    dbo.Medinteg m      
   inner join Appl a on m.APNO = a.APNO       
   Where a.SSN = @SSN and m.Apno <> @apno and @includeHistory =1       
 --Added by schapyala on 02/18/2013  
 and IsNull(IsHidden,0) = 0   --only include records that were not marked as unused   
   END  
    
  IF (@sectionOption = 'MVR')  
   BEGIN     
    IF (SELECT COUNT(Apno) FROM dbo.DL WHERE Apno = @apno) > 0               
 SELECT      
   'MVR' as SectionName      
    ,'Current' as RecordType      
   ,Apno     
   ,IsNull(SectStat,'0') as SectStat  
   ,Web_Status       
   ,Report  
   ,IsNull(InUse,'') as InUse     
  FROM       
   dbo.DL     
  WHERE      
   apno = @apno      
  UNION ALL      
  SELECT      
   'MVR' as SectionName      
    ,'Current' as RecordType      
   ,d.Apno     
   ,IsNull(d.SectStat,'0') as SectStat  
   ,d.Web_Status       
   ,d.Report  
   ,IsNull(d.InUse,'') as InUse            
  FROM       
    dbo.DL d      
   inner join Appl a on d.APNO = a.APNO       
   Where a.SSN = @SSN and d.Apno <> @apno and @includeHistory =1       
 --Added by schapyala on 02/18/2013  
 and IsNull(IsHidden,0) = 0   --only include records that were not marked as unused   
   END  
   
    IF (@sectionOption = 'PublicRecords') 
    BEGIN
    IF (SELECT COUNT(Apno) FROM dbo.Crim WHERE Apno = @apno) > 0  
    SELECT 'Crim' as SectionName
	   ,[CrimID] as SectionId
      ,[APNO]
      ,[County]
      ,[Clear]
      ,[Ordered]
      ,[Name]
      ,[DOB]
      ,[SSN]
      ,[CaseNo]
      ,[Date_Filed]
      ,[Degree]
      ,[Offense]
      ,[Disposition]
      ,[Sentence]
      ,[Fine]
      ,[Disp_Date]
      ,[Pub_Notes]
      ,[Priv_Notes]
      ,[txtalias]
      ,[txtalias2]
      ,[txtalias3]
      ,[txtalias4]
      ,[uniqueid]
      ,[txtlast]
      ,[Crimenteredtime]
      ,[Last_Updated]
      ,[CNTY_NO]
      ,[IRIS_REC]
      ,[CRIM_SpecialInstr]
      ,[Report]
      ,[batchnumber]
      ,[crim_time]
      ,[vendorid]
      ,[deliverymethod]
      ,[countydefault]
      ,[status]
      ,[b_rule]
      ,[tobeworked]
      ,[readytosend]
      ,[NoteToVendor]
      ,[test]
      ,[InUse]
      ,[parentCrimID]
      ,[IrisFlag]
      ,[IrisOrdered]
      ,[Temporary]
      ,[CreatedDate]
      ,[IsCAMReview]
      ,[IsHidden]
      ,[IsHistoryRecord]
      ,[AliasParentCrimID]
      ,[InUseByIntegration]
      ,[ClientAdjudicationStatus]
  FROM [dbo].[Crim]
  WHERE apno = @apno
  -- SELECT    
  -- 'Crim' as SectionName    
  --  ,'Current' as RecordType    
  -- ,Apno 
  -- ,IsNull(County,'') as County
  -- ,CNTY_NO
  -- ,Clear
  -- ,IsNull(Ordered,'') as Ordered
  -- ,IsNull(Name,'') as Name
  -- ,DOB
  -- ,IsNull(SSN,'') as SSN 
  -- ,[CaseNo]
  -- ,[Date_Filed]
  -- ,[Degree]
  -- ,[Offense]
  -- ,[Disposition]
  -- ,[Sentence]
  -- ,[Fine]
  -- ,[Disp_Date]
  -- ,Last_Updated
  -- ,IsNull(cast([CRIM_SpecialInstr] as varchar),'') as [CRIM_SpecialInstr] 
  -- ,IsNull(cast(Priv_Notes as varchar),'') as Priv_Notes
  -- ,IsNull(cast(Pub_Notes as varchar),'') as Pub_Notes
  -- ,IsNull([Status],'') as [Status]
  -- ,IsNull(ClientAdjudicationStatus,'') as ClientAdjudicationStatus  
  -- ,IsNull(Report,'') as Report
  -- ,CrimId as SectionId  
  -- ,IsNull(InUse,'') as InUse   
  --FROM     
  -- dbo.Crim
  --WHERE    
  -- apno = @apno     
  --UNION ALL
  -- SELECT    
  -- 'Crim' as SectionName    
  --  ,'Previous' as RecordType    
  -- ,C.Apno 
  -- ,IsNull(C.County,'') as County
  -- ,C.CNTY_NO
  -- ,C.Clear
  --  ,IsNull(C.Ordered,'') as Ordered
  -- ,IsNull(C.Name,'') as Name
  -- ,C.DOB as DOB
  -- ,IsNull(C.SSN,'') as SSN 
  --   ,C.[CaseNo]
  -- ,C.[Date_Filed]
  -- ,C.[Degree]
  -- ,C.[Offense]
  -- ,C.[Disposition]
  -- ,C.[Sentence]
  -- ,C.[Fine]
  -- ,C.[Disp_Date]
  --  ,C.Last_Updated
  --  ,IsNull(cast(c.[CRIM_SpecialInstr] as varchar),'') as [CRIM_SpecialInstr] 
  -- ,IsNull(cast(C.Priv_Notes as varchar),'') as Priv_Notes
  -- ,IsNull(cast(C.Pub_Notes as varchar),'') as Pub_Notes
  -- ,IsNull(C.[Status],'') as [Status]
  -- ,IsNull(C.ClientAdjudicationStatus,'') as ClientAdjudicationStatus  
  -- ,IsNull(C.Report,'') as Report
  -- ,C.CrimId as SectionId  
  -- ,IsNull(C.InUse,'') as InUse   
  --FROM     
  -- dbo.Crim c 
  --  inner join Appl a on c.APNO = a.APNO     
  -- Where a.SSN = @SSN and c.Apno <> @apno and @includeHistory =1    
    
   
   
   END
   
     
   --IF (@sectionOption = 'SanctionCheck')  
   --BEGIN  
     
     
   --END  
     
   --IF (@sectionOption = 'MVR')  
   --BEGIN  
     
     
 --  END  
     
     
     
   set @flag = @flag + 1    
     
    
             
 END      
    
   
     
  
      
      
   
        
 --END      
      
 --IF ((SELECT COUNT(Apno) FROM dbo.Educat WHERE Apno = @apno) > 0 AND isnull(@section,'Education') ='Education')      
 --BEGIN      
 -- SELECT       
 --  'Education' as SectionName      
 --  ,'Current' as RecordType         
 --  ,RTRIM(LTRIM(School)) as School      
 --  ,IsNull(Degree_A,'') as Degree_A      
 --  ,IsNull(Studies_A,'') as Studies_A      
 --  ,IsNull(From_A,'') as From_A      
 --  ,IsNull(To_A,'') as To_A      
 --  ,IsNull(From_V,'') as From_V      
 --  ,IsNull(To_V,'') as To_V      
 --  ,CampusName         
 --  ,RTRIM(LTRIM(City)) as City      
 --  ,State      
 --  ,zipcode      
 --  ,IsNull(Name,'') as Name      
 --  ,IsNull(cast(Priv_Notes as varchar),'') as Priv_Notes           
 --  ,EducatId as SectionId      
 --  ,IsNull(IsOnReport,0) as IsOnReport      
 --  ,IsNull(IsHidden,0) as IsHidden      
 --  FROM       
 --  dbo.Educat       
 --  WHERE       
 --  Apno = @apno      
           
 -- Union All      
 -- SELECT      
 --  'Education' as SectionName      
 --  ,'Previous' as RecordType      
 --  ,RTRIM(LTRIM(School)) as School      
 --  ,IsNull(Degree_A,'') as Degree_A      
 --  ,IsNull(Studies_A,'') as Studies_A      
 --  ,IsNull(From_A,'') as From_A      
 --  ,IsNull(To_A,'') as To_A      
 --  ,IsNull(From_V,'') as From_V      
 --  ,IsNull(To_V,'') as To_V      
 --  ,CampusName         
 --  ,RTRIM(LTRIM(e.City)) as City      
 --  ,e.State as State      
 --  ,zipcode      
 --  ,IsNull(Name,'') as Name      
 --  ,IsNull(cast(e.Priv_Notes as varchar),'') as Priv_Notes          
 --  ,EducatId as SectionId      
 --  ,IsNull(IsOnReport,0) as IsOnReport      
 --  ,IsNull(IsHidden,0) as IsHidden       
 --   FROM dbo.Educat e       
 --  inner join Appl a on e.APNO = a.APNO       
 --  Where a.SSN = @SSN and e.Apno <> @apno and @includeHistory =1       
          
             
 --END      
      
 --IF ((SELECT COUNT(Apno) FROM dbo.Empl WHERE Apno = @apno) > 0 AND isnull(@section,'Employment') ='Employment')      
 --BEGIN      
 -- SELECT       
 --   'Employment' as SectionName      
 --   ,'Current' as RecordType          
 --   ,RTRIM(LTRIM(Employer)) as Employer      
 --  ,RTRIM(LTRIM(Location)) as Location      
 --  ,RTRIM(LTRIM(City)) as City      
 --  ,State      
 --  ,zipcode      
 --  ,IsNull(Position_A,'') as Position_A      
 --  ,IsNull(Ver_Salary,0) as Ver_Salary      
 --  ,IsNull(SpecialQ,0) as SpecialQ         
 --  ,IsNull(From_A,'') as From_A      
 --  ,IsNull(To_A,'') as To_A      
 --  ,IsNull(From_V,'') as From_V      
 --  ,IsNull(To_V,'') as To_V      
 --  ,Dept      
 --  ,IsNull(DNC,0) as DNC      
 --  ,RFL         
 --  ,RTRIM(LTRIM(Supervisor)) as Supervisor      
 --  ,RTRIM(LTRIM(SupPhone)) as SupPhone      
 --  ,IsNull(cast(Priv_Notes as varchar),'') as Priv_Notes      
 --   ,EmplId as SectionId      
 --  ,IsNull(IsOnReport,0) as IsOnReport      
 --  ,IsNull(IsHidden,0) as IsHidden      
 --  ,IsNull(Title,'') as Title      
 --  ,IsNull(Emp_Type,'') as Emp_Type      
 --  ,IsNull(Rel_Cond,'') as Rel_Cond         
 --  ,IsNull(Rehire,'') as Rehire         
 --  ,IsNull(Web_Status,0) as WebStatus      
 --  ,IsNull(Ver_By,'') as Ver_By      
 --  ,IsNull(IsOkToContact,0) as ContactPresentEmpl      
 -- FROM       
 --  dbo.Empl      
 -- WHERE       
 --  Apno = @apno      
 -- UNION ALL      
 -- SELECT       
 --   'Employment' as SectionName      
 --   ,'Previous' as RecordType         
 --   ,RTRIM(LTRIM(Employer)) as Employer      
 --  ,RTRIM(LTRIM(Location)) as Location      
 --  ,RTRIM(LTRIM(e.City)) as City      
 --  ,e.State      
 --  ,zipcode      
 --  ,IsNull(Position_A,'') as Position_A      
 --  ,IsNull(Ver_Salary,0) as Ver_Salary      
 --  ,IsNull(SpecialQ,0) as SpecialQ         
 --  ,IsNull(From_A,'') as From_A      
 --  ,IsNull(To_A,'') as To_A      
 --  ,IsNull(From_V,'') as From_V      
 --  ,IsNull(To_V,'') as To_V      
 --  ,Dept      
 --  ,IsNull(DNC,0) as DNC      
 --  ,RFL         
 --  ,RTRIM(LTRIM(Supervisor)) as Supervisor      
 --  ,RTRIM(LTRIM(SupPhone)) as SupPhone      
 --  ,IsNull(cast(e.Priv_Notes as varchar),'') as Priv_Notes      
 --   ,EmplId as SectionId      
 --  ,IsNull(IsOnReport,0) as IsOnReport      
 --  ,IsNull(IsHidden,0) as IsHidden      
 --  ,IsNull(Title,'') as Title      
 --  ,IsNull(Emp_Type,'') as Emp_Type      
 --  ,IsNull(Rel_Cond,'') as Rel_Cond         
 --  ,IsNull(Rehire,'') as Rehire         
 --  ,IsNull(Web_Status,0) as WebStatus      
 --  ,IsNull(Ver_By,'') as Ver_By      
 --  ,IsNull(IsOkToContact,0) as ContactPresentEmpl      
 -- FROM       
 --  dbo.Empl e      
 --  inner join Appl a on e.APNO = a.APNO       
 --  Where a.SSN = @SSN and e.Apno <> @apno and @includeHistory =1        
 --END      
       
 --IF ((SELECT COUNT(Apno) FROM dbo.ProfLic WHERE Apno = @apno) > 0 AND isnull(@section,'Licensing') ='Licensing')      
 --BEGIN      
 -- SELECT      
 --   'Licensing' as SectionName      
 --   ,'Current' as RecordType          
 --   ,ProfLicId as SectionId      
 --   ,Lic_Type         
 --  ,IsNull(Lic_Type_V,'') as Lic_Type_V      
 --  ,Lic_No      
 --  ,IsNull(Lic_No_V,'') as Lic_No_V      
 --  ,State      
 --  ,IsNull(State_V,'') as State_V      
 --  ,Convert(VarChar,Expire,101) as Expire      
 --  ,Expire_V         
 --  ,[Year]      
 --  ,IsNull(Year_V,'') as Year_V      
 --  ,[Status]         
 --  ,IsNull(Organization,'') as Organization      
 --  ,IsNull(cast(Priv_Notes as varchar),'') as Priv_Notes      
 --  ,IsNull(IsOnReport,0) as IsOnReport      
 --  ,IsNull(IsHidden,0) as IsHidden      
 -- FROM       
 --  dbo.ProfLic            
 -- WHERE       
 --  Apno = @apno       
 -- --AND isnull(@section,'Licensing') ='Lic'      
 -- UNION ALL       
        
 -- SELECT      
 --   'Licensing' as SectionName      
 --   ,'Previous' as RecordType          
 --   ,ProfLicId as SectionId      
 --   ,Lic_Type         
 --  ,IsNull(Lic_Type_V,'') as Lic_Type_V      
 --  ,Lic_No      
 --  ,IsNull(Lic_No_V,'') as Lic_No_V      
 --  ,l.State      
 --  ,IsNull(State_V,'') as State_V      
 --  ,Convert(VarChar,Expire,101) as Expire      
 --  ,Expire_V         
 --  ,[Year]      
 --  ,IsNull(Year_V,'') as Year_V      
 --  ,[Status]         
 --  ,IsNull(Organization,'') as Organization      
 --  ,IsNull(cast(l.Priv_Notes as varchar),'') as Priv_Notes      
 --  ,IsNull(IsOnReport,0) as IsOnReport      
 --  ,IsNull(IsHidden,0) as IsHidden      
 -- FROM       
 --  dbo.ProfLic l      
 --  inner join Appl a on l.APNO = a.APNO       
 --  Where a.SSN = @SSN and l.Apno <> @apno and @includeHistory =1      
         
 --END      
       
 --IF ((SELECT COUNT(Apno) FROM dbo.PersRef WHERE Apno = @apno) > 0 AND isnull(@section,'PersRef') ='PersRef')      
 --BEGIN      
 -- SELECT      
 --  'PersRef' as SectionName      
 --   ,'Current' as RecordType      
 --  ,PersRefId as SectionId      
 --  ,IsNull(IsHidden,0) as IsHidden      
 --  ,IsNull(Name,'') as Name      
 --  ,IsNull(IsOnReport,0) as IsOnReport      
 --  ,Phone      
 --  ,Rel_V as Rel_V      
 --  ,Years_V      
 --  ,IsNull(cast(Priv_Notes as varchar),'') as Priv_Notes      
 -- FROM       
 --  dbo.PersRef      
 -- WHERE      
 --  apno = @apno      
 -- UNION ALL      
 --  SELECT      
 --  'PersRef' as SectionName      
 --  ,'Previous' as RecordType      
 --  ,PersRefId as SectionId      
 --  ,IsNull(IsHidden,0) as IsHidden      
 --  ,IsNull(Name,'') as Name      
 --  ,IsNull(IsOnReport,0) as IsOnReport      
 --  ,p.Phone      
 --  ,Rel_V as Rel_V      
 --  ,Years_V      
 --  ,IsNull(cast(p.Priv_Notes as varchar),'') as Priv_Notes      
 -- FROM       
 --  dbo.PersRef p      
 --  inner join Appl a on p.APNO = a.APNO       
 --  Where a.SSN = @SSN and p.Apno <> @apno and @includeHistory =1             
 --END      
       
       
       
 --declare @credit int      
 --declare @mvr int      
 --declare @sanctioncheck int      
      
 --select @credit = isnull((select count(1) from dbo.Credit where APNO = @apno),0)      
 --select @mvr = isnull((select count(1) from dbo.Crim where APNO = @apno),0)      
 --select @sanctioncheck = IsNull((select count(1) from MEDINTEG where @apno = @apno),0)      
      
 --if @mvr > 0 set @mvr = 1      
 --if @credit > 0 set @credit= 1      
 --if @sanctioncheck > 0 set @sanctioncheck= 1      
 --if (@section = 'All')      
 -- select 'Orders' as SectionName,@credit as order_credit, @mvr as order_mvr,@sanctioncheck as order_sanctioncheck      
      
--END 

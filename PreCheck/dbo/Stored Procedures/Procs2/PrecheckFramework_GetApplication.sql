--[dbo].[PrecheckFramework_GetApplication] 7058608, 0, 'Education|Licensing', 'dhe', 0, 1
-- =============================================
-- Modified on 04/11/2023 -casting IsEligibleForRehire column  for HDT #89923
-- Modified on 6/15/2023 by Diksha Salunke for CXHE-37 - ME 71382 - Update Logic that alerts Admitted Record in system for different clients using online release forms in line 112
-- Modified on 9/18/2023 by Dongmei He for Velocity Update 1.7
-- =============================================
CREATE PROCEDURE [dbo].[PrecheckFramework_GetApplication](@apno int = null,@includeHistory bit,@sectionList varchar(100) = null,@username varchar(20) = null,@lockAppl bit = 0, @IsHCA BIT = NULL)      
AS   
SET NOCOUNT ON;      
   
declare @flag int  
declare @count int  
declare @sectionOption varchar(50)  
declare @ssn varchar(30) 
declare @subStatusDesc varchar(300)
declare @IsReview bit
declare @ssnWithoutDash varchar(11)
DECLARE @Clno INT


 -- PR05
Select @Clno = clno from appl where apno = @apno

IF (charindex('AllSections', @sectionList) > 0)
	SET @sectionList = 'ApplicationData|Employment|Education|Licensing|PersRef|Credit|MVR|SanctionCheck|PublicRecords'
SET @count = (
		SELECT count(*)
		FROM fn_Split(@sectionList, '|')
		);
SET @flag = 0


IF ISNULL(@IsHCA, 0) = 0 -- PR05
BEGIN -- PR05

select @IsReview = chkReview from Metastorm9_2.dbo.oasis where apno=Convert(varchar,@apno)
  
if (IsNull(@username,'') = '')  
 set @username = ''  

 if (@userName is not null)
	set @userName = Left(@userName,8)
  
--set @ssn = select top 1 ssn from dbo.appl where apno = @apno order by apdate desc)  
Select @Ssn = [Ssn], @ssnWithoutDash = Replace(a.[Ssn], '-', '') From [dbo].[appl] a where a.[ApNo] = @apNo order by a.[apdate] desc

SET ARITHABORT ON  
-- Change to pull custom client data for US_ONCOLOGY  
    IF(SELECT COUNT(Apno) from dbo.ApplClientData where Apno = @apno) > 0  
		SELECT   
		'CustomClientData' as SectionName,  
		APNO,   
		NewTable.RequestXML.query('data(ClientData1)') AS ClientData1,  
		NewTable.RequestXML.query('data(ClientData2)') AS ClientData2,   
		NewTable.RequestXML.query('data(ClientData3)') AS  ClientData3,
		NewTable.RequestXML.query('data(ClientData4)') AS  ClientData4    
		FROM applclientdata CROSS APPLY XMLD.nodes('//CustomClientData') AS NewTable(RequestXML)  
		WHERE  
		apno = @apno
		  
SET ARITHABORT OFF 
declare @clientCertReceived varchar(5)

Drop table if exists #ApplAdditional
create table #ApplAdditional
(
	SectionName varchar(100),
	Candidate_SelfDisclosed bit,
	SalaryRange varchar(100),
	State_Employment_Occur varchar(20),
	ClientCertReceived varchar(5),
	ClientCertBy varchar(500)
)



insert into #ApplAdditional
select 
	'ApplAdditionalData' as SectionName,
	case when SUM(Candidate_SelfDisclosed) > 0 then 1 else 0 end as Candidate_SelfDisclosed,
	max(SalaryRange) as SalaryRange,
	max(State_Employment_Occur) as State_Employment_Occur,
	max(ClientCertReceived) as ClientCertReceived,
	max(ClientCertBy) as ClientCertBy
from
(
select  
	'ApplAdditionalData' as SectionName,
	 0 as Candidate_SelfDisclosed,
	 '' as SalaryRange ,
	 '' as State_Employment_Occur,
	cc.ClientCertReceived,
	cc.ClientCertBy
	from  dbo.ClientCertification cc
	where cc.apno = @apno
	UNION ALL
	select top 1 'ApplAdditionalData' as SectionName,
	 Crim_SelfDisclosed as Candidate_SelfDisclosed,
	 SalaryRange,
	 StateEmploymentOccur as State_Employment_Occur,
	null as ClientCertReceived,
	null as ClientCertBy
	from dbo.ApplAdditionalData ad --left join dbo.ClientCertification cc on
	--ad.APNO = cc.APNO 	
	where 
		Replace(ad.SSN,'-','') = Replace(@ssn,'-','') and ad.APNO = @apno
	ORDER BY DateCreated desc
	UNION ALL
	select 'ApplAdditionalData' as SectionName,
	 Crim_SelfDisclosed as Candidate_SelfDisclosed,
	 SalaryRange,
	 StateEmploymentOccur as State_Employment_Occur,
	null as ClientCertReceived,
	null as ClientCertBy
	from dbo.ApplAdditionalData ad --left join dbo.ClientCertification cc on
	--ad.APNO = cc.APNO 	
	where ad.APNO = @apno 	
	) tbl

	
if (select count(1) from #ApplAdditional) > 0
Begin
	select @clientCertReceived = ClientCertReceived from #ApplAdditional
	select * from #ApplAdditional 
END

 IF (SELECT COUNT(Apno) from dbo.ApplAlias where Apno = @apno) > 0
     BEGIN
		--SELECT DISTINCT 'ApplAlias' as SectionName,ApplAliasID as SectionId,First,Middle,Last,Generation, IsPublicRecordQualified, IsPrimaryName, CreatedDate, CreatedBy from dbo.ApplAlias 
		--where Apno = @apno and IsActive = 1 and IsPrimaryName = 0--and IsNull(Deleted,0) = 0   
		
		--SELECT DISTINCT 'ApplAlias' as SectionName,MIN(ApplAliasID) as SectionId, First,isnull(Middle,'') Middle,Last,isnull(Generation,'') Generation
		--, cast(max(cast(IsPublicRecordQualified as int)) as bit) IsPublicRecordQualified, cast(max(cast(IsPrimaryName as int)) as bit) IsPrimaryName, MIN(CreatedDate) CreatedDate, MIN(CreatedBy) CreatedBy
		--FROM dbo.ApplAlias 
  --      where Apno = @apno and IsActive = 1 and IsPrimaryName = 0
  --      GROUP BY First,isnull(Middle,''),Last,isnull(Generation,'')	
		--Order By IsPublicRecordQualified desc	
		
		Select * from (
         SELECT  distinct 'ApplAlias' as SectionName, min(ApplAliasID) as SectionId, First,isnull(Middle,'') Middle,Last,isnull(Generation,'') Generation
		, cast(max(cast(IsPublicRecordQualified as int)) as bit) IsPublicRecordQualified, cast(min(cast(IsPrimaryName as int)) as bit) IsPrimaryName, MIN(CreatedDate) CreatedDate, MIN(CreatedBy) CreatedBy
		FROM dbo.ApplAlias 		
        where Apno = @apno and IsActive = 1 and IsPrimaryName = 0
        GROUP BY First,isnull(Middle,''),Last,isnull(Generation,'')
		)A  --where  A.IsPrimaryName  = 0 
			Order By A.IsPublicRecordQualified desc	
		  
		
       		 
     END
END  --PR05

--exec PrecheckFramework_GetByApno @apno  
IF(@Clno = 11625 or @Clno = 11340) AND ISNULL(@IsHCA, 0) = 1
   SELECT apno from educat where 0 =1
ELSE
BEGIN

while (@flag <= @count)  
BEGIN   
 set @sectionOption = (select value from fn_Split(@sectionList,'|') where idx = @flag);      
      
      
 
     
      
IF ISNULL(@IsHCA, 0) = 0 -- PR05
BEGIN -- PR05     
    ---------- Application ----------------  
if (@sectionOption = 'ApplicationData')  
  BEGIN   
	IF (SELECT COUNT(Apno) FROM dbo.Appl WHERE Apno = @apno) > 0  
	BEGIN          
				 
		 -- Get substatus description.  THis is a change for the Client Certification enhancement
		 if (select isnull(@clientCertReceived,'')) = 'no'
		 BEGIN
						

			SELECT top 1 @subStatusDesc =  ss.SubStatus FROM dbo.Appl A INNER JOIN dbo.SubStatus SS ON A.SubStatusID = SS.SubStatusID 
					AND APNO = @APNO  --AND ApStatus = 'M' 
		END

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
			--,Addr_Street    
			,REPLACE(REPLACE(Addr_Street, CHAR(13), ' '), CHAR(10), ' ') as Addr_Street --By Humera Ahmed on 8/25/2020 to add space between Address lines.    
			,Addr_Apt        
			,Addr_Dir        
			--,IsNull(Attn,'') as Attn 
			,CASE WHEN CHARINDEX('@', Attn) > 0 THEN ISNULL([dbo].[GetAttentionNameFromEmail](@Apno, Attn), '') -- Modified per Dana's request 09/03/2019
			 ELSE IsNull(Attn,'')  END Attn          
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
			,IsNull(@subStatusDesc,'') as SubStatusDescription   
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
		--) tbl  
     
		IF (@lockAppl = 1)  
		BEGIN        
			--Update empls in use from temp table  
			update dbo.Appl  
			set InUse = @username  
			where apno = @apno and IsNull(InUse,'') = ''        
		END    
     
  -- -- Return results  
  --select * from #tmpAppl   
    
  ----Drop table, we are done  
  --drop table #tmpAppl              
        
         
    END      
  
           
	 declare @credit int          
	 declare @mvr int          
	 declare @sanctioncheck int          
  
	 set @credit = 0  
	 set @mvr = 0  
	 set @sanctioncheck = 0          
	 select @credit = isnull((select count(1) from dbo.Credit where APNO = @apno),0)          
	 select @mvr = isnull((select count(1) from dbo.Crim where APNO = @apno),0)          
	 select @sanctioncheck = IsNull((select count(1) from dbo.MEDINTEG where APNO = @apno),0)          
          
	 if @mvr > 0 set @mvr = 1          
	 if @credit > 0 set @credit= 1          
	 if @sanctioncheck > 0 set @sanctioncheck= 1          
          
	 select 'Orders' as SectionName,@credit as order_credit, @mvr as order_mvr,@sanctioncheck as order_sanctioncheck,null as Order_FedBankruptcy,null as Order_NewspaperArticle,null as Order_PositiveID,null as Order_USCivil,null as Order_USFederal          
  --exec PrecheckFramework_GetByApno @apno  
 END  
      
 if (@sectionOption = 'Counts')  
   Begin  
	  select 'Counts' as SectionName,Section,SectionCount from  
	  (  
	   select 'Employment' as Section,count(EmplId) as SectionCount from dbo.Empl where apno = @apno  and IsNull(IsHidden,0) = 0
	   Union All  
	   select 'Education' as Section,count(EducatId) as SectionCount from dbo.Educat where apno = @apno  and IsNull(IsHidden,0) = 0
	   Union All  
	   select 'Licensing' as Section,count(ProfLicId) as SectionCount from dbo.ProfLic where apno = @apno  and IsNull(IsHidden,0) = 0
	   Union All  
	   select 'PersonalReference' as Section,count(PersRefId) as SectionCount from dbo.PersRef where apno = @apno and IsNull(IsHidden,0) = 0 
	   Union All  
	   select 'MVR' as Section,count(apno) as SectionCount from dbo.DL where apno = @apno and IsNull(IsHidden,0) = 0
	   Union All
	   select 'Credit' as Section,count(apno) as SectionCount from dbo.Credit where apno = @apno and RepType = 'C' and IsNull(IsHidden,0) = 0
	   Union All
	   select 'PID' as Section,count(apno) as SectionCount from dbo.Credit where apno = @apno and RepType = 'S' and IsNull(IsHidden,0) = 0
	   Union All
	   select 'SanctionCheck' as Section,count(apno) as SectionCount from dbo.MedInteg where apno = @apno and IsNull(IsHidden,0) = 0
	   --select 'PublicRecords' as Section,count(CrimId) as SectionCount from dbo.Crim where apno = @apno     
	  ) secTbl  
	  group by Section,SectionCount  
 End  
 
 END -- PR05
                  
    ---------- EMPLOYMENT ----------------  
IF (@sectionOption = 'Employment')  
 BEGIN  
  --IF (SELECT COUNT(Apno) FROM dbo.Empl WHERE Apno = @apno) > 0         
  --BEGIN      
  -- Select * into #tmpEmployment from  
  -- ( 
  select * from ( 
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
   -- Set DNC info on RFL for AIMI fix 07/03/2014
    --,IsNull(RFL,'') as RFL 
	,case when charindex('OK TO CONTACT',IsNull([RFL],''))>0 or charindex('DO NOT CONTACT',IsNull([RFL],''))>0  then [RFL] else (IsNull([RFL],'') + (case  IsNull(DNC,0) When 1  then ';DO NOT CONTACT' else ';OK TO CONTACT' end )) END  as RFL   
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
	--,case when SectStat = '9' then 'H' 
	--else IsNull(SectStat,'0') end as SectStat    
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
    ,RecipientName_V
	  ,City_V
	  ,State_V
	  ,Country_V        
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
	--,case when SectStat = '9' then 'H' 
	--else IsNull(SectStat,'0') end as SectStat      
    ,IsNull(Ver_By,'') as Ver_By      
    ,IsNull(IsOkToContact,0) as ContactPresentEmpl  
    ,e.apno as Apno  
    ,e.Investigator as Investigator       
    ,a.Apdate        
    ,IsNull(e.InUse,'') as InUse
    ,e.Email
	 ,IsNull(e.IsIntl,0) as IsIntl  
   ,RecipientName_V
	 ,City_V
	 ,State_V
	 ,Country_V      
     FROM       
     dbo.Empl e      
     INNER JOIN dbo.Appl a on e.APNO = a.APNO       
     WHERE a.SSN = @SSN and e.Apno <> @apno and @includeHistory = 1   
     --Added by schapyala on 02/18/2013  
     and IsNull(IsOnReport,0) = 1 --only include records that were on past reports  
     and IsNull(IsHidden,0) = 0   
			
	 UNION ALL      
   SELECT       
    'Employment' as SectionName      
    ,'Previous' as RecordType        
    ,LEFT(RTRIM(LTRIM(ISNULL(ec.CompanyName,''))),30) as Employer
    ,RTRIM(LTRIM(ISNULL(ec.Address, ''))) as Location      
    ,RTRIM(LTRIM(ec.City)) as City      
    ,ec.State      
    ,ISNULL(ec.Zipcode, '') AS zipcode   
    ,IsNull(ec.LastPosition,'') as Position_A    
    ,IsNull(ec.LastPosition,'') as Position_V     
    ,IsNull(ec.FinalSalary,0) as Ver_Salary      
    ,CAST(0 AS BIT) as SpecialQ   
    ,CAST(0 AS BIT) as AdverseRFL  
	,IsNull(CONVERT(VARCHAR(10), ec.HireDate, 103),'') as From_A      
    ,IsNull(CONVERT(VARCHAR(10), ec.SearationDate, 103),'') as To_A 
    ,IsNull(CONVERT(VARCHAR(10), ec.HireDate, 103),'') as From_V      
    ,IsNull(CONVERT(VARCHAR(10), ec.SearationDate, 103),'') as To_V 
    ,ISNULL(ec.Department, '') as Dept      
    ,IsNull(ec.DNC,0) as DNC    
    ,IsNull(ec.RFL,'') as RFL             
    ,IsNull(ec.Phone,'') as EmployerPhone     
    ,RTRIM(LTRIM(ISNULL(ec.Supervisor, ''))) as Supervisor      
    ,RTRIM(LTRIM(ISNULL(ec.SupPhone, ''))) as SupPhone      
    ,IsNull(cast(ec.Notes as varchar(max)),'') as Priv_Notes   
    ,'' as Pub_Notes     
     ,ec.EmploymentCredentialID as SectionId      
    ,CAST(0 AS BIT) as IsOnReport      
    ,CAST(0 AS BIT) as IsHidden      
    ,IsNull(ec.LastPosition,'') as Title      
    ,CASE 
		WHEN ec.EmploymentTypes LIKE '%IC%' THEN 'C'
		WHEN ec.EmploymentTypes LIKE '%EM%' THEN 'F'
		WHEN ec.EmploymentTypes LIKE '%TM%' THEN 'T'
		WHEN ec.EmploymentTypes LIKE '%FT%' THEN 'F'
		WHEN ec.EmploymentTypes LIKE '%IN%' THEN 'C'
		WHEN ec.EmploymentTypes LIKE '%PT%' THEN 'P'
		WHEN ec.EmploymentTypes LIKE '%OT%' THEN 'N'
		ELSE ''
	END as Emp_Type      
    ,'' as Rel_Cond         
	,CAST(ISNULL(ec.IsEligibleForRehire,'') as VARCHAR(1)) as Rehire  
    ,0 as Web_Status  
    ,'4' as SectStat    
    ,IsNull(ec.CredentialSource,'') as Ver_By      
    ,IsNull(ec.DNC,0) as ContactPresentEmpl  
    ,a.Apno as Apno  
    ,ec.CredentialSource AS Investigator       
    ,a.Apdate        
    ,'' as InUse
    ,ec.Email
	 ,CAST(0 AS BIT) as IsIntl
   ,ec.RecipientFirstName +' ' + ec.RecipientMiddleName + ' ' + ec.RecipientLastName as RecipientName_V
	 ,ec.City as City_V
	 ,ec.State as State_V
	 ,ec.Country as Country_V   
     FROM       
     dbo.EmploymentCredentials ec
	 JOIN  Enterprise.[Staging].[ApplicantStage] s ON s.StagingApplicantId = ec.StagingApplicantId
     INNER JOIN Appl a on s.ApplicantNumber = a.APNO       
     WHERE a.SSN = @SSN and a.Apno = @apno
     
    
	 ) tbl
	 order by RecordType asc,apno desc
	 --only include records that were not marked as unused  
     ----order by a.Apdate desc  
     --) tbl  
	          
 if (@lockAppl = 1)  
    begin 
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

	if (@IsReview = 1)  --dhe added on 04/16/2018
    begin 
		  update dbo.Empl  
		  set SectStat = 'H'
		  where apno = @apno and SectStat = '9' 
	end 
      
  ---- Return results  
  --select * from #tmpEmployment   
    
  ----Drop table, we are done  
  --drop table #tmpEmployment         
  --END  
  END  
    
    
   
IF (@sectionOption = 'Education')  
  BEGIN  
  --IF (SELECT COUNT(Apno) FROM dbo.Educat WHERE Apno = @apno) > 0    
  --BEGIN  
  --Select * into #tmpEducation from  
  --(  
  select * from (
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
    ,E.CampusName         
    ,RTRIM(LTRIM(City)) as City      
    ,E.State      
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
    --PR05
	,E.GraduationYear
	
	,ISNULL(RTRIM(LTRIM(E.EducationLevel)), 'Unknown') + ' - (' + ISNULL(E.EducationLevelCode, 'Unknown')  + ')' AS EducationLevel
		
	,REPLACE(ISNULL(RTRIM(LTRIM(E.School)), 'Unknown'), '&', ' and ') + ' - (' + ISNULL(E.SchoolCode, 'Other') + ')' AS Institution

	,CASE WHEN S.IsVerifyStatus = 1 AND E.IsOnReport = 1 
		THEN 
			CASE WHEN ISNULL(RTRIM(LTRIM(E.Studies_V)), '') = '' THEN
			    'Unknown' + ' - (' + ISNULL(E.StudiesCode, 'Unknown') + ')'
            ELSE 
				REPLACE(RTRIM(LTRIM(E.Studies_V)), '&', ' and ') + ' - (' + ISNULL(E.StudiesCode, 'Other') + ')' END 
		ELSE 
			CASE WHEN ISNULL(RTRIM(LTRIM(E.Studies_A)), '') = '' THEN
			    'Unknown' + ' - (' + ISNULL(E.StudiesCode, 'Unknown') + ')'
			ELSE
				REPLACE(ISNULL(RTRIM(LTRIM(E.Studies_A)), 'Unknown'), '&', ' and ') + ' - (' + ISNULL(E.StudiesCode, 'Unknown') + ')' END
		END AS Specialization


    ,CASE WHEN S.IsVerifyStatus = 1 AND E.IsOnReport = 1 THEN Cast(1 as bit)
			ELSE Cast(0 as bit)
			END AS HasVerified
        ,CASE WHEN E.IsOnReport = 0 THEN 'Not On Report'
			ELSE S.Description END AS LeadStatus
	,CASE WHEN E.IsOnReport = 0 THEN 'Not On Report'
			ELSE SS.SectSubStatus END AS LeadSubStatus
   	,Last_Updated
	,E.HasGraduated 
  ,Recipientname_V
	,GraduationDate_V
	,City_V
	,State_V
	,Country_V
	FROM dbo.Educat E
	LEFT JOIN SectStat S
	ON E.SectStat = S.Code
	LEFT JOIN SectSubStatus SS
		ON E.SectStat = SS.SectStatusCode
		AND E.SectSubStatusID = SS.SectSubStatusID
    WHERE       
    Apno = @apno 
		--PR05               
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
	--PR05
	,null As GraduationYear
	,null AS EducationLevel
	,null AS Institution
	,null AS Specialization
	,null AS HasVerified
	,null AS LeadStatus
	,null AS LeadSubStatus
   	,null AS Last_Updated
	,null AS HasGraduated
	--PR05
  ,Recipientname_V
	,GraduationDate_V
	,City_V
	,State_V
	,Country_V
  FROM dbo.Educat e       
    inner join Appl a on e.APNO = a.APNO       
    Where a.SSN = @SSN and e.Apno <> @apno and @includeHistory =1    
  --Added by schapyala on 02/18/2013  
  and IsNull(IsOnReport,0) = 1 --only include records that were on past reports  
  and IsNull(IsHidden,0) = 0   --only include records that were not marked as unused    
    ----order by a.ApDate desc  

				Union All      
   SELECT      
    'Education' as SectionName      
    ,'Previous' as RecordType      
    ,RTRIM(LTRIM(ec.SchoolName)) as School      
    ,LEFT(ISNULL(ec.Degree,''),25) as Degree_A      
    ,IsNull(ec.Major,'') as Studies_A   
    ,LEFT(ISNULL(ec.Degree,''),25) as Degree_V      
    ,IsNull(ec.Major,'') as Studies_V  
    ,ec.CredentialSource as ContactName  
    ,'' as ContactTitle            
    ,ec.CreatedDate as ContactDate               
    ,IsNull(ec.StartDate,'') as From_A      
    ,IsNull(ec.EndDate,'') as To_A      
    ,IsNull(ec.StartDate,'') as From_V      
    ,IsNull(ec.EndDate,'') as To_V      
    ,'' AS CampusName         
    ,RTRIM(LTRIM(ec.City)) as City      
    ,ec.State as State      
    ,ec.Zipcode      
    , CASE WHEN s.MiddleName IS NULL AND s.FirstName IS NULL AND s.LastName IS NULL THEN ''
	WHEN s.MiddleName IS NULL THEN s.LastName+' '+s.FirstName
	ELSE s.LastName+' '+ s.FirstName +' '+s.MiddleName
	END  as Name      
     ,IsNull(cast(ec.Notes as varchar(max)),'') as Priv_Notes  
     ,'' as Pub_Notes            
    ,ec.EducationCredentialID as SectionId      
    ,CAST(0 AS BIT) as IsOnReport      
    ,CAST(0 AS BIT) as IsHidden  
    ,0 as Web_Status
    ,'4' as SectStat    
    ,a.apno as Apno  
    ,ec.CredentialSource as Investigator    
    ,a.Apdate         
    ,'' as InUse
    ,CAST(0 AS BIT) as IsIntl  
	--PR05
	,null As GraduationYear
	,null AS EducationLevel
	,null AS Institution
	,null AS Specialization
	--,null As EducationLevelShortName
	--,null As SchoolShortName
	--,null As MajorShortName
	,null AS HasVerified
	,null AS LeadStatus
	,null AS LeadSubStatus
   	,null AS Last_Updated
	,null AS HasGraduated
	--PR05
  ,ec.RecipientFirstName +' ' + ec.RecipientMiddleName + ' ' + ec.RecipientLastName as RecipientName_V
	,cast(ec.GraduationDate as date)
	,ec.City as City_V
	,ec.State as State_V
	,ec.Country as Country_V
  FROM dbo.[EducationCredentials] ec     
  JOIN Enterprise.[Staging].[ApplicantStage] s ON s.StagingApplicantId = ec.StagingApplicantId  
    INNER JOIN Appl a on s.ApplicantNumber = a.APNO  
    Where  a.Apno = @apno
    ) tbl2
	order by RecordType asc,apno desc  
	 
  if (@lockAppl = 1)  
    begin     
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
 
 if (@IsReview = 1)  --dhe added on 04/16/2018
    begin 
		  update dbo.Educat 
		  set SectStat = 'H'
		  where apno = @apno and SectStat = '9' 
	end 
  ---- Return results  
  --select * from #tmpEducation   
    
  ----Drop table, we are done  
  --drop table #tmpEducation        
  --    END  
 END  
              
IF (@sectionOption = 'Licensing')  
	BEGIN    
  -- IF (SELECT COUNT(Apno) FROM dbo.ProfLic WHERE Apno = @apno) > 0   
  -- BEGIN  
  -- Select * into #tmpProfLic from  
  --(         
  SELECT      
    'Licensing' as SectionName      
    ,'Current' as RecordType          
    ,ProfLicId as SectionId      
    ,Lic_Type         
   --,IsNull(Lic_Type_V,'') as Lic_Type_V  
   --PR05 
   ,CASE WHEN Lic_Type_V = '0' THEN '' 
			      WHEN Lic_Type_V = null THEN '' 
				  ELSE Lic_Type_V
				  END AS Lic_Type_V   
   --PR05
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
   ,IsNull(LicenseTypeId,0) as LicenseTypeId     
  --PR05
	,CASE WHEN MultiState_V IN('Yes','Multi-State', 'Multistate') THEN 'Yes'
			WHEN MultiState_V IN('Single State', 'No') THEN 'No'
			ELSE 'N/A' END  AS MultiStateOption
		,CASE WHEN S.IsVerifyStatus = 1 AND P.IsOnReport = 1 THEN Cast(1 as bit)
			ELSE Cast(0 as bit)
			END AS HasVerified -- license status or process status
		,CASE WHEN P.IsOnReport = 0 THEN 'Not On Report'
				ELSE S.Description END AS LeadStatus
        ,CASE WHEN P.IsOnReport = 0 THEN 'Not On Report'
				ELSE SS.SectSubStatus END AS LeadSubStatus
	,Last_Updated
			
	FROM dbo.ProfLic P
	JOIN SectStat S
	ON P.SectStat = S.Code
	LEFT JOIN SectSubStatus SS
		ON P.SectStat = SS.SectStatusCode
		AND P.SectSubStatusID = SS.SectSubStatusID
	WHERE Apno = @apno
  --PR05      
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
       ,IsNull(DisclosedPastAction,0) as  DisclosedPastAction	
	     ,IsNull(LicenseTypeId,0) as LicenseTypeId  
  	--PR05
	,null AS MultiStateOption
	,null AS HasVerified
	,null AS LeadStatus -- license status or process status
	,null AS LeadSubStatus
	,null AS Last_Updated
    --PR05		    
  FROM       
   dbo.ProfLic l      
   inner join Appl a on l.APNO = a.APNO       
   Where a.SSN = @SSN and l.Apno <> @apno and @includeHistory =1    
 --Added by schapyala on 02/18/2013  
 and IsNull(IsOnReport,0) = 1 --only include records that were on past reports  
 and IsNull(IsHidden,0) = 0  --only include records that were not marked as unused  
 --)tbl  
   
 if (@lockAppl = 1)  
    begin  
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

	if (@IsReview = 1)  --dhe added on 04/16/2018
    begin 
		  update dbo.ProfLic  
		  set SectStat = 'H'
		  where apno = @apno and SectStat = '9' 
	end 
          
 -- -- Return results  
 -- select * from #tmpProfLic   
    
 -- --Drop table, we are done  
 -- drop table #tmpProfLic        
 --END  
END            
     
IF (@sectionOption = 'PersRef')  
  BEGIN  
 --   IF (SELECT COUNT(Apno) FROM dbo.PersRef WHERE Apno = @apno) > 0   
 --   BEGIN              
 --SELECT * into #tmpPersRef from   
 --(
 select     
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
 and IsNull(IsHidden,0) = 0   --only include records that were not marked as unused  
 --)tbl  

if (@lockAppl = 1)  
    begin
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
    if (@IsReview = 1)  --dhe added on 04/16/2018
    begin 
		  update dbo.PersRef  
		  set SectStat = 'H'
		  where apno = @apno and SectStat = '9' 
	end       
 -- -- Return results  
 -- select * from #tmpPersRef   
    
 -- --Drop table, we are done  
 -- drop table #tmpPersRef        
 --END  
END  
     
IF (@sectionOption = 'Credit')  
  BEGIN     
    --IF (SELECT COUNT(Apno) FROM dbo.Credit WHERE Apno = @apno) > 0               
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
		apno = @apno  and IsNull(IsHidden,0) = 0     
		--UNION ALL      
		--SELECT      
		--'Credit' as SectionName      
		--,'Previous' as RecordType      
		--,c.Apno   
		--,c.RepType as ReportType           
		--,IsNull(c.SectStat,'0') as SectStat  
		--,c.Report  
		--,c.PositiveIDReport as ReportXml         
		--FROM       
		--dbo.Credit c       
		--inner join Appl a on c.APNO = a.APNO       
		--Where a.SSN = @SSN and c.Apno <> @apno and @includeHistory =1   
		----Added by schapyala on 02/18/2013  
		--and IsNull(IsHidden,0) = 0   --only include records that were not marked as unused   
   END  
   
   
     
     
IF (@sectionOption = 'SanctionCheck')  
   BEGIN     
    --IF (SELECT COUNT(Apno) FROM dbo.Medinteg WHERE Apno = @apno) > 0               
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
		apno = @apno  and IsNull(IsHidden,0) = 0     
		--UNION ALL      
		--SELECT      
		--'SanctionCheck' as SectionName      
		--,'Current' as RecordType      
		--,m.Apno     
		--,IsNull(m.SectStat,'0') as SectStat       
		--,m.Report  
		--,IsNull(m.InUse,'') as InUse          
		--FROM       
		--dbo.Medinteg m      
		--inner join Appl a on m.APNO = a.APNO       
		--Where a.SSN = @SSN and m.Apno <> @apno and @includeHistory =1       
		----Added by schapyala on 02/18/2013  
		--and IsNull(IsHidden,0) = 0   --only include records that were not marked as unused   
   END  
    
IF (@sectionOption = 'MVR')  
   BEGIN     
    --IF (SELECT COUNT(Apno) FROM dbo.DL WHERE Apno = @apno) > 0               
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
		apno = @apno and IsNull(IsHidden,0) = 0     
		--UNION ALL      
		--SELECT      
		--'MVR' as SectionName      
		--,'Current' as RecordType      
		--,d.Apno     
		--,IsNull(d.SectStat,'0') as SectStat  
		--,d.Web_Status       
		--,d.Report  
		--,IsNull(d.InUse,'') as InUse            
		--FROM       
		--dbo.DL d      
		--inner join Appl a on d.APNO = a.APNO       
		--Where a.SSN = @SSN and d.Apno <> @apno and @includeHistory =1       
		----Added by schapyala on 02/18/2013  
		--and IsNull(IsHidden,0) = 0   --only include records that were not marked as unused   
   END  
   
IF (@sectionOption = 'PublicRecords') 
   BEGIN
    --IF (SELECT COUNT(Apno) FROM dbo.Crim WHERE Apno = @apno) > 0  
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
		  ,[CNTY_NO] as County_Number
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
		  ,IsNull([tobeworked],0) as ToBeWorked
		  ,Isnull([readytosend],0) as ReadyToSend
		  ,[NoteToVendor]
		  ,[test]
		  ,IsNull([InUse],'') as InUse
		  ,[parentCrimID]
		  ,[IrisFlag]
		  ,[IrisOrdered]
		  ,[Temporary]
		  ,[CreatedDate]
		  ,IsNull([IsCAMReview],0) as [IsCAMReview]
		  ,IsNull([IsHidden],0) as [IsHidden]
		  ,IsNull([IsHistoryRecord],0) as [IsHistoryRecord]
		  ,[AliasParentCrimID]
		  ,[InUseByIntegration]
		  ,[ClientAdjudicationStatus]
		  ,IsNull(AdmittedRecord,0) as AdmittedRecord
	  FROM [dbo].[Crim]
	  WHERE apno = @apno and IsNull(IsHidden,0) = 0

	   
   END
     
   set @flag = @flag + 1    
   
 END  
 END
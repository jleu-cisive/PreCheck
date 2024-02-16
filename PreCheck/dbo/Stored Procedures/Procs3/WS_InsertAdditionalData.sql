
  
--select value from fn_Split('Key:Value',':') where idx = 1  
--dbo.WS_InsertAdditionalData 2135,12121454,'321-11-1111','Release','Candidate_SelfDisclosed:1|SalaryRange:Test123 -   provided or applicant will not earn less than $20,000 or greater than $75,000|State_Employment_Occur:VT'  
--select * from dbo.ApplAdditionalData where clno =2135 apno = 2336405 or clno = 2135

--Select count(1) From dbo.ApplAdditionalData Where  (APNO = 2336405 )OR (CLNO = 2569 AND (SSN = '' AND ISNULL(SSN,'')<>'' )))

--delete ApplAdditionalData where  apno = 2336405
CREATE procedure [dbo].[WS_InsertAdditionalData]  
(@clno int,@apno int,@ssn varchar(11),@datasource varchar(10),@dataPoints varchar(max))   
as   
declare @count int  
declare @flag int  
declare @dataPoint varchar(max)  
declare @value varchar(300)  
declare @key varchar(100)  
declare @Candidate_SelfDisclosed bit, @SalaryRange varchar(3000),@State_Employment_Occur varchar(20)  
  
set @flag = 0   
set @count = (select count(*) from fn_Split(@dataPoints,'|'));  
while (@flag <= @count)  
BEGIN     
 set @dataPoint = (select value from fn_Split(@dataPoints,'|') where idx = @flag);  
 set @key = (select value from fn_Split(@dataPoint,':') where idx = 0);  
 set @value = (select value from fn_Split(@dataPoint,':') where idx = 1);  
   
   
 if (@key = 'Candidate_SelfDisclosed')   
 Set @Candidate_SelfDisclosed = cast(isnull(@value,0) as bit)  
   
 if (@key = 'SalaryRange')   
 Set @SalaryRange = @value  
   
 if (@key = 'State_Employment_Occur')   
 Set @State_Employment_Occur  = @value  
  
set @flag = @flag + 1  
  
END  

 --Declare @AppCount int, @RecCount int,
 Declare @ApplAddDataID int
  
 --Select @AppCount = count(1) From dbo.ApplAdditionalData Where  (APNO = @apno)

 --Select @RecCount = count(1) From dbo.ApplAdditionalData Where  (CLNO = @clno AND (SSN = @ssn AND ISNULL(SSN,'')<>'' ))

 select Top 1 @ApplAddDataID = ApplAdditionalDataID
 From dbo.ApplAdditionalData
 Where  (APNO = @apno OR (CLNO = @clno AND isnull(APNO, '') = '' AND (ISNULL(SSN,'Dummy') = ISNULL(@ssn,'') ) ) ) 
 Order By ApplAdditionalDataID desc


 --If (isnull(@AppCount,0) = 0 AND  isnull(@RecCount,0) =0)

 If @ApplAddDataID is null
  Insert into dbo.ApplAdditionalData(clno,apno,ssn,DataSource,Crim_SelfDisclosed,SalaryRange,StateEmploymentOccur)  
  values(@clno,@apno,@ssn,@dataSource,@Candidate_SelfDisclosed,@SalaryRange,@State_Employment_Occur)   
 else  
  update dbo.ApplAdditionalData  
  Set Crim_SelfDisclosed = @Candidate_SelfDisclosed, SalaryRange = @SalaryRange, StateEmploymentOccur = @State_Employment_Occur,  
  APNO = (Case When isnull(APNO,'') = '' then @apno else APNO end),  
  SSN = (Case When (isnull(SSN,'') = '' AND IsNull(@ssn,'') <> '') then @ssn else SSN end),  
  Dateupdated = current_timestamp  
  --,DataSource =  ISNULL(@dataSource,DataSource)
  Where ApplAdditionalDataID = @ApplAddDataID 
  --Where (APNO = @apno OR (CLNO = @clno AND (ISNULL(SSN,'Dummy') = ISNULL(@ssn,'') ) ) ) 
  



--[GetApplicantDetails] 2650752,174

--[GetApplicantDetails] null, 10816
/*
	Last Modify By: James Norton
	Modify Date: 7132021
	Modification Purpose: Project - Enhancement - Migration from eScreen to ZipCrim
*/
/*
	Last Modify By: Abhijit Awari
	Modify Date: 3rd Nov 2022
	Modification Purpose: HDT #67098 Consortium Error being Received
	Change: Addr_street varchar(50) to Addr_street varchar(100)
*/

CREATE PROCEDURE [dbo].[GetApplicantDetails]    
	@APNO as INT = NULL,
	@OCHS_ID INT = NULL	
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE  @OCHS_Details TABLE (APNO INT,Last varchar(100),First varchar(100), Email varchar(100),SSN varchar(11),ProdCat varchar(50),ProdClass varchar(50),SpecType varchar(50),Location varchar(50),
							  DOB Date,Addr_street varchar(100),Addr_Apt varchar(50),CITY varchar(50),STATE char(2),ZIP varchar(11),CLNO INT,Phone varchar(50),DeptCode varchar(20),TestReason varchar(50),Customer varchar(10)
							  ,DrugTestProvider varchar(20), ZipCrimClientID varchar(10))

DECLARE @CLNO int, @zipcrimcnt int,  @effDate datetime , @provider varchar(20) 

-- determine if ZIPCRIM
IF @APNO IS NOT NULL
   select @CLNO = a.CLNO from  dbo.OCHS_CandidateInfo a where a.APNO= @APNO
ELSE
	select @CLNO = a.CLNO from  dbo.OCHS_CandidateInfo a where a.OCHS_CandidateInfoID =@OCHS_ID
 
 
select @zipcrimcnt =count(*) from   dbo.ClientPackages cp  inner join dbo.packageMain p on p.packageId = cp.packageId 
 where cp.clno = @CLNO and  p.refPackageTypeID = 4 and ISNULL(cp.ZipCrimClientPackageID,'') <> ''


select @effDate =coalesce(Max([value]), dateadd(m,-1,getdate())) from [dbo].[ClientConfiguration]  where CLNO = 0 and ConfigurationKey = 'ZipCrimCutOverDate'

set @provider = 'Other'

if getdate() >= @effDate set @provider = 'Zipcrim'
Else if @zipcrimcnt > 0 set @provider = 'Zipcrim' 


IF @APNO IS NOT NULL	
	BEGIN
		Insert into @OCHS_Details
		Select Top 1 @APNO,
			   LastName,
			   FirstName,
			   a.EMAIL,
			   a.SSN,
			   ProdCat,
			   ProdClass,
			  -- Case CF.Value when 'ZipCrim' then cp.ZipCrimClientPackageID else ds.SpecType end as SpecType,
			   Case @provider when 'Zipcrim' then cp.ZipCrimClientPackageID else ds.SpecType end as SpecType,
			   Location,
			   DOB,
			   Address1,
			   Address2,
			   a.CITY,
			   a.STATE,
			   a.ZIP,
			   a.CLNO,
			   a.Phone,
			   '' DeptCode,
			   IsNull(TR.TestReasonCode,'Other') TestReason,
			   Customer,
			   --IsNull(CF.Value,'Other') DrugTestProvider,
			   @provider DrugTestProvider,
		  	   c.ZipCrimClientID
		  From dbo.OCHS_CandidateInfo A 
		 inner Join dbo.ClientConfiguration_DrugScreening DS ON A.ClientConfiguration_DrugScreeningID = DS.ClientConfiguration_DrugScreeningID
		 LEFT outer JOIN   dbo.ClientPackages cp  ON cp.clno = a.clno and cp.PackageID = DS.PackageID
  		 left join [dbo].[refTestReason] TR on A.TestReason = TR.TestReasonID
		 --left join [dbo].[ClientConfiguration] CF on CF.CLNO = a.CLNO and CF.ConfigurationKey = 'DrugTestOCHSProvider'
		 left join [dbo].[Client] c on c.CLNO = a.CLNO 

		Where  (A.APNO = @APNO)  AND a.IsActive = 1
		Order by OCHS_CandidateInfoID Desc


		IF (Select count(1) From @OCHS_Details)=0
			Insert into @OCHS_Details
			Select APNO,
				   LAST,
				   FIRST,
				   a.EMAIL,
				   SSN,
				   ProdCat,
				   ProdClass,
				  -- Case CF.Value when 'ZipCrim' then cp.ZipCrimClientPackageID else ds.SpecType end as SpecType,
				   Case @provider when 'ZipCrim' then cp.ZipCrimClientPackageID else ds.SpecType end as SpecType,
				   Location,
				   cast(DOB as Date),
				   Addr_street,
				   Addr_Apt,
				   a.CITY,
				   a.STATE,
				   a.ZIP,
				   a.CLNO,
				   a.Phone,
				   DeptCode,
				   'Other' TestReason,
				   null Customer,
			   --IsNull(CF.Value,'Other') DrugTestProvider,
			   @provider DrugTestProvider,
				   c.ZipCrimClientID
			  From dbo.Appl A 
			 Inner Join dbo.ClientConfiguration_DrugScreening DS ON A.CLNO = DS.CLNO
		     LEFT outer JOIN   dbo.ClientPackages cp  ON cp.clno = a.clno and cp.PackageID = DS.PackageID
			 --left join [dbo].[ClientConfiguration] CF on CF.CLNO = A.CLNO and CF.ConfigurationKey = 'DrugTestOCHSProvider'
	 		 left join [dbo].[Client] c on c.CLNO = a.CLNO 
			Where A.APNO = @APNO
	END
ELSE
	Insert into @OCHS_Details
	Select Top 1 @OCHS_ID,
		   LastName,
		   FirstName,
		   a.EMAIL,
		   SSN,
		   ProdCat,
		   ProdClass,
 			  -- Case CF.Value when 'ZipCrim' then cp.ZipCrimClientPackageID else ds.SpecType end as SpecType,
			   Case @provider when 'Zipcrim' then cp.ZipCrimClientPackageID else ds.SpecType end as SpecType,
		   Location,
		   DOB,
		   Address1,
		   Address2,
		   a.CITY,
		   a.STATE,
		   a.ZIP,
		   a.CLNO,
		   a.Phone,
		   '' DeptCode,
		   IsNull(TR.TestReasonCode,'Other') TestReason,
		   Customer,
			   --IsNull(CF.Value,'Other') DrugTestProvider,
			   @provider DrugTestProvider,
		   c.ZipCrimClientID
	  From dbo.OCHS_CandidateInfo A 
	 inner Join dbo.ClientConfiguration_DrugScreening DS ON A.ClientConfiguration_DrugScreeningID = DS.ClientConfiguration_DrugScreeningID
	 LEFT outer JOIN   dbo.ClientPackages cp  ON cp.clno = a.clno and cp.PackageID = DS.PackageID
	 left join [dbo].[refTestReason] TR on A.TestReason = TR.TestReasonID
	 --left join [dbo].[ClientConfiguration] CF on CF.CLNO = a.CLNO and CF.ConfigurationKey = 'DrugTestOCHSProvider'
	 left join [dbo].[Client] c on c.CLNO = a.CLNO 
	Where  OCHS_CandidateInfoID  = @OCHS_ID  AND a.IsActive = 1
	Order by OCHS_CandidateInfoID Desc

	IF (Select count(1) From @OCHS_Details)>0
		INSERT INTO [dbo].[OCHS_edrugVerifyLog]
				   ([APNO]
				   ,[OCHS_ID]
				   ,Last
				   ,Email			   
				   ,[LogDate],
				   SAML_PunchThrough)
		SELECT @APNO,@OCHS_ID,Last,Email,current_timestamp,1
		FROM @OCHS_Details
	

Select APNO,LAST,FIRST,EMAIL,SSN,ProdCat,ProdClass,SpecType,DOB,Addr_street,Addr_Apt,CITY,STATE,ZIP,CLNO,ZIP as LocateZipCode,
       IsNull(Customer,'201754') Customer,
	  Location, 
       'PRECHECK' AS PartnerUsername,
       '5' as SSNMasking,
       '' as SuccessURL,
		'escreen@precheck.com' as  UserEmail, -- this email is used to recive a confirmation from escreen
       'PreCheckUserID' as Username,
       'USA' as DonorCountry,
       'http://www.precheck.com/' as CancelURL,		
		Phone,
		DeptCode,
		TestReason,
		DrugTestProvider,
		ZipcrimClientID
From @OCHS_Details
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET NOCOUNT OFF
END


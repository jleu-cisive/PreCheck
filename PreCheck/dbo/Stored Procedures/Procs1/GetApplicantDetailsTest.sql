
--[GetApplicantDetails] 2650752,174

--[GetApplicantDetails] null,174

--[GetApplicantDetails] 10063,0


CREATE  PROCEDURE [dbo].[GetApplicantDetailsTest]    
	@APNO as INT = NULL,
	@OCHS_ID INT = NULL	
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE  @OCHS_Details TABLE (APNO INT,Last varchar(100),First varchar(100),Email varchar(100),SSN varchar(11),ProdCat varchar(50),ProdClass varchar(50),SpecType varchar(50),Location varchar(50),
							  DOB Date,Addr_street varchar(50),Addr_Apt varchar(50),CITY varchar(50),STATE char(2),ZIP varchar(11),CLNO INT,Phone varchar(50),DeptCode varchar(20),TestReason varchar(50),Customer varchar(10))

IF @APNO IS NOT NULL	
	BEGIN
		Insert into @OCHS_Details
		Select Top 1 @APNO,
			   LastName,
			   FirstName,
			   EMAIL,
			   SSN,
			   ProdCat,
			   ProdClass,
			   SpecType,
			   Location,
			   DOB,
			   Address1,
			   Address2,
			   CITY,
			   STATE,
			   ZIP,
			   a.CLNO,
			   Phone,
			   '' DeptCode,
			   IsNull(TR.TestReasonCode,'Other') TestReason,
			   Customer
		  From dbo.OCHS_CandidateInfo A 
		 inner Join dbo.ClientConfiguration_DrugScreening DS ON A.ClientConfiguration_DrugScreeningID = DS.ClientConfiguration_DrugScreeningID
		 left join [dbo].[refTestReason] TR on A.TestReason = TR.TestReasonID
		Where  (A.OCHS_CandidateInfoID = @APNO)  AND IsActive = 1
		Order by OCHS_CandidateInfoID Desc


		IF (Select count(1) From @OCHS_Details)=0
			Insert into @OCHS_Details
			Select APNO,
				   LAST,
				   FIRST,
				   EMAIL,
				   SSN,
				   ProdCat,
				   ProdClass,
				   SpecType,
				   Location,
				   cast(DOB as Date),
				   Addr_street,
				   Addr_Apt,
				   CITY,
				   STATE,
				   ZIP,
				   a.CLNO,
				   Phone,
				   DeptCode,
				   'Other' TestReason,
				   null Customer
			  From dbo.Appl A 
			 Inner Join dbo.ClientConfiguration_DrugScreening DS ON A.CLNO = DS.CLNO
			Where A.APNO = @APNO
	END
ELSE
	Insert into @OCHS_Details
	Select Top 1 @OCHS_ID,
		   LastName,
		   FirstName,
		   EMAIL,
		   SSN,
		   ProdCat,
		   ProdClass,
		   SpecType,
		   Location,
		   DOB,
		   Address1,
		   Address2,
		   CITY,
		   STATE,
		   ZIP,
		   a.CLNO,
		   Phone,
		   '' DeptCode,
		   IsNull(TR.TestReasonCode,'Other') TestReason,
		   Customer
	  From dbo.OCHS_CandidateInfo A 
	 inner Join dbo.ClientConfiguration_DrugScreening DS ON A.ClientConfiguration_DrugScreeningID = DS.ClientConfiguration_DrugScreeningID
	 left join [dbo].[refTestReason] TR on A.TestReason = TR.TestReasonID
	Where  OCHS_CandidateInfoID  = @OCHS_ID  AND IsActive = 1
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
		TestReason
From @OCHS_Details


SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET NOCOUNT OFF
END













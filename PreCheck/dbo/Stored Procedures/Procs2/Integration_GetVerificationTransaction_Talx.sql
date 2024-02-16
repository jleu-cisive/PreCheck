



--[dbo].[Integration_GetVerificationTransaction_Test] '992-88-0002', 3993266, 'False Employer',null, 'Employment',3




CREATE procedure [dbo].[Integration_GetVerificationTransaction_Talx]
(		
	@ssn varchar(11),
	@apno int = null,		
	@verificationCodeName varchar(500),	
	@verificationCodeId varchar(50) = null,
	@verificationCodeIdType varchar(30) = null,
	@vendorId int = 0
)
as 


select top 1 ResponseXML,
			VerifiedDate,
			CreatedBy,
			IsNull(IsPresent,0) AS IsPresent,
			IsFoundEmployerCode,
			AliasLogicStatus,
			VerificationCodeId
from Integration_Verification_Transaction (nolock)
where replace(SSN,'-','') = replace(@ssn,'-','') 
and (APNO= @apno OR @apno IS NULL)
and (IsComplete = 1 and ResponseXML is not null)
--and IsComplete = 1
and VerificationCodeIdType = @verificationCodeIdType
and IsNull(VendorId,0) = @VendorId
and VerificationCodeId = Case when isnull(vendorID,0) = 3 then VerificationCodeId else @verificationCodeId END --modified by schapyala to search by verificationcode for NCH and others. TALX is excluded from this logic as results are for SSN
and CreatedDate between  DATEADD(year,-1,getdate()) and getdate()
order by CreatedDate desc

--select @responseXml ,
--			@dateVerified ,
--			@verifier,
--			@IsPresent







--[dbo].[Integration_GetVerificationTransaction] '252-27-9108', 4141258, null, '','','', 'Employment', '', 1,3




CREATE procedure [dbo].[Integration_GetVerificationTransaction]
(		
	@ssn varchar(11),
	@apno int = null,		
	@verificationCodeName varchar(500),
	@dateVerified datetime output,
	@verifier varchar(50) = null output,
	@verificationCodeId varchar(50) = null output,
	@verificationCodeIdType varchar(30) = null,
	@responseXml xml output,
	@IsPresent bit = null output,
	@vendorId int = 0
)
as 
SET NOCOUNT ON

if (@verificationCodeName is not null and @verificationCodeId is null) 
Begin
	select top 1 @verificationCodeId = verificationCodeId from dbo.Integration_Verification_Transaction (nolock) where VerificationCodeName = @verificationCodeName
	if (@verificationCodeId is null)
		return
END


select top 1 @responseXml = ResponseXML,
			@dateVerified = VerifiedDate,
			@verifier = CreatedBy,
			@IsPresent = IsNull(IsPresent,0),
			@verificationCodeId = VerificationCodeId
from Integration_Verification_Transaction (nolock)
where replace(SSN,'-','') = replace(@ssn,'-','') 
and (APNO= @apno OR @apno IS NULL)
and IsComplete = 1 
and VerificationCodeIdType = @verificationCodeIdType
and IsNull(VendorId,0) = @VendorId
and VerificationCodeId = Case when isnull(vendorID,0) = 3 then VerificationCodeId else @verificationCodeId END --modified by schapyala to search by verificationcode for NCH and others. TALX is excluded from this logic as results are for SSN
order by CreatedDate desc

SET NOCOUNT OFF
--select @responseXml ,
--			@dateVerified ,
--			@verifier,
--			@IsPresent


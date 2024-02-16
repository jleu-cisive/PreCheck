



Create procedure [dbo].[Integration_GetVerificationTransaction_7112012]
(	
	@ssn varchar(11),		
	@verificationCodeName varchar(500),
	@dateVerified datetime output,
	@verifier varchar(50) = null output,
	@verificationCodeIdType varchar(30) = null,
	@verificationCodeId varchar(50)output,
	@responseXml xml output
)
as 


if (@verificationCodeName is not null and @verificationCodeId is null) 
Begin
	select top 1 @verificationCodeId = verificationCodeId from dbo.Integration_Verification_Transaction where VerificationCodeName = @verificationCodeName
	if (@verificationCodeId is null)
		return
END


select top 1 @responseXml = ResponseXML,
			@dateVerified = VerifiedDate,
			@verifier = CreatedBy
from Integration_Verification_Transaction 
where replace(SSN,'-','') = replace(@ssn,'-','')
--where SSN = @ssn 
and VerificationCodeId = @verificationCodeId 
and IsComplete = 1 and IsInternalVerification = 0 
and VerificationCodeIdType = @verificationCodeIdType 
order by CreatedDate desc













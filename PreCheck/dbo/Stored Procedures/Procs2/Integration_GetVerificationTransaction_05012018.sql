


--[dbo].[Integration_GetVerificationTransaction] '471-08-8069', '', '', '', 'Employment', '11156', '', 0




CREATE procedure [dbo].[Integration_GetVerificationTransaction_05012018]
(	
	@ssn varchar(11),		
	@verificationCodeName varchar(500),
	@dateVerified datetime output,
	@verifier varchar(50) = null output,
	@verificationCodeIdType varchar(30) = null,
	@verificationCodeId varchar(50)output,
	@responseXml xml output,
	@IsPresent bit = null output,
	@vendorId int = 0
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
			@verifier = CreatedBy,
			@IsPresent = IsNull(IsPresent,0)

from Integration_Verification_Transaction 
where replace(SSN,'-','') = replace(@ssn,'-','')
and VerificationCodeId = @verificationCodeId 
and IsComplete = 1 and IsInternalVerification = 0 
and VerificationCodeIdType = @verificationCodeIdType
and IsNull(VendorId,0) = @VendorId
and IsNull(IsPresent,0) = 0 
order by VerficationTransactionId desc

--select @responseXml ,
--			@dateVerified ,
--			@verifier,
--			@IsPresent

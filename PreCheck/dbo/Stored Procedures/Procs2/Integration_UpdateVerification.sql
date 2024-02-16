





CREATE procedure [dbo].[Integration_UpdateVerification]
(
	@verificationTransactionId int,@responseXml xml = null,@ErrorDetails varchar(2000) = null,@iscomplete bit = 0,@verificationCodeName varchar(500),@IsInternalVerification bit,@VerificationOperation varchar(200) = null,@verifier varchar(50) = null,@IsPresent bit = 0,@isFoundEmployerCode bit = 0,@CodeStatus varchar(2) = null
)
as 

--if (@responseXml is null)
update Integration_Verification_Transaction
	set ErrorDetails = @ErrorDetails,
		ResponseXML = @responseXml,--IsNull(@responseXml,'')
		verifiedDate = CURRENT_TIMESTAMP,
		IsPresent = @IsPresent,	
		IsComplete = @iscomplete,
		IsInternalVerification = @IsInternalVerification,
		VerificationOperation = @VerificationOperation,		
		VerificationCodeName = @verificationCodeName,
		CreatedBy = @verifier,
		IsFoundEmployerCode	= @isFoundEmployerCode,	
		CodeStatus = @CodeStatus		
where VerficationTransactionId = @verificationTransactionId









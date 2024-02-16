




create procedure [dbo].[Integration_UpdateVerification_1272015]
(
	@verificationTransactionId int,@responseXml xml = null,@ErrorDetails varchar(2000) = null,@iscomplete bit = 0,@verificationCodeName varchar(500),@IsInternalVerification bit,@VerificationOperation varchar(200) = null,@verifier varchar(50) = null
)
as 

if (@responseXml is null)
update Integration_Verification_Transaction
	set ErrorDetails = @ErrorDetails,
		verifiedDate = CURRENT_TIMESTAMP,
		IsInternalVerification = @IsInternalVerification,
		VerificationOperation = @VerificationOperation,
		iscomplete = 0,
		VerificationCodeName = @verificationCodeName
		,
		CreatedBy = @verifier
where VerficationTransactionId = @verificationTransactionId
else


update Integration_Verification_Transaction
	set responsexml = @responsexml,
		verifiedDate = CURRENT_TIMESTAMP,
		IsInternalVerification = @IsInternalVerification,
		VerificationOperation = @VerificationOperation,
		iscomplete = @iscomplete,
		VerificationCodeName = @verificationCodeName
		,
		CreatedBy = @verifier		
where VerficationTransactionId = @verificationTransactionId












CREATE procedure [dbo].[Integration_InsertVerification_05012018]
(
	@verificationCodeId varchar(50),@verificationCodeType varchar(30),@SSN varchar(11),@DOB varchar(30),@requestXml xml = null,@createdBy varchar(30),@verificationDbId int,@vendorId int = null
	--@APNO int,@verificationCodeId varchar(50),@verificationCodeType varchar(30),@requestXml xml = null,@createdBy varchar(30),@verificationDbId int
)
as 
declare @tranid int

if (@vendorId is null)
Insert into Integration_Verification_Transaction(VerificationCodeId,VerificationCodeIdType,VerificationDbId,CreatedDate,CreatedBy,RequestXml,SSN,DOB,IsComplete)
values (@verificationCodeId,@verificationCodeType,@verificationDbId,current_timestamp,@createdBy,@requestXml,@SSN,@DOB,0)

else

Insert into Integration_Verification_Transaction(VerificationCodeId,VerificationCodeIdType,VerificationDbId,CreatedDate,CreatedBy,RequestXml,SSN,DOB,IsComplete,VendorId)
values (@verificationCodeId,@verificationCodeType,@verificationDbId,current_timestamp,@createdBy,@requestXml,@SSN,@DOB,0,@vendorId)


set @tranid = CAST(SCOPE_IDENTITY() as INT)
select @tranid






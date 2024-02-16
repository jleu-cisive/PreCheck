
Create Proc dbo.sp_FormAdverseContactAdd
(@AAID int,
 @UserID char(10),
 @APNO int,
 @ApplicantName nvarchar(50),
 @ApplicantHPhone nvarchar(15),
 @ApplicantCPhone nvarchar(15),
 @ApplicantWPhone nvarchar(15),
 @ApplicantEmail nvarchar(50),
 @CLNO int,
 @ContactName nvarchar(50),
 @ContactPhone nvarchar(15),
 @ContactPhoneExt char(4),
 @ContactEmail nvarchar(50),
 @ACMID int,
 @ASID int,
 @Comments text,
 @ContactDate smalldatetime
 )
As
Declare @ErrorCode int
Declare @AdverseContactLogID int 

Begin Transaction
Set @ErrorCode=@@Error
Insert AdverseContactLog_Test_JC                       
       Values(@AAID,@UserID,@APNO,@ApplicantName,@ApplicantHPhone,@ApplicantCPhone,@ApplicantWPhone,@ApplicantEmail,
              @CLNO,@ContactName,@ContactPhone,@ContactPhoneExt,@ContactEmail,@ACMID,@ASID,@Comments,@ContactDate)
Select @AdverseContactLogID=@@Identity
           
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  --Return (0)
  Return (@@Identity)


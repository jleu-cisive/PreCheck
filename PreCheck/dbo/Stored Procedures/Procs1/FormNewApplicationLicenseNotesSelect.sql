CREATE Proc [dbo].[FormNewApplicationLicenseNotesSelect]
@clno int
as
declare @ErrorCode int

Begin Transaction
Set @ErrorCode=@@Error

select aa.licensenotes from reflicensenotes aa  inner join 
client bb on aa.licensenotesid = bb.licensenotesid where bb.clno = @clno
   

Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
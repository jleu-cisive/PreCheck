CREATE Proc dbo.FormNewApplicationCreditSocialSelect
as
declare @ErrorCode int

Begin Transaction
Set @ErrorCode=@@Error

select * from credit   

Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
CREATE Proc dbo.FormNewApplicationTeamSelect
@clno int
as
declare @ErrorCode int

Begin Transaction
Set @ErrorCode=@@Error

select cam as team from client where clno= @clno
   

Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
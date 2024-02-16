CREATE Proc dbo.FormNewApplicationClientMVRETCSelect
@clno int
as
declare @ErrorCode int

Begin Transaction
Set @ErrorCode=@@Error

select social, MVR, creditnotesid, [Medicaid/Medicare] from client
where clno = @clno
   

Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
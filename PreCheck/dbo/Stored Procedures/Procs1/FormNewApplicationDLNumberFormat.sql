CREATE Proc dbo.FormNewApplicationDLNumberFormat
@state varchar(2)
as
declare @ErrorCode int

Begin Transaction
Set @ErrorCode=@@Error

select mask
  from DLFormat
 where state=@state 
   

Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
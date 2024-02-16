CREATE Proc dbo.FormNewApplicationClientAttention
@clno int
as
declare @ErrorCode int

Begin Transaction
Set @ErrorCode=@@Error

select LastName + ',' + FirstName as name
  from clientcontacts
 where clno=@clno and LastName is not null order by name
   

Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
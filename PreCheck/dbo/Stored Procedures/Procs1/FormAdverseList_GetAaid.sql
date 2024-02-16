
Create Proc dbo.FormAdverseList_GetAaid
@apno int
As
Declare @ErrorCode int
declare @aaid int

set @aaid=(select adverseactionid from adverseaction where apno=@apno)

Begin Transaction
Set @ErrorCode=@@Error


If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  Return (@aaid)



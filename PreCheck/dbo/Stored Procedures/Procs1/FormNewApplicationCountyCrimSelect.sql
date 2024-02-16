CREATE Proc [dbo].[FormNewApplicationCountyCrimSelect]
@clno int
as
declare @ErrorCode int

Begin Transaction
Set @ErrorCode=@@Error

select aa.countycrim from refcountycrim aa inner join 
client bb on aa.countycrimid = bb.countycrimid where bb.clno = @clno
   

Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
CREATE Proc [dbo].[FormNewApplicationCountyCrimNotesSelect]
@clno int
as
declare @ErrorCode int

Begin Transaction
Set @ErrorCode=@@Error

select aa.countycrimnotes from refcountycrimnotes aa inner join
client bb on aa.countycrimnotesid = bb.countycrimnotesid where bb.clno = @clno
   

Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
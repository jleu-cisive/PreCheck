CREATE Proc [dbo].[FormNewApplicationStateCrimNotesSelect]
@clno int
as
declare @ErrorCode int

Begin Transaction
Set @ErrorCode=@@Error

select aa.statecrimnotes from refstatecrimnotes aa inner join 
client bb on aa.statecrimnotesid = bb.statecrimnotesid where bb.clno = @clno
   

Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
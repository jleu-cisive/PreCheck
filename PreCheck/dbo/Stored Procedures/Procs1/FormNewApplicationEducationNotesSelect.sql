CREATE Proc [dbo].[FormNewApplicationEducationNotesSelect]
@clno int
as
declare @ErrorCode int

Begin Transaction
Set @ErrorCode=@@Error

select aa.educationnotes from refeducationnotes aa inner join 
client bb on aa.educationnotesid = bb.educationnotesid where bb.clno = @clno

Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
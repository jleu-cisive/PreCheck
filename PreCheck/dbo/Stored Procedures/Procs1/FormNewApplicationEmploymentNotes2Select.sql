CREATE Proc [dbo].[FormNewApplicationEmploymentNotes2Select]
@clno int
as
declare @ErrorCode int

Begin Transaction
Set @ErrorCode=@@Error

select aa.employmentnotes from refemploymentnotes aa inner join 
client bb on aa.employmentnotesid = bb.employmentnotes2id where bb.clno = @clno
   

Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
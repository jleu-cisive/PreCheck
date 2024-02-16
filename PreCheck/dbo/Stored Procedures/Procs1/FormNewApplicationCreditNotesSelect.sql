CREATE Proc [dbo].[FormNewApplicationCreditNotesSelect]
@clno int
as
declare @ErrorCode int

Begin Transaction
Set @ErrorCode=@@Error

select aa.creditnotes from refcreditnotes aa inner join
client bb on aa.creditnotesid = bb.creditnotesid where bb.clno = @clno
   

Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
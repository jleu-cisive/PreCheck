CREATE Proc [dbo].[FormNewApplicationEmploymentSelect]
@clno int
as
declare @ErrorCode int

Begin Transaction
Set @ErrorCode=@@Error

select aa.employment from refemployment aa inner join client bb on aa.employmentid = bb.employmentid where bb.clno = @clno
   

Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
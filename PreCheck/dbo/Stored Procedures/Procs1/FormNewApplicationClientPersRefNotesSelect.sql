CREATE Proc dbo.FormNewApplicationClientPersRefNotesSelect
@clno int
As
Declare @ErrorCode int

Begin Transaction
SELECT PersonalRefNotes
  FROM client
 WHERE clno=@clno
            
Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
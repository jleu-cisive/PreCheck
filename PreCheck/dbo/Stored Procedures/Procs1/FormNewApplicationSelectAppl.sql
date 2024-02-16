CREATE Proc dbo.FormNewApplicationSelectAppl
@clno int
As
Declare @ErrorCode int

Begin Transaction
SELECT  Last, First, apdate, clno
  FROM Appl 
 WHERE clno=@clno
            
Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
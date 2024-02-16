CREATE Proc dbo.FormNewApplicationStateList
as 
declare @ErrorCode int

begin transaction
set @ErrorCode=@@Error

select State from (SELECT '' State 
UNION ALL SELECT State FROM dbo.State)Qry order by State;
 
                            

If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
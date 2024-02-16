CREATE Proc dbo.FormNewApplicationPersRefSelect
@apno int
as 

declare @ErrorCode int

begin transaction
set @ErrorCode=@@Error

select * from PersRef where apno=@apno order by PersRefID;
 
                            

If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
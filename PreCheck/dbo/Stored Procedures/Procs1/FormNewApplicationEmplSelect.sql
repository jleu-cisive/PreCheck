CREATE Proc dbo.FormNewApplicationEmplSelect
@apno int
as 

declare @ErrorCode int

begin transaction
set @ErrorCode=@@Error

select * from Empl where apno=@apno order by EmplID;
 
                            

If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
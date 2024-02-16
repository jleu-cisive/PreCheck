CREATE Proc dbo.FormNewApplicationProfLicSelect
@apno int
as 

declare @ErrorCode int

begin transaction
set @ErrorCode=@@Error

select * from ProfLic where apno=@apno order by ProfLicID;
 
                            

If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
CREATE Proc dbo.FormNewApplicationEducatSelect
@apno int
as 

declare @ErrorCode int

begin transaction
set @ErrorCode=@@Error

select * from Educat where apno=@apno order by EducatID;
 
                            

If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
CREATE Proc dbo.FormNewApplicationInsertAppl
@apdate datetime,
@Last  varchar(20),
@First varchar(20),
@clno smallint
As
Declare @ErrorCode int
Declare @apno int

Begin Transaction
--insert into appl table
insert appl (apdate, [Last], [First], clno)
values(@apdate, @Last, @First, @clno)
Select @apno=@@Identity

            
Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  Return (@apno)
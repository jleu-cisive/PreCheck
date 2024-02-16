CREATE Proc [dbo].[FormNewApplicationZipCityState]
@zip  int
as 
declare @ErrorCode int

begin transaction
set @ErrorCode=@@Error

select top 1 city, state from MainDB.dbo.ZipCode where zip = @zip;

If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
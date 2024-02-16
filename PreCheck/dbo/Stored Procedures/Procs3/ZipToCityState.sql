CREATE PROCEDURE ZipToCityState
  @Zip char(5),
  @City varchar(25) OUTPUT,
  @State varchar(2) OUTPUT
as
  set nocount on
  select @City = City, @State = State from ZipCode where Zip = @Zip

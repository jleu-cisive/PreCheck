CREATE PROCEDURE InsertZipCode
  @Zip char(5),
  @City varchar(25),
  @State char(2)
as
  set nocount on
  insert into ZipCode (Zip, City, State)
  values (@Zip, @City, @State)

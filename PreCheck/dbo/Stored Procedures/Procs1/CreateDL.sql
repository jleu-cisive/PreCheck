CREATE PROCEDURE CreateDL
  @Apno int
as
  set nocount on
  insert into DL (Apno) values (@Apno)

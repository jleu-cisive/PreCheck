CREATE PROCEDURE DeleteAppl
  @Apno int
as
  set nocount on
  delete from Appl where Apno = @Apno

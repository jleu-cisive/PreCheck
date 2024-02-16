CREATE PROCEDURE DeleteApplCrim
  @Apno int
as
  set nocount on
  delete from Crim where Apno = @Apno

CREATE PROCEDURE DeleteApplEmpl
  @Apno int
as
  set nocount on
  delete from Empl where Apno = @Apno

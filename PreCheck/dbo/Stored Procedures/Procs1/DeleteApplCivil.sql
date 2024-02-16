CREATE PROCEDURE DeleteApplCivil
  @Apno int
as
  set nocount on
  delete from Civil where Apno = @Apno

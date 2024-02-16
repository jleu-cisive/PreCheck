CREATE PROCEDURE DeleteApplCredit
  @Apno int
as
  set nocount on
  delete from Credit where Apno = @Apno

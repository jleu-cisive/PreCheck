CREATE PROCEDURE DeleteApplDL
  @Apno int
as
  set nocount on
  delete from DL where Apno = @Apno

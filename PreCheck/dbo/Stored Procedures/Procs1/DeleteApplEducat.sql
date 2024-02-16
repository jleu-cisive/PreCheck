CREATE PROCEDURE DeleteApplEducat
  @Apno int
as
  set nocount on
  delete from Educat where Apno = @Apno

CREATE PROCEDURE DeleteApplPersRef
  @Apno int
as
  set nocount on
  delete from PersRef where Apno = @Apno

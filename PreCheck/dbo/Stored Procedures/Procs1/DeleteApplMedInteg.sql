CREATE PROCEDURE DeleteApplMedInteg
  @Apno int
as
  set nocount on
  delete from MedInteg where Apno = @Apno

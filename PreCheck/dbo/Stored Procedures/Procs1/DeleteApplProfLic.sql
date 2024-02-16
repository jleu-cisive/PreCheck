CREATE PROCEDURE DeleteApplProfLic
  @Apno int
as 
  set nocount on
  delete from ProfLic where Apno = @Apno

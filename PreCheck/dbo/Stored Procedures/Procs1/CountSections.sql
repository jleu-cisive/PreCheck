CREATE PROCEDURE CountSections
  @Apno int,
  @Empl smallint OUTPUT,
  @Educat smallint OUTPUT,
  @ProfLic smallint OUTPUT,
  @PersRef smallint OUTPUT
as
  set nocount on
  select @Empl = count(*) from Empl where Apno = @Apno
  select @Educat = count(*) from Educat where Apno = @Apno
  select @ProfLic = count(*) from ProfLic where Apno = @Apno
  select @PersRef = count(*) from PersRef where Apno = @Apno

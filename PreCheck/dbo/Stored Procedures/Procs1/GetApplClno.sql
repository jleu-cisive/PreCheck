CREATE PROCEDURE GetApplClno
  @Apno int,
  @Clno smallint OUTPUT
as
  set nocount on
  select @Clno = Clno from Appl where Apno = @Apno

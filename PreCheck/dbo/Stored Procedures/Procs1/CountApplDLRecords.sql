CREATE PROCEDURE CountApplDLRecords
  @Apno int,
  @Count smallint OUTPUT
as
  set nocount on
  select @Count = count(*) from DL where Apno = @Apno

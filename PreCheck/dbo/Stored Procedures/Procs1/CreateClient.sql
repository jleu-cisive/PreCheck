CREATE PROCEDURE CreateClient
  @CLNO smallint OUTPUT
as
  set nocount on
  insert into Client (Status, BillCycle) values ('N', 'A')
  select @CLNO = @@Identity
  

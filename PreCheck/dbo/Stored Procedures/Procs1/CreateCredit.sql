CREATE PROCEDURE CreateCredit
  @Apno int,
  @Vendor char(1),
  @RepType char(1),
  @Qued bit
as
  set nocount on
  insert into Credit (Apno, Vendor, RepType, Qued)
  values (@Apno, @Vendor, @RepType, @Qued)

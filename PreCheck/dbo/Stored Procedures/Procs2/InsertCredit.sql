CREATE PROCEDURE InsertCredit
  @Apno int,
  @Vendor char(1),
  @RepType char(1),
  @Qued bit,
  @Pulled bit,
  @SectStat char(1),
  @Report text
as
  set nocount on
  insert into Credit
    (Apno, Vendor, RepType, Qued, Pulled, SectStat, Report)
  values
    (@Apno, @Vendor, @RepType, @Qued, @Pulled, @SectStat, @Report)

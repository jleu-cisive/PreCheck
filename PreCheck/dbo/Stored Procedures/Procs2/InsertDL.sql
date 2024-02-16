CREATE PROCEDURE InsertDL
  @Apno int,
  @Ordered varchar(14),
  @SectStat char(1),
  @Report text
as
  set nocount on
  insert into DL
    (Apno, Ordered, SectStat, Report)
  values
    (@Apno, @Ordered, @SectStat, @Report)

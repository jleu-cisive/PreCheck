CREATE PROCEDURE InsertMedInteg
  @apno int,
  @sectstat char(1),
  @report text
as
  set nocount on
  insert into medinteg
    (apno, sectstat, report)
  values
    (@apno, @sectstat, @report)

CREATE PROCEDURE InsertTUQ
  @apno int,
  @reptype char(1),
  @name varchar(30),
  @pulled bit,
  @report text,
  @comments varchar(30)
as
  set nocount on
  insert into TUQ
    (apno, reptype, name, pulled, report, comments)
  values
    (@apno, @reptype, @name, @pulled, @report, @comments)

CREATE PROCEDURE InsertSectStat
  @Code char(1),
  @Description varchar(25)
as
  set nocount on
  insert into sectstat
    (code, description)
  values
    (@code, @description)

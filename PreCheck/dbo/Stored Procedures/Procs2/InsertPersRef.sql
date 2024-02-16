CREATE PROCEDURE InsertPersRef
  @persrefid int,
  @apno int,
  @sectstat char(1),
  @worksheet bit,
  @name varchar(25),
  @phone varchar(20),
  @rel_v varchar(20),
  @years_v smallint,
  @priv_notes text,
  @pub_notes text
as
  set nocount on
  insert into persref
    (persrefid, apno, sectstat, worksheet, name,
      phone, rel_v, years_v, priv_notes, pub_notes)
  values
    (@persrefid, @apno, @sectstat, @worksheet, @name,
      @phone, @rel_v, @years_v, @priv_notes, @pub_notes)

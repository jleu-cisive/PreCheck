CREATE PROCEDURE dbo.DeleteApplStudentAction
  @Apno varchar(8000),
  @CLNO_Hospital varchar (8000),
  @StudentActionID int
	
as
--
DELETE from ApplStudentAction
Where  cast(Apno as varchar) + cast(ClNO_Hospital as varchar)
in (Select (B.Value + A.Value) FROM dbo.fn_Split(@CLNO_Hospital,',') A cross join dbo.fn_Split(@Apno,',') B)
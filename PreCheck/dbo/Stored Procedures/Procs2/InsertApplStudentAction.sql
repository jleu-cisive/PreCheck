
CREATE PROCEDURE [dbo].[InsertApplStudentAction]
  @Apno varchar(8000),
  @CLNO_Hospital varchar (8000),
  @StudentActionID int
	
as
--Modified by Santosh on 01/22/07 - Added the where clause to the subquery...fix for timeout issue
--Only inserts hospitals for the Apps selected if they are not already in the ApplStudentAction table
INSERT INTO ApplStudentAction
(APNO,CLNO_Hospital,StudentActionID)
 SELECT B.Value,A.Value,0 FROM dbo.fn_Split(@CLNO_Hospital,',') A cross join dbo.fn_Split(@Apno,',') B
WHERE (B.Value + A.Value) not in 
(Select cast(Apno as varchar) + cast(ClNO_Hospital as varchar) 
 From ApplStudentAction 
--Added the where clause to filter out the rows - 01/22/07 - schapyala
 Where apno in (select value from dbo.fn_Split(@Apno,',')))


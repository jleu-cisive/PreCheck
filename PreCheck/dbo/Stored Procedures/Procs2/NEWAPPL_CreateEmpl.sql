CREATE PROCEDURE NEWAPPL_CreateEmpl
	@Apno int,
	@Employer varchar(30),
	@Phone varchar(20),
	@Position_A varchar(25),
	@From_A varchar(8),
	@To_A varchar(8),
	@DNC bit,
	@SpecialQ bit,
	@Supervisor varchar(25),
	@Salary_A varchar(15),
	@Ver_Salary bit,
	@RFL varchar(30),
	@Dept varchar(30),
	@Location varchar(30),
	@Priv_Notes text,
	@EmplID int OUTPUT
AS
	SET NOCOUNT ON


DECLARE @SectStat char(1)
--IF IsDate(@To_A) = 1    --isdate means old employment, mark it already reviewd
--  SET @SectStat = '9'   --goes straight to be worked
--ELSE
--  SET @SectStat = '0'   --current empl, needs to be reviewed 1st

--IF IsDate(@To_A) = 1    --isdate means old employment, mark it already reviewd
--  SET @SectStat = '9'   --goes straight to be worked
--ELSE begin   -- might be mm/yy which fails the IsDate() test
--  IF ((Len(@To_A) = 5) AND (IsNumeric(Substring(@To_A,1,2) )) = 1) 
--    SET @SectStat = '9'   --goes straight to be worked
--  ELSE
--    SET @SectStat = '0'   --current empl, needs to be reviewed 1st
--end

SET @SectStat = '0'   --DEFAULT VALUE = current empl, needs to be reviewed 1st (NOW OR PRESENT)
IF IsNumeric(Substring(@To_A,1,1) ) = 1     -- any date 01 OR 12/01 OR 1/12/2001
  SET @SectStat = '9'   --goes straight to be worked

	INSERT INTO Empl
		(Apno, Employer, Phone, Position_A, From_A, To_A, DNC, SpecialQ,
		Supervisor, Salary_A, Ver_Salary, RFL, Dept, Location, Priv_Notes,SectStat)
	VALUES
		(@Apno, @Employer, @Phone, @Position_A, @From_A, @To_A, @DNC, @SpecialQ,
		@Supervisor, @Salary_A, @Ver_Salary, @RFL, @Dept, @Location, @Priv_Notes,@SectStat)
	SELECT @EmplID = @@IDENTITY
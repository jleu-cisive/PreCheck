CREATE PROCEDURE NEWAPPL_RetrieveEmpl
	@EmplID int
AS
	SELECT EmplID, Apno, Employer, Phone, Position_A, From_A, To_A, DNC,
		SpecialQ, Supervisor, Salary_A, Ver_Salary, RFL, Dept, Location,
		Priv_Notes
	FROM Empl
	WHERE EmplID = @EmplID

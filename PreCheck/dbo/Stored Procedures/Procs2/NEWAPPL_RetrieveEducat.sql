CREATE PROCEDURE NEWAPPL_RetrieveEducat
	@EducatID int
AS
	SELECT EducatID, Apno, School, State, Phone, Degree_A, Studies_A, From_A, To_A
	FROM Educat
	WHERE EducatID = @EducatID
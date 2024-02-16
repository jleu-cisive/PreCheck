CREATE PROCEDURE NEWAPPL_CreateEducat
	@Apno int,
	@School varchar(25),
	@State varchar(2),
	@Phone varchar(20),
	@Degree_A varchar(25),
	@Studies_A varchar(25),
	@From_A varchar(8),
	@To_A varchar(8),
	@EducatID int OUTPUT
AS
	SET NOCOUNT ON
	INSERT INTO Educat
		(Apno, School, State, Phone, Degree_A, Studies_A, From_A, To_A)
	VALUES
		(@Apno, @School, @State, @Phone, @Degree_A, @Studies_A, @From_A, @To_A)
	SELECT @EducatID = @@IDENTITY

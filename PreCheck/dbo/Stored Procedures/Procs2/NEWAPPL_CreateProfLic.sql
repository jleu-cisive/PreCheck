CREATE PROCEDURE NEWAPPL_CreateProfLic
	@Apno int,
	@Lic_Type varchar(30),
	@State varchar(8),
	@Year varchar(4),
	@Expire datetime,
	@Lic_No varchar(12),
	@ProfLicID int OUTPUT
AS
	SET NOCOUNT ON
	INSERT INTO ProfLic
		(Apno, Lic_Type, State, [Year], Expire, Lic_No)
	VALUES
		(@Apno, @Lic_Type, @State, @Year, @Expire, @Lic_No)
	SELECT @ProfLicID = @@IDENTITY

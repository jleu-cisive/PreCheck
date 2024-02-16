CREATE PROCEDURE NEWAPPL_CreatePersRef
	@Apno int,
	@Name varchar(25),
	@Phone varchar(20),
	@Rel_V varchar(20),
	@Years_V smallint,
	@PersRefID int OUTPUT
AS
	SET NOCOUNT ON
	INSERT INTO PersRef
		(Apno, [Name], Phone, Rel_V, Years_V)
	VALUES
		(@Apno, @Name, @Phone, @Rel_V, @Years_V)
	SELECT @PersRefID = @@IDENTITY

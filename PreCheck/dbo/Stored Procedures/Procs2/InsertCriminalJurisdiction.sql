CREATE PROCEDURE InsertCriminalJurisdiction
	@CrimJName varchar(30),
	@SearchSourceID tinyint,
	@DefaultRate smallmoney,
	@Enabled bit,
	@LastModifiedUser varchar(30),
	@CrimJID int OUTPUT
AS
	INSERT INTO CriminalJurisdiction
		(CrimJName, SearchSourceID, DefaultRate, Enabled, LastModifiedUser)
	VALUES
		(@CrimJName, @SearchSourceID, @DefaultRate, @Enabled, @LastModifiedUser)
	SELECT @CrimJID = @@Identity

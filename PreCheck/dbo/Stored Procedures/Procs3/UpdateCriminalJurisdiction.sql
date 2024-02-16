CREATE PROCEDURE UpdateCriminalJurisdiction
	@CrimJID int,
	@CrimJName varchar(30),
	@SearchSourceID tinyint,
	@DefaultRate smallmoney,
	@Enabled bit,
	@LastModifiedUser varchar(30)
AS
	UPDATE CriminalJurisdiction
	SET
		CrimJName = @CrimJName,
		SearchSourceID = @SearchSourceID,
		DefaultRate = @DefaultRate,
		Enabled = @Enabled,
		LastModifiedUser = @LastModifiedUser,
		LastModifiedDate = GetDate()
	WHERE
		CrimJID = @CrimJID

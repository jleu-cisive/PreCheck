CREATE PROCEDURE RetrieveCriminalJurisdiction
	@CrimJID int
AS
	SELECT CrimJID, CrimJName, SearchSourceID, DefaultRate, Enabled, LastModifiedUser, LastModifiedDate
	FROM CriminalJurisdiction
	WHERE CrimJID = @CrimJID

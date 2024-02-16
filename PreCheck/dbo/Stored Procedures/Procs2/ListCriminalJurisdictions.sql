CREATE PROCEDURE ListCriminalJurisdictions
AS
	SELECT CrimJID, CrimJName, Enabled
	FROM CriminalJurisdiction
	ORDER BY CrimJName

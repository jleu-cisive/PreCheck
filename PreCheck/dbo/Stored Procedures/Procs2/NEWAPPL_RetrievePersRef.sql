CREATE PROCEDURE NEWAPPL_RetrievePersRef
	@PersRefID int
AS
	SELECT PersRefID, Apno, Name, Phone, Rel_V, Years_V
	FROM PersRef
	WHERE PersRefID = @PersRefID

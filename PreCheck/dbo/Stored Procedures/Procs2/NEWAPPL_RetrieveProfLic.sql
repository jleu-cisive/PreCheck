CREATE PROCEDURE NEWAPPL_RetrieveProfLic
	@ProfLicID int
AS
	SELECT ProfLicID, Apno, Lic_Type, State, [Year], Expire, Lic_No
	FROM ProfLic
	WHERE ProfLicID = @ProfLicID

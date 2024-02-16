CREATE PROCEDURE ListClientsForPackage
	@PackageID int
AS
SET NOCOUNT ON
SELECT CP.CLNO, CP.PackageID, CP.Rate, C.[Name]
FROM ClientPackages CP
JOIN Client C on CP.CLNO = C.CLNO
WHERE CP.PackageID = @PackageID
ORDER BY C.[Name]

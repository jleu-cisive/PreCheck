CREATE PROCEDURE GetShpClientPackageSvc
	@CLNO smallint
AS
SELECT P.PackageID, P.ServiceType, P.IncludedCount, P.MaxCount
FROM PackageService P, ClientPackages C
WHERE (C.CLNO = @CLNO)
  AND (C.PackageID = P.PackageID)

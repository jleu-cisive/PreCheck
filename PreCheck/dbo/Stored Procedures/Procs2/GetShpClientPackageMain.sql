CREATE PROCEDURE GetShpClientPackageMain
	@CLNO smallint
AS
SELECT P.PackageID, P.PackageDesc, C.Rate
FROM PackageMain P, ClientPackages C
WHERE (C.CLNO = @CLNO)
  AND (C.PackageID = P.PackageID)

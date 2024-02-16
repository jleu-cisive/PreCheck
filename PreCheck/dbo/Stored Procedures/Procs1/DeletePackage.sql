CREATE PROCEDURE DeletePackage
	@PackageID int
AS
SET NOCOUNT ON
DELETE FROM PackageService
WHERE PackageID = @PackageID
DELETE FROM PackageMain
WHERE PackageID = @PackageID

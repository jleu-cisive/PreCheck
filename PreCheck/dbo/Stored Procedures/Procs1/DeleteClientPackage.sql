CREATE PROCEDURE DeleteClientPackage
	@CLNO smallint,
	@PackageID int
AS
SET NOCOUNT ON
DELETE FROM ClientPackages
WHERE (CLNO = @CLNO)
  AND (PackageID = @PackageID)

CREATE PROCEDURE UpdateClientPackage
	@CLNO smallint,
	@PackageID int,
	@Rate smallmoney
AS
SET NOCOUNT ON
UPDATE ClientPackages
SET Rate = @Rate
WHERE (CLNO = @CLNO)
  AND (PackageID = @PackageID)

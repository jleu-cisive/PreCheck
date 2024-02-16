CREATE PROCEDURE GetClientPackageRate
	@CLNO smallint,
	@PackageID int,
	@Rate smallmoney OUTPUT
AS
SET NOCOUNT ON
SELECT @Rate = Rate 
FROM ClientPackages
WHERE (CLNO = @CLNO)
  AND (PackageID = @PackageID)

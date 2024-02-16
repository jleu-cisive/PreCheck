CREATE PROCEDURE UpdatePackageMain
	@PackageID int,
	@PackageDesc varchar(20),
	@DefaultPrice smallmoney
AS
SET NOCOUNT ON
UPDATE PackageMain
SET PackageDesc = @PackageDesc,
	DefaultPrice = @DefaultPrice
WHERE PackageID = @PackageID

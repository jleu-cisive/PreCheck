CREATE PROCEDURE UpdatePackageDesc
	@PackageID int,
	@PackageDesc varchar(20)
AS
SET NOCOUNT ON
UPDATE PackageMain
SET PackageDesc = @PackageDesc
WHERE PackageID = @PackageID

CREATE PROCEDURE GetPackageDesc
	@PackageID int,
	@PackageDesc varchar(20) OUTPUT
AS
SET NOCOUNT ON
SELECT @PackageDesc = PackageDesc
FROM PackageMain
WHERE PackageID = @PackageID

CREATE PROCEDURE GetPackages
AS
SET NOCOUNT ON
SELECT PackageID, PackageDesc, DefaultPrice
FROM PackageMain
ORDER BY PackageDesc

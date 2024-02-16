CREATE PROCEDURE GetPackageServices
	@PackageID int
AS
SET NOCOUNT ON
SELECT PackageID, ServiceType, IncludedCount, MaxCount
FROM PackageService
WHERE PackageID = @PackageID

CREATE PROCEDURE UpdatePackageService
	@PackageID int,
	@ServiceType tinyint,
	@IncludedCount smallint,
	@MaxCount smallint
AS
SET NOCOUNT ON
UPDATE PackageService
SET IncludedCount = @IncludedCount,
	MaxCount = @MaxCount
WHERE (PackageID = @PackageID)
  AND (ServiceType = @ServiceType)

CREATE PROCEDURE InsertPackageService
	@PackageID int,
	@ServiceType tinyint,
	@IncludedCount smallint,
	@MaxCount smallint
AS
SET NOCOUNT ON
INSERT INTO PackageService (PackageID, ServiceType, IncludedCount, MaxCount)
VALUES (@PackageID, @ServiceType, @IncludedCount, @MaxCount)

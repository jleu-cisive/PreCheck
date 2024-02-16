CREATE PROCEDURE [dbo].[Billing_GetPackageServices_NP]
	@PackageID int
AS
SET NOCOUNT ON
SELECT ps.PackageID, ps.ServiceType, ps.IncludedCount, ps.MaxCount,dr.RateType As Identifier
FROM PackageService ps inner join DefaultRates dr on ps.ServiceID = dr.ServiceID 
WHERE ps.PackageID = @PackageID






CREATE VIEW [dbo].[vwClientPackage]
AS
SELECT
ClientId=cp.CLNO,
p.PackageID,
PackageName = ISNULL(cp.ClientPackageDesc,p.PackageDesc),
PackageTypeId = p.refPackageTypeID,
PackageTypeName=ISNULL(t.[Description],'Background Check'),
cp.IsActive,
PackagePrice = ISNULL(CP.Rate,P.DefaultPrice),
DefaultPackageName=p.PackageDesc

FROM dbo.ClientPackages cp
	INNER JOIN dbo.PackageMain p
	ON p.PackageID = cp.PackageID
	LEFT OUTER JOIN dbo.refPackageType t
	ON p.refPackageTypeID=t.refPackageTypeID


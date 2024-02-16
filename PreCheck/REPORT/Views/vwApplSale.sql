



CREATE VIEW [REPORT].[vwApplSale]
AS
SELECT
APNO,
A.CLNO,
A.PackageID,
CP.PackagePrice,
ClientPackageName=CP.PackageName,
CP.DefaultPackageName,
A.CreatedDate,
EnteredVia = CASE WHEN EO.OrderNumber IS NOT NULL THEN 'MCIC' ELSE a.EnteredVia END,
A.OrigCompDate
FROM dbo.Appl A WITH(NOLOCK)
LEFT OUTER JOIN Enterprise.precheck.vwClientPackage CP WITH(NOLOCK)
	ON A.PackageID=CP.PackageID AND A.CLNO=CP.ClientId		
LEFT OUTER JOIN Enterprise..[Order] EO WITH(NOLOCK)
			ON A.APNO=EO.OrderNumber AND eo.BatchOrderDetailId IS NOT NULL AND eo.DASourceId=2

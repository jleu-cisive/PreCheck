
CREATE PROCEDURE [dbo].[PackageSummary]
AS
SET NOCOUNT ON

SELECT pm.PackageDesc
     , c.Name
     , cp.CLNO
     , pm.DefaultPrice
     , cp.Rate as Price 
     , dr.RateType
     , (case when cr.Rate IS NULL then '0.00' else cr.Rate end) as Rate
     , dr.DefaultRate
     , ps.Includedcount
     , ps.MaxCount
     , dr.DefaultRate as PackageDefaultRate
     , rbs.BillingStatus
	 , c.IsInactive
	 , MAX(im.InvDate) AS LastDateBilled


 FROM ClientPackages cp JOIN PackageService ps ON cp.PackageID = ps.PackageID 
   JOIN DefaultRates dr ON dr.ServiceID = ps.ServiceID
   JOIN PackageMain pm ON pm.PackageID=cp.PackageID 
   JOIN Client c ON c.CLNO=cp.CLNO
   LEFT JOIN ClientRates cr ON cr.ServiceID=dr.ServiceID AND cr.CLNO=c.CLNO
   LEFT JOIN dbo.refBillingStatus rbs ON c.BillingStatusID = rbs.BillingStatusID
   LEFT JOIN dbo.InvMaster im ON c.CLNO = im.CLNO

GROUP BY pm.PackageDesc
		, c.Name
		, cp.CLNO
		, pm.DefaultPrice
		, cp.Rate  
		, dr.RateType
		, (case when cr.Rate IS NULL then '0.00' else cr.Rate end) 
		, dr.DefaultRate
		, ps.Includedcount
		, ps.MaxCount
		, dr.DefaultRate 
		, rbs.BillingStatus
		, c.IsInactive

ORDER BY pm.PackageDesc
		 ,c.Name 
		 ,cp.CLNO 
		 ,dr.RateType

SET NOCOUNT OFF

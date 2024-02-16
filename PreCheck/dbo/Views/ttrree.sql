CREATE VIEW dbo.ttrree
AS
SELECT DISTINCT 
                      c.County, dbo.CountydefaultVendor.FirstName, dbo.CountydefaultVendor.LastName, dbo.CountydefaultVendor.VendorCompany, 
                      dbo.CountydefaultVendor.VendorID, c.Ordered
FROM         dbo.Crim c INNER JOIN
                      dbo.Appl a ON c.APNO = a.APNO LEFT OUTER JOIN
                      dbo.CountydefaultVendor ON c.County = dbo.CountydefaultVendor.johndo
WHERE     (a.ApStatus IN ('P', 'W'))
GROUP BY c.County, c.Clear, c.APNO, c.Ordered, dbo.CountydefaultVendor.FirstName, dbo.CountydefaultVendor.LastName, 
                      dbo.CountydefaultVendor.VendorCompany, dbo.CountydefaultVendor.VendorID, c.Ordered
HAVING      (c.Clear = 'o')

CREATE VIEW dbo.VIEW2
AS
SELECT DISTINCT 
                      c.County, dbo.CountydefaultVendor.FirstName, dbo.CountydefaultVendor.LastName, dbo.CountydefaultVendor.VendorCompany, 
                      dbo.CountydefaultVendor.VendorID, c.APNO, c.Name, c.DOB
FROM         dbo.Crim c INNER JOIN
                      dbo.Appl a ON c.APNO = a.APNO LEFT OUTER JOIN
                      dbo.CountydefaultVendor ON c.County = dbo.CountydefaultVendor.johndo
WHERE     (a.ApStatus IN ('P', 'W')) AND (c.Clear IS NULL)
GROUP BY c.County, c.Clear, c.APNO, c.Ordered, dbo.CountydefaultVendor.FirstName, dbo.CountydefaultVendor.LastName, 
                      dbo.CountydefaultVendor.VendorCompany, dbo.CountydefaultVendor.VendorID, c.Name, c.DOB

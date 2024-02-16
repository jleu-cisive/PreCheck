CREATE PROCEDURE M_Crim_Readytoorder as
SELECT    c.County, c.Clear, c.APNO, c.Ordered, dbo.CountydefaultVendor.VendorCompany, dbo.CountydefaultVendor.FirstName, 
                      dbo.CountydefaultVendor.johndo
FROM         dbo.Crim c INNER JOIN
                      dbo.Appl a ON c.APNO = a.APNO LEFT OUTER JOIN
                      dbo.CountydefaultVendor ON c.County = dbo.CountydefaultVendor.County
WHERE     (a.ApStatus IN ('P', 'W')) AND (c.Clear IS NULL)

CREATE PROCEDURE Crimpendingwithtime AS
SELECT DISTINCT  c.County, dbo.CountydefaultVendor.FirstName, dbo.CountydefaultVendor.LastName, dbo.CountydefaultVendor.VendorCompany, 
                      dbo.CountydefaultVendor.VendorID, 
    (SELECT min(crimenteredtime) FROM Crim
	WHERE (Crim.county = c.county)
	  AND (Crim.Clear IS NULL))
        AS Crim_time
FROM         dbo.Crim c INNER JOIN
                      dbo.Appl a ON c.APNO = a.APNO LEFT OUTER JOIN
                      dbo.CountydefaultVendor ON c.County = dbo.CountydefaultVendor.johndo
WHERE     (a.ApStatus IN ('P', 'W'))  and  (c.clear is null) and (datediff(mi,c.crimenteredtime,getdate()) >= 20)
GROUP BY c.County, c.Clear, c.APNO, c.Ordered, dbo.CountydefaultVendor.FirstName, dbo.CountydefaultVendor.LastName, 
dbo.CountydefaultVendor.VendorCompany, dbo.CountydefaultVendor.VendorID,c.crimenteredtime
--SELECT DISTINCT  c.County, dbo.CountydefaultVendor.FirstName, dbo.CountydefaultVendor.LastName, dbo.CountydefaultVendor.VendorCompany, 
--                      dbo.CountydefaultVendor.VendorID, 
--    (SELECT min(crimenteredtime) FROM Crim
--	WHERE (Crim.county = c.county)
--	  AND (Crim.Clear IS NULL))
--        AS Crim_time
--FROM         dbo.Crim c INNER JOIN
--                      dbo.Appl a ON c.APNO = a.APNO LEFT OUTER JOIN
--                      dbo.CountydefaultVendor ON c.County = dbo.CountydefaultVendor.johndo
--WHERE     (a.ApStatus IN ('P', 'W'))  and  (c.clear is null)
--GROUP BY c.County, c.Clear, c.APNO, c.Ordered, dbo.CountydefaultVendor.FirstName, dbo.CountydefaultVendor.LastName, 
 --                     dbo.CountydefaultVendor.VendorCompany, dbo.CountydefaultVendor.VendorID

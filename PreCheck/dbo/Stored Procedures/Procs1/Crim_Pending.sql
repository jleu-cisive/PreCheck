CREATE PROCEDURE Crim_Pending AS
--select  distinct c.county,c.apno,c.clear,c.ordered,a.userid,dv.vendorid,dv.vendorcompany,c.uniqueid, a.apdate,a.last,a.first,a.middle,convert(numeric(7,2),dbo.elapsedbusinessdays(c.ordered,getdate())) as elapsed
--from crim c join appl a on c.apno = a.apno 
--join countydefaultvendor dv on c.county = dv.johndo
--where c.clear = 'o' and (a.apstatus in ('p','w')) 
SELECT DISTINCT 
                      c.County, dbo.CountydefaultVendor.FirstName, dbo.CountydefaultVendor.LastName, dbo.CountydefaultVendor.VendorCompany, 
                      dbo.CountydefaultVendor.VendorID,c.uniqueid,c.ordered,convert(numeric(7,2),dbo.elapsedbusinessdays(c.ordered,getdate())) as Elapsed
FROM         dbo.Crim c INNER JOIN
                      dbo.Appl a ON c.APNO = a.APNO LEFT OUTER JOIN
                      dbo.CountydefaultVendor ON c.County = dbo.CountydefaultVendor.johndo
WHERE     (a.ApStatus IN ('P', 'W'))
GROUP BY c.County, c.Clear, c.APNO, c.Ordered, dbo.CountydefaultVendor.FirstName, dbo.CountydefaultVendor.LastName, 
                      dbo.CountydefaultVendor.VendorCompany, dbo.CountydefaultVendor.VendorID,c.uniqueid
HAVING      (c.Clear = 'o')

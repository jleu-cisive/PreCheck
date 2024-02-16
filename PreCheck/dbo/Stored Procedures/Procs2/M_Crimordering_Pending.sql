CREATE PROCEDURE M_Crimordering_Pending
 @controlnum varchar(100) ,
@contact varchar(100),
@phone varchar(20),
@fax varchar(20),
@vendornotes varchar(200)
AS
SELECT     a.[Last], c.CrimID, a.[First], @contact as contact,@phone as phone,@fax as fax,@vendornotes as vendornotes,CONVERT(varchar, a.DOB, 101) AS dob, 
                  c.Ordered, a.DL_Number, a.SSN, a.Middle, a.Alias, a.Alias2, a.Alias3, 
                --      dv.VendorCompany, dv.LastName, dv.FirstName, dv.VendorPhone, dv.VendorFax,
 a.Alias4, a.APNO, c.txtalias, c.txtalias2, c.txtalias3, c.txtalias4, 
                      a.Addr_Num + ' ' + a.Addr_Street AS address, c.County,  c.uniqueid,c.txtlast
FROM         dbo.Crim c INNER JOIN
                      dbo.Appl a ON c.APNO = a.APNO
-- LEFT OUTER JOIN    dbo.CountydefaultVendor dv ON c.County = dv.johndo
WHERE     (a.ApStatus IN ('P', 'W')) AND (c.Clear = 'o') AND (c.uniqueid = @controlnum)

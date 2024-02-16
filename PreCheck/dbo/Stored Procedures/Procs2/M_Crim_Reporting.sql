CREATE PROCEDURE M_Crim_Reporting 
@uniqueid varchar(50) ,
@contact varchar(100),
@phone varchar(20),
@fax varchar(20),
@vendornotes varchar(200),
@company varchar(100)
AS
SELECT     a.[Last], c.CrimID, a.[First], CONVERT(varchar, a.DOB, 101) AS dob, c.Ordered, a.DL_Number, 
--dv.VendorPhone, dv.VendorFax, 
               @contact as contact,@phone as phone,@fax as fax,@vendornotes as notes,@company as company,
                      a.Addr_Num + ' ' + a.Addr_Street AS address, a.SSN, a.Middle, a.Alias, a.Alias2, a.Alias3, a.Alias4, a.APNO, c.County, c.Ordered AS Expr1, c.txtalias, 
                      c.txtlast,c.txtalias2, c.txtalias3, c.txtalias4, c.uniqueid
--dv.VendorCompany, dv.FirstName, dv.LastName
FROM         dbo.Crim c INNER JOIN
                      dbo.Appl a ON c.APNO = a.APNO 
-- LEFT OUTER JOIN
--                      dbo.CountydefaultVendor dv ON c.County = dv.johndo
WHERE     (a.ApStatus IN ('P', 'W')) AND (c.uniqueid = @uniqueid)

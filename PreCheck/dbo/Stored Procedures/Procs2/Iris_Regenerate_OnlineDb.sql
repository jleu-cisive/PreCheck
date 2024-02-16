-- Alter Procedure Iris_Regenerate_OnlineDb
CREATE PROCEDURE dbo.Iris_Regenerate_OnlineDb @printnumber int AS

SELECT     dbo.Appl.[Last], dbo.Appl.[First], dbo.Appl.Middle, dbo.Appl.Alias, dbo.Appl.Alias2, dbo.Appl.Alias3, dbo.Appl.Alias4, dbo.Appl.SSN, dbo.Appl.DOB, 
                      dbo.Crim.CRIM_SpecialInstr, dbo.Appl.Addr_Num + ' ' + dbo.Appl.Addr_Street AS address, dbo.Appl.City, dbo.Appl.State, dbo.Appl.Zip, 
                      dbo.Appl.ApStatus, dbo.Crim.txtlast, dbo.Crim.txtalias, dbo.Crim.txtalias2, dbo.Crim.txtalias3, dbo.Crim.txtalias4, dbo.Appl.Alias AS Expr1, 
                      dbo.Appl.Alias1_Last, dbo.Appl.Alias1_First, dbo.Appl.Alias1_Middle, dbo.Appl.Alias1_Generation, dbo.Appl.Alias2_Last, dbo.Appl.Alias2_First, 
                      dbo.Appl.Alias2_Middle, dbo.Appl.Alias2_Generation, dbo.Appl.Alias3_Last, dbo.Appl.Alias3_First, dbo.Appl.Alias3_Middle, dbo.Appl.Alias3_Generation, 
                      dbo.Appl.Alias4_Last, dbo.Appl.Alias4_First, dbo.Appl.Alias4_Middle, dbo.Appl.Alias4_Generation, dbo.Appl.Alias2 AS Expr2, dbo.Appl.Alias3 AS Expr3, 
                      dbo.Appl.Alias4 AS Expr4, dbo.Iris_Researchers.R_Name, dbo.Iris_Researchers.R_Email_Address, dbo.Crim.Ordered, dbo.Iris_Researchers.R_Zip, 
                      dbo.Iris_Researchers.R_Phone, dbo.Iris_Researchers.R_Fax, dbo.Iris_Researchers.R_Firstname, dbo.Iris_Researchers.R_Lastname, 
                      dbo.Iris_Researchers.R_Middlename, dbo.Crim.batchnumber, dbo.Iris_Researchers.R_VendorNotes, dbo.Crim.County AS Bis_Crim_County, 
                      dbo.Appl.APNO, dbo.TblCounties.A_County, dbo.TblCounties.State AS crimstate,crim.status,crim.batchnumber,TblCounties.country
FROM         dbo.Appl INNER JOIN
                      dbo.Crim ON dbo.Appl.APNO = dbo.Crim.APNO INNER JOIN
                      dbo.Iris_Researchers ON dbo.Crim.vendorid = dbo.Iris_Researchers.R_id INNER JOIN
                      dbo.TblCounties ON dbo.Crim.CNTY_NO = dbo.TblCounties.CNTY_NO
WHERE     (dbo.Crim.status = @printnumber)

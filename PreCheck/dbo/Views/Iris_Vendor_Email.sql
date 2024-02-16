CREATE VIEW dbo.Iris_Vendor_Email
AS
SELECT     TOP 100 PERCENT dbo.Crim.CNTY_NO, dbo.Crim.APNO, dbo.Crim.vendorid, dbo.Crim.CrimID, dbo.Iris_Researchers.R_Email_Address, 
                      dbo.Iris_Researchers.R_Delivery, dbo.Iris_Researchers.R_Name, dbo.Iris_Researchers.R_Fax
FROM         dbo.Appl INNER JOIN
                      dbo.Crim ON dbo.Appl.APNO = dbo.Crim.APNO INNER JOIN
                      dbo.Iris_Researchers ON dbo.Crim.vendorid = dbo.Iris_Researchers.R_id
WHERE     (dbo.Iris_Researchers.R_Delivery = 'e-mail') AND (dbo.Crim.IRIS_REC = 'Yes') AND (dbo.Crim.readytosend = '1') AND (dbo.Appl.InUse IS NULL) AND 
                      (dbo.Crim.Clear = 'R') AND (DATEDIFF(mi, dbo.Crim.Crimenteredtime, GETDATE()) >= 20) AND (dbo.Crim.batchnumber IS NULL) AND 
                      (dbo.Appl.ApStatus = 'p' OR
                      dbo.Appl.ApStatus = 'w') OR
                      (dbo.Iris_Researchers.R_Delivery = 'e-mail') AND (dbo.Crim.IRIS_REC = 'Yes') AND (dbo.Crim.readytosend = '1') AND (dbo.Appl.InUse IS NULL) AND 
                      (dbo.Crim.Clear = 'R') AND (DATEDIFF(mi, dbo.Crim.Crimenteredtime, GETDATE()) >= 1) AND (dbo.Crim.batchnumber IS NULL) AND 
                      (dbo.Appl.ApStatus = 'p' OR
                      dbo.Appl.ApStatus = 'w')
ORDER BY dbo.Crim.vendorid, dbo.Crim.CNTY_NO



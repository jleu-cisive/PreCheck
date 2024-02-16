CREATE PROCEDURE Iris_FaxCopy_Vendors AS

SELECT DISTINCT dbo.Iris_Researchers.R_Name, dbo.Iris_Researchers.R_id 
FROM         dbo.Crim WITH (NOLOCK) INNER JOIN
                      dbo.Appl WITH (NOLOCK) ON dbo.Crim.APNO = dbo.Appl.APNO LEFT OUTER JOIN
                      dbo.Iris_Researchers WITH (NOLOCK) ON dbo.Crim.vendorid = dbo.Iris_Researchers.R_id
WHERE     (dbo.Iris_Researchers.R_Delivery = 'Fax-CopyofCheck') AND (dbo.Crim.Clear IS NULL Or Crim.clear = 'R') AND (dbo.Crim.IRIS_REC = 'yes') AND (dbo.Crim.batchnumber IS NULL) AND 
                      (DATEDIFF(mi, dbo.Crim.Crimenteredtime, GETDATE()) >= 1) AND (dbo.Appl.InUse IS NULL OR
                      dbo.Appl.InUse = '0') and (iris_researchers.r_active = 'yes')
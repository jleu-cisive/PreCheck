-- Alter Procedure Iris_Automate_Fax_Vendors
CREATE PROCEDURE dbo.Iris_Automate_Fax_Vendors AS

-- Prep outgoing fax and Connect to Iris_automated_pending_fax
SELECT DISTINCT dbo.Iris_Researchers.R_Name, dbo.Iris_Researchers.R_id,dbo.iris_researchers.r_fax
FROM         dbo.Appl INNER JOIN
                      dbo.Crim ON dbo.Appl.APNO = dbo.Crim.APNO INNER JOIN
                      dbo.Iris_Researchers ON dbo.Crim.vendorid = dbo.Iris_Researchers.R_id INNER JOIN
                      dbo.TblCounties ON dbo.Crim.CNTY_NO = dbo.TblCounties.CNTY_NO
WHERE     (dbo.Appl.ApStatus = 'p' OR
                      dbo.Appl.ApStatus = 'w') AND (dbo.Crim.Clear = 'o') AND (dbo.Iris_Researchers.R_Delivery = 'fax')
 and (iris_researchers.iris_autosender = 1)
--and (iris_researchers.R_id <> 115125)

GROUP BY dbo.Iris_Researchers.R_Name, dbo.Iris_Researchers.R_id,iris_researchers.r_fax
ORDER BY dbo.Iris_Researchers.R_id

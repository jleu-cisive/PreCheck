CREATE VIEW dbo.VIEW4
AS
SELECT     dbo.Crim.APNO, dbo.Iris_Researchers.R_Name, dbo.Iris_Researchers.R_Firstname, dbo.Crim.b_rule, dbo.Iris_Researchers.R_Lastname, 
                      ISNULL(dbo.Crim.readytosend, 0) AS readytosend, dbo.Iris_Researchers.R_id AS vendorid, dbo.Iris_Researchers.R_Delivery, dbo.Crim.CNTY_NO,
                          (SELECT     MIN(z.crimenteredtime)
                            FROM          Crim z
                            WHERE      (z.cnty_no = crim.cnty_no) AND (z.Clear IS NULL) AND (z.iris_rec = 'yes')) AS crim_time, dbo.Counties.A_County AS county, 
                      dbo.Counties.State, dbo.Crim.IRIS_REC, dbo.Appl.ApStatus
FROM         dbo.Crim INNER JOIN
                      dbo.Counties ON dbo.Crim.CNTY_NO = dbo.Counties.CNTY_NO INNER JOIN
                      dbo.Appl ON dbo.Crim.APNO = dbo.Appl.APNO LEFT OUTER JOIN
                      dbo.Iris_Researchers ON dbo.Crim.vendorid = dbo.Iris_Researchers.R_id
WHERE     (dbo.Iris_Researchers.R_Delivery = 'fax') AND (dbo.Crim.Clear IS NULL) AND (dbo.Crim.IRIS_REC = 'yes') AND (DATEDIFF(mi, 
                      dbo.Crim.Crimenteredtime, GETDATE()) >= 10)

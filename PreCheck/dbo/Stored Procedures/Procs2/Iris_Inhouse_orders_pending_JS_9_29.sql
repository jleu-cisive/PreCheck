-- Alter Procedure Iris_Inhouse_orders_pending_JS_9_29
CREATE PROCEDURE dbo.Iris_Inhouse_orders_pending_JS_9_29  AS
SELECT    dbo.Iris_Researchers.R_Name, dbo.Iris_Researchers.R_Firstname, dbo.Crim.b_rule, dbo.Iris_Researchers.R_Lastname, 
                      ISNULL(dbo.Crim.readytosend, 0) AS readytosend, dbo.Iris_Researchers.R_id AS vendorid, dbo.Iris_Researchers.R_Delivery, dbo.Crim.CNTY_NO,
                          crim.crimenteredtime
                             AS crim_time, dbo.TblCounties.A_County AS county, 
                      dbo.TblCounties.State, dbo.Crim.IRIS_REC
--, dbo.Appl.InUse
FROM        dbo.Crim INNER JOIN
                  dbo.TblCounties ON dbo.Crim.CNTY_NO = dbo.TblCounties.CNTY_NO INNER JOIN
                  dbo.Appl ON dbo.Crim.APNO = dbo.Appl.APNO LEFT OUTER JOIN
                  dbo.Iris_Researchers ON dbo.Crim.vendorid = dbo.Iris_Researchers.R_id
WHERE    (dbo.Iris_Researchers.R_Delivery = 'InHouse') AND  (Crim.clear = 'o')  AND (dbo.Crim.IRIS_REC = 'yes') AND (dbo.Crim.batchnumber IS NULL) 
--AND (DATEDIFF(mi, dbo.Crim.Crimenteredtime, GETDATE()) >= 20) 
AND (dbo.Appl.InUse IS NULL )

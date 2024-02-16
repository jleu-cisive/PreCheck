-- Alter Procedure Iris_Mailcheck_Order_Pending_572012


CREATE PROCEDURE [dbo].[Iris_Mailcheck_Order_Pending_572012] AS
SELECT   distinct dbo.Iris_Researchers.R_Name, dbo.Iris_Researchers.R_Firstname, dbo.Crim.b_rule, dbo.Iris_Researchers.R_Lastname, 
--isnull(dbo.LookupTimeZoneByState (Iris_Researchers.R_City,Iris_Researchers.R_State_Province,getdate(),iris_researchers.cutoff),'N/A') as cutoff,
--isnull(datediff(mi,getdate(),dbo.LookupTimeZoneByState (Iris_Researchers.R_City,Iris_Researchers.R_State_Province,getdate(),iris_researchers.cutoff)),999999999) as mycutoff,
                      ISNULL(dbo.Crim.readytosend, 0) AS readytosend, dbo.Iris_Researchers.R_id AS vendorid, dbo.Iris_Researchers.R_Delivery, dbo.Crim.CNTY_NO,
                          (SELECT     MIN(z.crimenteredtime)
                            FROM          Crim z
                            WHERE      (z.cnty_no = crim.cnty_no) AND (z.Clear IS NULL or z.clear = 'R') AND (z.iris_rec = 'yes')) AS crim_time, dbo.TblCounties.A_County AS county, 
                      dbo.TblCounties.State, dbo.Crim.IRIS_REC
FROM         dbo.Crim INNER JOIN
                      dbo.TblCounties ON dbo.Crim.CNTY_NO = dbo.TblCounties.CNTY_NO INNER JOIN
                      dbo.Appl ON dbo.Crim.APNO = dbo.Appl.APNO LEFT OUTER JOIN
                      dbo.Iris_Researchers ON dbo.Crim.vendorid = dbo.Iris_Researchers.R_id
WHERE     (dbo.Iris_Researchers.R_Delivery = 'Mail-copyofcheck') AND (dbo.Crim.Clear IS NULL or Crim.clear = 'R') AND (dbo.Crim.IRIS_REC = 'yes') 
AND (dbo.Crim.batchnumber IS NULL)  AND   (DATEDIFF(mi, dbo.Crim.Crimenteredtime, GETDATE()) >= 1) 
and (dbo.Appl.InUse IS NULL )
--order by mycutoff asc




Create PROCEDURE [dbo].[Iris_Fax_orders_pending_572012]  AS

-- If there is an stuck in the que check for application it may be in Final status

SELECT   distinct Iris_Researchers.R_Name, Iris_Researchers.R_Firstname, Crim.b_rule, Iris_Researchers.R_Lastname,Iris_Researchers.R_State_Province,
--ISNULL(dbo.LookupTimeZoneByState (Iris_Researchers.R_City,Iris_Researchers.R_State_Province,getdate(),iris_researchers.cutoff),'N/A') as cutoff,
--isnull(datediff(mi,getdate(),dbo.LookupTimeZoneByState (Iris_Researchers.R_City,Iris_Researchers.R_State_Province,getdate(),iris_researchers.cutoff)),999999999) as mycutoff,
         ISNULL(
            Crim.readytosend, 0) 
         AS readytosend, 
       Iris_Researchers.R_id AS vendorid,
       Iris_Researchers.R_Delivery, 
       Crim.CNTY_NO,
                          (SELECT     MIN(z.crimenteredtime)
                            FROM          Crim z WITH (NOLOCK) 
                            WHERE      (z.cnty_no = crim.cnty_no) AND (z.clear = 'R') AND (z.iris_rec = 'yes')) AS crim_time,Counties.A_County AS county, 
                      Counties.State, Crim.IRIS_REC
FROM         Crim WITH (NOLOCK) INNER JOIN
                      Counties WITH (NOLOCK) ON dbo.Crim.CNTY_NO = Counties.CNTY_NO INNER JOIN
                      Appl WITH (NOLOCK) ON dbo.Crim.APNO =  Appl.APNO LEFT OUTER JOIN
                      Iris_Researchers WITH (NOLOCK) ON dbo.Crim.vendorid = Iris_Researchers.R_id


WHERE     (dbo.Iris_Researchers.R_Delivery = 'fax') AND (Crim.clear = 'R') AND (dbo.Crim.IRIS_REC = 'yes') 
AND (dbo.Crim.batchnumber IS NULL)  AND   (DATEDIFF(mi, dbo.Crim.Crimenteredtime, GETDATE()) >= 1) 
and (dbo.Appl.InUse IS NULL) and (appl.apstatus = 'p' or appl.apstatus = 'w')




/*WHERE     (Iris_Researchers.R_Delivery = 'fax') AND (Crim.Clear IS NULL or Crim.clear = 'R') AND (Crim.IRIS_REC = 'yes') 
AND (Crim.batchnumber IS NULL)  AND   (DATEDIFF(mi, Crim.Crimenteredtime, GETDATE()) >= 20) 
and (Appl.InUse IS NULL ) */
--order by iris_researchers.r_name
--order by mycutoff asc
-- isnull(convert(varchar,iris_researchers.cutoff,108),'N/A')



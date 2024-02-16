




CREATE PROCEDURE [dbo].[Iris_Callin_orders_pending] AS


--SELECT    distinct dbo.Iris_Researchers.R_Name, dbo.Iris_Researchers.R_Firstname, dbo.Crim.b_rule, dbo.Iris_Researchers.R_Lastname,
----isnull(dbo.LookupTimeZoneByState (Iris_Researchers.R_City,Iris_Researchers.R_State_Province,getdate(),iris_researchers.cutoff),'N/A') as cutoff,
----isnull(datediff(mi,getdate(),dbo.LookupTimeZoneByState (Iris_Researchers.R_City,Iris_Researchers.R_State_Province,getdate(),iris_researchers.cutoff)),999999999) as mycutoff,
--                      ISNULL(dbo.Crim.readytosend, 0) AS readytosend, dbo.Iris_Researchers.R_id AS vendorid, dbo.Iris_Researchers.R_Delivery, dbo.Crim.CNTY_NO,
--                          (SELECT     MIN(z.crimenteredtime)
--                            FROM          Crim z
--                            WHERE      (z.cnty_no = crim.cnty_no) AND (z.Clear IS NULL or z.clear = 'R') AND (z.iris_rec = 'yes')) AS crim_time, dbo.Counties.A_County AS county, 
--                      dbo.Counties.State, dbo.Crim.IRIS_REC
----, dbo.Appl.InUse
--FROM         dbo.Crim (NOLOCK) INNER JOIN
--                      dbo.Counties (NOLOCK) ON dbo.Crim.CNTY_NO = dbo.Counties.CNTY_NO INNER JOIN
--                      dbo.Appl (NOLOCK) ON dbo.Crim.APNO = dbo.Appl.APNO LEFT OUTER JOIN
--                      dbo.Iris_Researchers (NOLOCK) ON dbo.Crim.vendorid = dbo.Iris_Researchers.R_id
--WHERE     (dbo.Iris_Researchers.R_Delivery = 'Call_in') AND  Crim.clear = 'R'  AND (dbo.Crim.IRIS_REC = 'yes') AND (dbo.Crim.batchnumber IS NULL) 
--AND       (DATEDIFF(mi, dbo.Crim.Crimenteredtime, GETDATE()) >= 1) 
--AND (dbo.Appl.InUse IS NULL )
----order by   mycutoff asc
------------------------------------------------------------------


--7/29/08 changed for performance tuning cchaupin
SELECT    dbo.Iris_Researchers.R_Name, dbo.Iris_Researchers.R_Firstname, dbo.Crim.b_rule, dbo.Iris_Researchers.R_Lastname, 
  ISNULL(dbo.Crim.readytosend, 0) AS readytosend, dbo.Iris_Researchers.R_id AS vendorid, dbo.Iris_Researchers.R_Delivery, dbo.Crim.CNTY_NO,
       MIN(crimenteredtime)
        AS crim_time, dbo.Counties.A_County AS county, 
  dbo.Counties.State, dbo.Crim.IRIS_REC
FROM        dbo.Crim WITH (NOLOCK) INNER JOIN
                  dbo.Counties WITH (NOLOCK) ON dbo.Crim.CNTY_NO = dbo.Counties.CNTY_NO INNER JOIN
                  dbo.Appl WITH (NOLOCK) ON dbo.Crim.APNO = dbo.Appl.APNO LEFT OUTER JOIN
                  dbo.Iris_Researchers WITH (NOLOCK) ON dbo.Crim.vendorid = dbo.Iris_Researchers.R_id
WHERE    (dbo.Iris_Researchers.R_Delivery = 'Call_in') AND  (Crim.clear = 'R')  AND (dbo.Crim.IRIS_REC = 'yes') AND (dbo.Crim.batchnumber IS NULL) 
AND ((DATEDIFF(mi, dbo.Crim.last_updated, GETDATE()) >= 1))
AND (dbo.Appl.InUse IS NULL ) AND (Appl.ApStatus = 'p' OR Appl.ApStatus = 'w')
and dbo.Appl.CLNO not in (3468) and (dbo.crim.IsHidden = 0 ) -- Added this by Santosh on 06/24/13 to exclude BAD APPS and unused searches
group by dbo.Iris_Researchers.R_Name, dbo.Iris_Researchers.R_Firstname, dbo.Crim.b_rule, dbo.Iris_Researchers.R_Lastname, 
  ISNULL(dbo.Crim.readytosend, 0) , dbo.Iris_Researchers.R_id , dbo.Iris_Researchers.R_Delivery, dbo.Crim.CNTY_NO,
dbo.Counties.A_County , 
  dbo.Counties.State, dbo.Crim.IRIS_REC
   order by crim_time asc

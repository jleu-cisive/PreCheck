-- Alter Procedure Iris_Email_orders_pending




CREATE PROCEDURE [dbo].[Iris_Email_orders_pending] AS
SET NOCOUNT ON       --stop the server from returning a message to the client, reduce network traffic
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT    distinct dbo.Iris_Researchers.R_Name, dbo.Iris_Researchers.R_Firstname, dbo.Crim.b_rule, dbo.Iris_Researchers.R_Lastname, 
--isnull(dbo.LookupTimeZoneByState (Iris_Researchers.R_City,Iris_Researchers.R_State_Province,getdate(),iris_researchers.cutoff),'N/A') as cutoff, 
--isnull(datediff(mi,getdate(),dbo.LookupTimeZoneByState (Iris_Researchers.R_City,Iris_Researchers.R_State_Province,getdate(),iris_researchers.cutoff)),999999999) as mycutoff, 
                    ISNULL(dbo.Crim.readytosend, 0) AS readytosend, dbo.Iris_Researchers.R_id AS vendorid, dbo.Iris_Researchers.R_Delivery, dbo.Crim.CNTY_NO,
                          (SELECT     MIN(z.crimenteredtime)
                            FROM          Crim z
							INNER JOIN Appl a on a.APNO = z.APNO
                            WHERE      (z.cnty_no = crim.cnty_no) AND (z.clear = 'R') AND (z.iris_rec = 'yes') AND A.ApStatus in ('P','W')) AS crim_time, dbo.TblCounties.A_County AS county, 
                      dbo.TblCounties.State, dbo.Crim.IRIS_REC, dbo.Appl.InUse
FROM         dbo.Crim INNER JOIN
                      dbo.TblCounties ON dbo.Crim.CNTY_NO = dbo.TblCounties.CNTY_NO INNER JOIN
                      dbo.Appl ON dbo.Crim.APNO = dbo.Appl.APNO LEFT OUTER JOIN
                      dbo.Iris_Researchers ON dbo.Crim.vendorid = dbo.Iris_Researchers.R_id
WHERE     (dbo.Iris_Researchers.R_Delivery = 'E-Mail') AND (crim.clear = 'R') AND (dbo.Crim.IRIS_REC = 'yes') AND (dbo.Crim.batchnumber IS NULL) AND 
                    (DATEDIFF(mi, dbo.Crim.Crimenteredtime, GETDATE()) >= 1) 
                    and (dbo.Appl.InUse IS NULL) and (appl.apstatus = 'p' or appl.apstatus = 'w')
					and dbo.Appl.CLNO not in (3468) and (dbo.crim.IsHidden = 0 ) -- Added this by Santosh on 06/24/13 to exclude BAD APPS and unused searches
ORDER BY crim_time asc
--order by   mycutoff asc
SET NOCOUNT OFF
SET TRANSACTION ISOLATION LEVEL READ COMMITTED

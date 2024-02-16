
-- =============================================
-- Edited By :	Larry Ouch
-- Edited date:	08/15/2017
-- Description:	introduced a new Delivery method called "integrated"
-- Execution: EXEC [dbo].[Iris_IntegratedVendor_orders_pending] 
-- =============================================
-- Modify by : Doug DeGenaro
-- Modify Date : 08/15/2019
-- Description :  removed Crim id in the select and group by as it is causing duplicates in IRIS and did order by with min

CREATE PROCEDURE [dbo].[Iris_IntegratedVendor_orders_pending] AS

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

SELECT dbo.Iris_Researchers.R_Name, dbo.Iris_Researchers.R_Firstname, dbo.Crim.b_rule, dbo.Iris_Researchers.R_Lastname, 
		ISNULL(dbo.Crim.readytosend, 0) AS readytosend, dbo.Iris_Researchers.R_id AS vendorid, dbo.Iris_Researchers.R_Delivery, dbo.Crim.CNTY_NO,
        MIN(crimenteredtime) AS crim_time, dbo.Counties.A_County AS county, 
		dbo.Counties.State, dbo.Crim.IRIS_REC
--, dbo.Appl.InUse
FROM dbo.Crim WITH (NOLOCK) 
INNER JOIN dbo.Counties WITH (NOLOCK) ON dbo.Crim.CNTY_NO = dbo.Counties.CNTY_NO 
INNER JOIN dbo.Appl WITH (NOLOCK) ON dbo.Crim.APNO = dbo.Appl.APNO 
LEFT OUTER JOIN dbo.Iris_Researchers WITH (NOLOCK) ON dbo.Crim.vendorid = dbo.Iris_Researchers.R_id
WHERE (dbo.Iris_Researchers.R_Delivery = 'integration') 
  AND  (Crim.clear = 'R')  
  AND (dbo.Crim.IRIS_REC = 'yes') 
  AND (dbo.Crim.batchnumber IS NULL) 
  AND ((DATEDIFF(mi, dbo.Crim.last_updated, GETDATE()) >= 1)  and (Counties.cnty_no <> 2480)  or (DATEDIFF(mi, dbo.Crim.last_updated, GETDATE()) >= 20)  and (Counties.cnty_no = 2480)) 
  AND (dbo.Appl.InUse IS NULL ) 
  AND (Appl.ApStatus = 'p' OR Appl.ApStatus = 'w')
  AND dbo.Appl.CLNO not in (3468,2135) 
  AND (dbo.crim.IsHidden = 0 ) -- Added this by Santosh on 06/24/13 to exclude BAD APPS and unused searches
GROUP BY dbo.Iris_Researchers.R_Name, dbo.Iris_Researchers.R_Firstname, dbo.Crim.b_rule, dbo.Iris_Researchers.R_Lastname, 
		 ISNULL(dbo.Crim.readytosend, 0) , dbo.Iris_Researchers.R_id , dbo.Iris_Researchers.R_Delivery, dbo.Crim.CNTY_NO,
		dbo.Counties.A_County,dbo.Counties.State, dbo.Crim.IRIS_REC
order by min(dbo.Crim.CrimID)

SET NOCOUNT OFF
SET TRANSACTION ISOLATION LEVEL READ COMMITTED





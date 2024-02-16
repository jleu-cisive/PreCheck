﻿CREATE PROCEDURE [dbo].[Iris_Ordered_Pending] AS
-- Ordered Pending 

SELECT     dbo.Crim.status, dbo.Crim.Ordered, dbo.Iris_Researchers.R_Name AS vendor, dbo.Iris_Researchers.R_Delivery, 
                      dbo.Crim.CNTY_NO, dbo.Iris_Researchers.R_id AS vendorid, dbo.Iris_Researchers.R_Firstname, dbo.Iris_Researchers.R_Lastname, 
                      dbo.Crim.batchnumber, dbo.Crim.IRIS_REC, CONVERT(numeric(7, 2), dbo.ElapsedBusinessDays(dbo.Crim.Ordered, GETDATE())) AS Elapsed, 
                      dbo.Counties.A_County, dbo.Counties.State, dbo.Counties.A_County + ' , ' + dbo.Counties.State AS county
FROM         dbo.Appl WITH (NOLOCK) INNER JOIN
                      dbo.Crim WITH (NOLOCK) ON dbo.Appl.APNO = dbo.Crim.APNO INNER JOIN
                      dbo.Counties WITH (NOLOCK) ON dbo.Crim.CNTY_NO = dbo.Counties.CNTY_NO LEFT OUTER JOIN
                      dbo.Iris_Researchers WITH (NOLOCK) ON dbo.Crim.vendorid = dbo.Iris_Researchers.R_id
WHERE     (dbo.Crim.IRIS_REC = 'yes') AND (dbo.Crim.Clear = 'O') AND (dbo.Appl.ApStatus = 'p' OR
                      dbo.Appl.ApStatus = 'w')
					  and dbo.Appl.CLNO not in (3468) and (dbo.crim.IsHidden = 0 ) -- Added this by Santosh on 06/24/13 to exclude BAD APPS and unused searches
GROUP BY dbo.Crim.status, dbo.Crim.Ordered, dbo.Iris_Researchers.R_Name, dbo.Iris_Researchers.R_Firstname, dbo.Iris_Researchers.R_Lastname, 
                      dbo.Crim.batchnumber, dbo.Iris_Researchers.R_id, dbo.Iris_Researchers.R_Delivery, dbo.Crim.County, dbo.Crim.IRIS_REC, dbo.Crim.CNTY_NO, 
                      dbo.Counties.A_County, dbo.Counties.State
HAVING      (NOT (dbo.Crim.batchnumber IS NULL))
ORDER BY CONVERT(numeric(7, 2), dbo.ElapsedBusinessDays(dbo.Crim.Ordered, GETDATE())) desc
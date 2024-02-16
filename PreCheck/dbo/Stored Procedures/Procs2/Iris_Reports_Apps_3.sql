CREATE PROCEDURE Iris_Reports_Apps_3 AS

-- Iris Applications that are 3 days old

SELECT      dbo.Crim.CrimID, dbo.Crim.status, dbo.Crim.Ordered, dbo.Iris_Researchers.R_Name AS vendor, appl.apno,
                      dbo.Iris_Researchers.R_id AS vendorid, dbo.Crim.batchnumber, dbo.Appl.ApStatus, dbo.Crim.IRIS_REC, CONVERT(numeric(7, 2), 
                      dbo.ElapsedBusinessDays(dbo.Crim.Ordered, GETDATE())) AS Elapsed, dbo.Counties.A_County + ' , ' + dbo.Counties.State AS county, dbo.Client.Name, 
                      dbo.Appl.[Last], dbo.Appl.[First], dbo.Appl.Middle, dbo.Appl.SSN, dbo.Counties.State, dbo.Counties.A_County
FROM         dbo.Appl  WITH (NOLOCK) INNER JOIN
                      dbo.Crim  WITH (NOLOCK) ON dbo.Appl.APNO = dbo.Crim.APNO INNER JOIN
                      dbo.Counties WITH (NOLOCK) ON dbo.Crim.CNTY_NO = dbo.Counties.CNTY_NO INNER JOIN
                      dbo.Client WITH (NOLOCK) ON dbo.Appl.CLNO = dbo.Client.CLNO LEFT OUTER JOIN
                      dbo.Iris_Researchers WITH (NOLOCK) ON dbo.Crim.vendorid = dbo.Iris_Researchers.R_id
WHERE     (dbo.Crim.IRIS_REC = 'yes') AND (dbo.Crim.Clear = 'O') AND (dbo.Appl.ApStatus = 'p' OR
                      dbo.Appl.ApStatus = 'w') AND (NOT (dbo.Crim.batchnumber IS NULL))
 and (CONVERT(numeric(7, 2), 
                      dbo.ElapsedBusinessDays(dbo.Crim.Ordered, GETDATE())) = 3)
ORDER BY dbo.Crim.Ordered
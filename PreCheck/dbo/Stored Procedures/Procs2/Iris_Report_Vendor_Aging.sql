




CREATE PROCEDURE [dbo].[Iris_Report_Vendor_Aging] as


SELECT     TOP 100 PERCENT dbo.Crim.status, dbo.Crim.APNO, dbo.Crim.Ordered, dbo.Iris_Researchers.R_Name AS vendor, dbo.Iris_Researchers.R_Delivery, 
                      dbo.Appl.ApDate, dbo.Appl.PC_Time_Stamp, dbo.Appl.[Last], dbo.Appl.Middle, dbo.Appl.[First], dbo.Crim.CNTY_NO, 
                      dbo.Iris_Researchers.R_id AS vendorid, dbo.Iris_Researchers.R_Firstname, dbo.Iris_Researchers.R_Lastname, dbo.Crim.batchnumber, 
                      dbo.Appl.ApStatus, dbo.Crim.IRIS_REC, 
					  CONVERT(numeric(7, 2), dbo.ElapsedBusinessDays(convert(datetime,dbo.Crim.Crimenteredtime,1), GETDATE())) AS Elapsed, 
                      CONVERT(numeric(7, 2), dbo.ElapsedBusinessDays(convert(varchar(20),dbo.Crim.Ordered,1), GETDATE())) AS OrderedElapsed, --Radhika Dereddy on 06/25/2014 Changed the Conversion type dbo.ElapsedBusinessDays(convert(datetime,dbo.Crim.Ordered,1) datetime to varchar(14)
					  CONVERT(numeric(7, 2), dbo.ElapsedBusinessDays(convert(datetime,dbo.Appl.PC_Time_Stamp,1), GETDATE())) AS RecElapsed, 
					  dbo.Counties.A_County, dbo.Counties.State, 
                      dbo.Counties.A_County + ' , ' + dbo.Counties.State AS county, dbo.Crim.Crimenteredtime, dbo.Iris_Researcher_Charges.Researcher_Fel, 
                      dbo.Iris_Researcher_Charges.Researcher_Mis, dbo.Iris_Researcher_Charges.Researcher_fed, dbo.Iris_Researcher_Charges.Researcher_alias, 
                      dbo.Iris_Researcher_Charges.Researcher_combo, dbo.Iris_Researcher_Charges.Researcher_other, dbo.Iris_Researchers.R_Phone, 
                      dbo.Iris_Researchers.R_Fax, dbo.Client.Medical, dbo.Iris_Researcher_Avg_Turnaround.AverageTurnAround
FROM         dbo.Iris_Researcher_Avg_Turnaround WITH (NOLOCK) RIGHT JOIN
                      dbo.Iris_Researchers WITH (NOLOCK) ON dbo.Iris_Researcher_Avg_Turnaround.R_ID = dbo.Iris_Researchers.R_id RIGHT OUTER JOIN
                      dbo.Appl WITH (NOLOCK) INNER JOIN
                      dbo.Crim WITH (NOLOCK) ON dbo.Appl.APNO = dbo.Crim.APNO INNER JOIN
                      dbo.Counties WITH (NOLOCK) ON dbo.Crim.CNTY_NO = dbo.Counties.CNTY_NO LEFT OUTER JOIN
                      dbo.Client WITH (NOLOCK) ON dbo.Appl.CLNO = dbo.Client.CLNO LEFT OUTER JOIN
                      dbo.Iris_Researcher_Charges WITH (NOLOCK) ON dbo.Crim.CNTY_NO = dbo.Iris_Researcher_Charges.cnty_no AND 
                      dbo.Crim.vendorid = dbo.Iris_Researcher_Charges.Researcher_id ON dbo.Iris_Researchers.R_id = dbo.Crim.vendorid
WHERE     (dbo.Crim.IRIS_REC = 'yes') AND (dbo.Crim.Clear in ('O','W','X','I')) AND (dbo.Appl.ApStatus <> 'M')
GROUP BY dbo.Crim.status, dbo.Crim.Ordered, dbo.Iris_Researchers.R_Name, dbo.Iris_Researchers.R_Firstname, dbo.Iris_Researchers.R_Lastname, 
                      dbo.Crim.batchnumber, dbo.Appl.ApStatus, dbo.Iris_Researchers.R_id, dbo.Iris_Researchers.R_Delivery, dbo.Crim.County, dbo.Crim.IRIS_REC, 
                      dbo.Crim.CNTY_NO, dbo.Counties.A_County, dbo.Counties.State, dbo.Crim.APNO, dbo.Appl.[Last], dbo.Appl.Middle, dbo.Appl.[First], 
                      dbo.Crim.Crimenteredtime, dbo.Iris_Researcher_Charges.Researcher_Fel, dbo.Iris_Researcher_Charges.Researcher_Mis, 
                      dbo.Iris_Researcher_Charges.Researcher_fed, dbo.Iris_Researcher_Charges.Researcher_alias, dbo.Iris_Researcher_Charges.Researcher_combo, 
                      dbo.Iris_Researcher_Charges.Researcher_other, dbo.Appl.ApDate, dbo.Appl.PC_Time_Stamp, dbo.Iris_Researchers.R_Phone, 
                      dbo.Iris_Researchers.R_Fax, dbo.Client.Medical, dbo.Iris_Researcher_Avg_Turnaround.AverageTurnAround
HAVING      (dbo.Appl.ApStatus = 'p' OR
                      dbo.Appl.ApStatus = 'w') AND (NOT (dbo.Crim.batchnumber IS NULL))
ORDER BY dbo.Crim.Ordered desc





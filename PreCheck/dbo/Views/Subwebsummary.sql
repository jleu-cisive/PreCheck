CREATE VIEW dbo.Subwebsummary
AS
SELECT     dbo.Appl.APNO, dbo.Crim.Clear AS Crimclear, dbo.Crim.County AS CrimCounty, dbo.MedInteg.SectStat AS Medstatus, dbo.Empl.Employer, 
                      dbo.Empl.SectStat AS Emplstatus, dbo.Educat.SectStat AS edustatus, dbo.Educat.School, dbo.ProfLic.SectStat AS Licstatus, 
                      dbo.Credit.SectStat AS Socialstatus
FROM         dbo.Appl LEFT OUTER JOIN
                      dbo.Credit ON dbo.Appl.APNO = dbo.Credit.APNO LEFT OUTER JOIN
                      dbo.MedInteg ON dbo.Appl.APNO = dbo.MedInteg.APNO LEFT OUTER JOIN
                      dbo.Crim ON dbo.Appl.APNO = dbo.Crim.APNO LEFT OUTER JOIN
                      dbo.PersRef ON dbo.Appl.APNO = dbo.PersRef.APNO LEFT OUTER JOIN
                      dbo.ProfLic ON dbo.Appl.APNO = dbo.ProfLic.Apno LEFT OUTER JOIN
                      dbo.Empl ON dbo.Appl.APNO = dbo.Empl.Apno LEFT OUTER JOIN
                      dbo.Educat ON dbo.Appl.APNO = dbo.Educat.APNO

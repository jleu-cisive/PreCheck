CREATE VIEW dbo.Lictypebymonth
AS
SELECT     dbo.ProfLic.Lic_Type, COUNT(dbo.ProfLic.Lic_Type) AS thecount
FROM         dbo.Appl LEFT OUTER JOIN
                      dbo.ProfLic ON dbo.Appl.APNO = dbo.ProfLic.Apno
WHERE     (dbo.Appl.ApDate BETWEEN CONVERT(DATETIME, '2002-01-01 00:00:00', 102) AND CONVERT(DATETIME, '2002-01-31 00:00:00', 102))
GROUP BY dbo.Appl.CLNO, dbo.ProfLic.Lic_Type
HAVING      (dbo.Appl.CLNO = 1629)

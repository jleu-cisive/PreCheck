CREATE PROCEDURE Bis3_CrimReportSummary @apno int AS

SELECT     MAX(dbo.Crimsectstat.LevelOfImportance) AS Expr1, dbo.Crimsectstat.crimdescription
FROM         dbo.Crimsectstat INNER JOIN
                      dbo.Crim ON dbo.Crimsectstat.crimsect = dbo.Crim.Clear
WHERE     (dbo.Crim.APNO = @apno)
GROUP BY dbo.Crimsectstat.crimdescription
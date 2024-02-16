CREATE PROCEDURE Bis3_CivilReportSummary @apno int  AS


SELECT     MAX(dbo.Crimsectstat.LevelOfImportance) AS Expr1, dbo.Crimsectstat.crimdescription
FROM         dbo.Crimsectstat INNER JOIN
                      dbo.Civil ON dbo.Crimsectstat.crimsect = dbo.Civil.Clear
WHERE     (dbo.Civil.APNO = @apno)
GROUP BY dbo.Crimsectstat.crimdescription
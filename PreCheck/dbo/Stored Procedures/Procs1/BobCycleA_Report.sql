CREATE PROCEDURE BobCycleA_Report AS


SELECT     dbo.Client.Name, dbo.Client.BillCycle, dbo.InvMaster.Sale, dbo.InvMaster.Tax, dbo.InvMaster.InvDate, dbo.Client.CLNO, 
                      dbo.Appl.CompDate, dbo.InvDetail.Description, dbo.Appl.APNO, dbo.Appl.[Last], dbo.Appl.[First], dbo.Appl.Middle
FROM         dbo.Client INNER JOIN
                      dbo.InvMaster ON dbo.Client.CLNO = dbo.InvMaster.CLNO INNER JOIN
                      dbo.Appl ON dbo.Client.CLNO = dbo.Appl.CLNO INNER JOIN
                      dbo.InvDetail ON dbo.InvMaster.InvoiceNumber = dbo.InvDetail.InvoiceNumber AND dbo.Appl.APNO = dbo.InvDetail.APNO
WHERE     (dbo.Client.BillCycle = 'a') AND (dbo.InvMaster.InvDate = CONVERT(DATETIME, '2003-05-31 00:00:00', 102))
ORDER BY dbo.Client.Name

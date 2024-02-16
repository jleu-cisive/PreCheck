CREATE PROCEDURE B_invoice_summary  AS
--Requested by bruce 11/1/2002

SELECT   D.APNO, D.Amount, D.Description, D.Type, D.InvDetID, APPL.ApStatus, APPL.[Last], APPL.[First], APPL.Middle, APPL.CompDate, 
                      APPL.CLNO, APPL.Update_Billing, CLIENT.Name, CLIENT.Addr1, CLIENT.Addr2, CLIENT.Addr3, CLIENT.TaxRate, CLIENT.BillCycle
FROM         dbo.InvDetail D INNER JOIN
                      dbo.Appl APPL ON D.APNO = APPL.APNO INNER JOIN
                      dbo.Client CLIENT ON APPL.CLNO = CLIENT.CLNO
WHERE     (D.Billed = 0) AND (APPL.ApStatus = 'F') AND (APPL.CompDate <= 'Jan 31, 2003 12:00AM') AND (CLIENT.BillCycle = 'A')
ORDER BY APPL.CLNO, APPL.[Last], APPL.[First], APPL.Middle, APPL.APNO
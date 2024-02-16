
CREATE PROCEDURE [dbo].[Billing_GetInvoicesToArchive]
AS

; WITH CTE AS
(
	SELECT 
		value 
	FROM fn_split(
		(SELECT cc.[Value] FROM dbo.ClientConfiguration cc WHERE cc.ConfigurationKey = 'Billing_GroupsToArchiveInvoice'), 
		',')
)
SELECT * INTO #BillingCycles FROM CTE;

SELECT im.InvoiceNumber, c.CLNO, c.BillCycle, im.InvDate FROM dbo.InvMaster im
INNER JOIN dbo.Client c ON im.CLNO = c.CLNO
INNER JOIN #BillingCycles bc ON c.BillCycle = bc.[value]
WHERE im.Printed = 0 
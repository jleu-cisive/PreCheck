
CREATE PROCEDURE [dbo].[Billing_GetInvoicesToEmail]
AS 
; WITH CTE AS
(
	SELECT 
		value 
	FROM fn_split(
		(SELECT cc.[Value] FROM dbo.ClientConfiguration cc WHERE cc.ConfigurationKey = 'Billing_GroupsToEmailInvoice'), 
		',')
)
SELECT * INTO #BillingCycles FROM CTE;

SELECT
	im.InvoiceNumber,
	im.CLNO,
	c.BillCycle,
	im.InvDate
INTO #InvToBill
FROM dbo.InvMaster im
INNER JOIN dbo.Client c ON im.CLNO = c.CLNO
INNER JOIN #BillingCycles bc ON bc.[value] = c.BillCycle
WHERE im.Printed = 0 
ORDER BY im.CLNO DESC

; WITH CTE AS
(
	SELECT 
		nc.CLNO,
		STUFF(
			(SELECT
                        nc2.Email + ';'
					FROM Precheck_Staging.dbo.NotificationConfig nc2
                        WHERE nc.CLNO = nc2.CLNO
						AND nc2.refNotificationTypeID = 11
                        FOR XML PATH(''), TYPE
			).value('.','varchar(max)')
			, 1, 0, ''
        ) AS Emails
		FROM Precheck_Staging.dbo.NotificationConfig nc
		WHERE NC.CLNO IN (SELECT itb.CLNO FROM #InvToBill itb)
		GROUP BY nc.CLNO
)

SELECT itb.*, c.Emails FROM #InvToBill itb
LEFT JOIN CTE c ON c.CLNO = itb.CLNO

DROP TABLE #BillingCycles
DROP TABLE #InvToBill



-- Alter Procedure Billing_PassThroughCharges_Insert

-- THIS Stored Procedure is NOT USED in BILLING ANYMORE

CREATE PROCEDURE [dbo].[Billing_PassThroughCharges_Insert]
(
	@StartDate datetime
	, @EndDate datetime
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

INSERT INTO dbo.InvDetail (APNO, [Type], Subkey, SubkeyChar, Billed, InvoiceNumber, CreateDate, Description, Amount)
SELECT	C2.APNO, 2, NULL, NULL, 0, NULL, getdate(), MIN(C.A_County) + ', ' + MIN(C.State) + ' Service Charge', MIN(C.PassThroughCharge)
FROM	dbo.TblCounties C
		INNER JOIN dbo.Crim C2 ON C.CNTY_NO = C2.CNTY_NO
			AND C.PassThroughCharge > 0
			--AND C2.IrisOrdered BETWEEN @StartDate AND DATEADD(d, 1, @EndDate)
		INNER JOIN dbo.Appl A ON C2.APNO = A.APNO
		INNER JOIN dbo.Client Cl ON Cl.CLNO = A.CLNO
			--AND Cl.BillCycle <> 'P'
			--AND Cl.BillingCycleID <> 6
			AND A.Billed = 0
GROUP BY C2.APNO, C2.CNTY_NO

SET NOCOUNT OFF
SET TRANSACTION ISOLATION LEVEL READ COMMITTED

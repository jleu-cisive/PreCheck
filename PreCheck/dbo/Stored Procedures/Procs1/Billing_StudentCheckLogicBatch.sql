-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Billing_StudentCheckLogicBatch]
	-- Add the parameters for the stored procedure here		
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


INSERT INTO dbo.InvDetail (APNO, [Type], Subkey, SubkeyChar, Billed, InvoiceNumber, CreateDate, Description, Amount)
SELECT	a.APNO, 11, NULL, NULL, 0, NULL, getdate(), 'Student Check Discount', 
case when CAST(ISNULL(cc.value,'0') As smallmoney) > 0 then - CAST(cc.value As smallmoney)
	when scc.studentcheckdiscount is not null and ISNULL(scc.studentcheckdiscount,0) > 0 then - scc.studentcheckdiscount
	ELSE 0 END
FROM	clientconfiguration cc2 
		INNER JOIN dbo.Client Cl ON Cl.CLNO = cc2.clno AND cc2.configurationkey = 'Billing_SC_DiscountActive' AND ISNULL(cc2.Value,'') = 'True'
		INNER JOIN appl a ON Cl.CLNO = a.CLNO
		INNER JOIN dbo.appl b ON a.ssn = b.ssn		
		INNER JOIN dbo.client cb on cb.clno = b.clno
		LEFT JOIN clientconfiguration cc on cc.clno = cl.clno AND cc.configurationkey = 'Billing_SC_Discount'
		LEFT JOIN statediscount scc on scc.state = cl.state
		WHERE			
			(a.enteredvia <> 'StuWeb' and ISNULL(Cl.clienttypeid,1) NOT IN (6,8,9,11,12,13))
			AND (b.enteredvia = 'StuWeb' or ISNULL(cb.clienttypeid,1) IN (6,8,9,11,12,13))			
			AND Cl.BillCycle <> 'P'
			AND Cl.BillingCycleID <> 6			
			AND A.Billed = 0
			AND (SELECT sum(amount) from invdetail where apno = a.apno and billed = 0) + 
(case
 when (CAST(ISNULL(cc.value,'0') As smallmoney) > 0) then - CAST(cc.value As smallmoney)
	when scc.studentcheckdiscount is not null and ISNULL(scc.studentcheckdiscount,0) > 0 then - scc.studentcheckdiscount ELSE 0 END) >= 0
			AND ((scc.studentcheckdiscount is not null and ISNULL(scc.studentcheckdiscount,0) > 0) or (CAST(ISNULL(cc.value,'0') As smallmoney) > 0))

GROUP BY A.APNO,cc.value,scc.studentcheckdiscount



SET NOCOUNT OFF
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
END

















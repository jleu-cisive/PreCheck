











-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Billing_StudentCheckLogic]
	-- Add the parameters for the stored procedure here
		
	@CLNO smallint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @Discount smallmoney,@SVALUE varchar(50);
SET @Discount = 0.00;
--set discount to default state discount
SET @Discount = ISNULL((SELECT studentcheckdiscount from statediscount sd inner join client c on sd.state = c.state and c.clno = @CLNO),0);
--pull clientconfiguration discount if it exists then overide discount price
SET @SVALUE = ISNULL((SELECT Value FROM clientconfiguration where configurationkey = 'Billing_SC_Discount' and clno = @CLNO),'');
SET @SVALUE = LTRIM(RTRIM(@SVALUE));
IF LEN(@SVALUE) > 0
	SET @Discount = CAST(@SVALUE As smallmoney);
SET @SVALUE = ISNULL((SELECT Value FROM clientconfiguration where configurationkey = 'Billing_SC_DiscountActive' and clno = @CLNO),'');
IF LTRIM(RTRIM(@SVALUE)) <> 'True'
	SET @Discount = 0;
IF @Discount > 0	
BEGIN
SET @Discount = -(@Discount);
INSERT INTO dbo.InvDetail (APNO, [Type], Subkey, SubkeyChar, Billed, InvoiceNumber, CreateDate, Description, Amount)
SELECT	a.APNO, 11, NULL, NULL, 0, NULL, getdate(), 'Student Check Discount', @Discount
FROM	appl a 
		INNER JOIN dbo.appl b ON a.ssn = b.ssn
		INNER JOIN dbo.Client Cl ON Cl.CLNO = a.CLNO
		INNER JOIN dbo.client cb on cb.clno = b.clno
			AND (a.enteredvia <> 'StuWeb' and ISNULL(Cl.clienttypeid,1) NOT IN (6,8,9,11,12,13))
			AND (b.enteredvia = 'StuWeb' or ISNULL(cb.clienttypeid,1) IN (6,8,9,11,12,13))	
			AND Cl.BillCycle <> 'P'
			AND Cl.BillingCycleID <> 6
			AND Cl.CLNO = @CLNO
			AND A.Billed = 0
			AND (SELECT sum(amount) from invdetail where apno = a.apno and billed = 0) + @Discount >= 0
			
GROUP BY a.APNO
END
SET NOCOUNT OFF
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
END













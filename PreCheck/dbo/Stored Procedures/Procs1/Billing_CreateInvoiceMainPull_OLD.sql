-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Billing_CreateInvoiceMainPull_OLD] 
	-- Add the parameters for the stored procedure here
	@CutOffDate datetime,@BillingCycle char(1)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SELECT D.APNO , D.AMOUNT ,  D.DESCRIPTION ,D.Type, D.InvDetID,APPL.APSTATUS ,  APPL.LAST , APPL.FIRST , APPL.MIDDLE,
APPL.COMPDATE ,  APPL.CLNO, appl.update_billing, APPL.DeptCode,CLIENT.NAME ,  CLIENT.ADDR1 , CLIENT.ADDR2 ,
      CLIENT.CITY, CLIENT.STATE, CLIENT.ZIP , CLIENT.TAXRATE ,  CLIENT.IsTaxExempt  , refBC.BillingCycle as BillingCycle
 FROM InvDetail D , APPL APPL ,  CLIENT CLIENT,  refBillingCycle refBC
 WHERE ( D.APNO = APPL.APNO )  AND  ( APPL.CLNO = CLIENT.CLNO )
 AND ( ( ( D.Billed = 0 ) AND  ( ( ( APPL.APSTATUS = 'F' )
 AND ( APPL.COMPDATE < @CutOffDate ) )  OR ( APPL.APSTATUS = 'W' ) )
 AND  ( refBC.BillingCycleID = client.BillingCycleID)
 AND (refBC.BILLingCYCLE = @BillingCycle ) ) )
 ORDER BY APPL.CLNO , appl.last, appl.first, appl.middle, appl.apno , D.TYPE

SET NOCOUNT OFF
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
END



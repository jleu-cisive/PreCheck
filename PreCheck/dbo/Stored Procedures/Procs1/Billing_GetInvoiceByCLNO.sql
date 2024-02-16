
-- =============================================
-- Author:		<Radhika Dereddy>
-- Create date: <10/25/2013>
-- Description:	<returns the Invocie pdf for a particular CLNo and InvoiceNumber>
-- =============================================
CREATE PROCEDURE [dbo].[Billing_GetInvoiceByCLNO]
	-- Add the parameters for the stored procedure here
	@CLNO int,
	@InvoiceNumber int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON;
    
	SELECT pdf FROM dbo.BillingInvoice where CLNO = @CLNO and InvoiceNumber = @InvoiceNumber 


	
SET NOCOUNT OFF

END





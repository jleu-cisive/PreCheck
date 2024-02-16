-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 10/31/2013
-- Description:	Insert Client Invoices split by CLNO
-- =============================================

CREATE PROCEDURE [dbo].[Billing_InsertorUpdateInvoice]
  @CLNO smallint,
  @InvoiceNumber int,
  @InvDate datetime,
  @BillingCycle char(2),
  @pdf image
 
as
  set nocount on
	IF Exists(SELECT CLNO, InvoiceNumber FROM dbo.BillingInvoice WHERE CLNO=@CLNO and InvoiceNumber =@InvoiceNumber)
    BEGIN
		UPDATE dbo.BillingInvoice SET InvDate =@InvDate, BillingCycle =@BillingCycle, pdf =@pdf
		WHERE CLNO=@CLNo and InvoiceNumber =@InvoiceNumber
	END

	ELSE
	BEGIN
		INSERT INTO BillingInvoice
		(CLNO, InvoiceNumber, InvDate, BillingCycle, pdf)
		VALUES
		(@CLNO, @InvoiceNumber, @InvDate, @BillingCycle, @pdf)
	END




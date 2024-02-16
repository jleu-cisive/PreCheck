
CREATE PROCEDURE [dbo].[Billing_SetInvoicesToPrinted]
@Invoices varchar(max)
AS
SET NOCOUNT ON;
IF @Invoices IS NOT NULL
	BEGIN
		-- Insert statements for procedure here
		UPDATE dbo.InvMaster SET dbo.InvMaster.Printed = 1 WHERE dbo.InvMaster.InvoiceNumber IN (SELECT convert(int, value) FROM fn_split(@Invoices, ','))
	END
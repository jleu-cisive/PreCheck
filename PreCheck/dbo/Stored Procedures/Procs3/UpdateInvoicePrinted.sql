-- =============================================
-- Date: July 3, 2001
-- Author: Pat Coffer
-- =============================================
CREATE PROCEDURE UpdateInvoicePrinted
	@InvoiceNumber int
AS
SET NOCOUNT ON
UPDATE InvMaster
SET Printed = 1
WHERE InvoiceNumber = @InvoiceNumber

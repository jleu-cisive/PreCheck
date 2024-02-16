-- =============================================
-- Date: July 3, 2001
-- Author: Pat Coffer
-- =============================================
CREATE PROCEDURE UpdateInvMasterAmounts
	@InvoiceNumber int,
	@Sale smallmoney,
	@Tax smallmoney
AS
SET NOCOUNT ON
UPDATE InvMaster
SET Sale = @Sale,
    Tax = @Tax
WHERE InvoiceNumber = @InvoiceNumber

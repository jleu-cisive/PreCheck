-- =============================================
-- Date: July 3, 2001
-- Author: Pat Coffer
--
-- Date: November 7, 2001
-- Author: Pat Coffer
-- Changed table name from InvDet to InvDetail.
-- =============================================
CREATE  PROCEDURE UpdateInvDetailBilled
	@InvDetID int,
	@InvoiceNumber int
AS
SET NOCOUNT ON
UPDATE InvDetail
SET Billed = 1,
    InvoiceNumber = @InvoiceNumber
WHERE InvDetID = @InvDetID

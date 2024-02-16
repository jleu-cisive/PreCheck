-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 04/19/2018
-- Requester: Jeff Rackler
-- Description:	A user must be able to pull a Q-Report based on the invoices built through the Billing Processor/Service (INVOICE LIST Q-REPORT)
-- The report must be filtered by a date range. The report should be filtered by CLNO
-- EXEC Reconciliation_Invoice_List '03/31/2018', 9804
-- =============================================
CREATE PROCEDURE Reconciliation_Invoice_List
	-- Add the parameters for the stored procedure here
	@StartDate datetime,
	@CLNO int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT  i.Apno, i.InvoiceNumber,im.CLNO, i.Billed, i.CreateDate, i.Description, i.Amount, im.sale as 'SubTotal'
	FROM Invdetail i (NOLOCK)
	INNER JOIN InvMaster im (NOLOCK) ON i.InvoiceNumber = im.InvoiceNumber
	INNER JOIN Client C (NOLOCK) ON im.CLNO = c.CLNO
	WHERE (im.InvDate = @StartDate)
	AND im.CLNO = @CLNO

END

-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 09/24/2018
-- Description:	Create a Qreport that gives a Year to Date billing for a CLNO by facility
-- Requestor : Jeff Rackler
-- EXEC [YearToDateInvoicesForClientPerFacility] 12721,'01/01/2018','09/01/2018'
-- =============================================
CREATE PROCEDURE YearToDateInvoicesForClientPerFacility
	-- Add the parameters for the stored procedure here
	@ParentCLNO int,
	@StartDate datetime,
	@EndDate datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT C.CLNO, C.Name, im.InvoiceNumber, im.InvDate as 'InvoiceDate',im.Sale as 'SubTotal', im.Tax as 'Tax'
	FROM InvMaster im (nolock)
	INNER JOIN Client c(nolock) on im.CLNO =c.CLNO
	WHERE C.CLNO in ( SELECT CLNO FROM Client WHERE WebOrderParentCLNO = @ParentCLNO)
	AND (im.InvDate between @StartDate and @EndDate)

END

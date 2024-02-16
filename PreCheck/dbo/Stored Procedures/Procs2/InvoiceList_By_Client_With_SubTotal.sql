-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 04/26/2018
-- Description:	Gives the list of invoice numbers with CLNO, InvDate and sale.
-- =============================================
CREATE PROCEDURE InvoiceList_By_Client_With_SubTotal
	-- Add the parameters for the stored procedure here
	@StartDate datetime,
	@EndDate Datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT InvoiceNumber, CLNO, InvDate 'InvoiceDate', Sale as 'SubTotal'
	FROM Invmaster WHERE InvDate BETWEEN @StartDate AND @EndDate
END

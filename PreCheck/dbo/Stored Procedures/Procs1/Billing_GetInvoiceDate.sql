
-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 10/31/2013
-- Description:	Gets the InvoiceDate for CLNO and InvoiceNumber
-- =============================================
CREATE PROCEDURE [dbo].[Billing_GetInvoiceDate] 
	-- Add the parameters for the stored procedure here
	@CLNO int,
	@InvoiceNumber int,
	@InvoiceDate datetime OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @InvoiceDate = (SELECT InvDate FROM dbo.InvMaster WHERE CLNO=@CLNO and InvoiceNumber=@InvoiceNumber)
	--SELECT InvDate FROM dbo.InvMaster WHERE CLNO=7181 and InvoiceNumber=9104401
END



-- =============================================
-- Author:		cchaupin
-- Create date: 2/24/09
-- Description:	updates billing data with new invoicing total for manual adjustment purposes.
-- =============================================
CREATE PROCEDURE [dbo].[Billing_Rollback_UpdateInvoiceTotal]
	@Invoicenumber int,@sale decimal(18,2),@tax decimal(18,2)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @Oldsale decimal(18,2),@oldtax decimal(18,2),@newtotal decimal(18,2),@runnumber int,@diffsale decimal(18,2),@difftax decimal(18,2);
BEGIN TRANSACTION;

SET @newtotal = @sale + @tax;
SET @Oldsale = (select sale from invmaster where invoicenumber = @invoicenumber)
SET @Oldtax = (select tax from invmaster where invoicenumber =@invoicenumber)
set @runnumber = (select runnumber from invregistrar where invoicenumber = @invoicenumber)
set @diffsale = @oldsale - @sale;
SET @difftax = @oldtax - @tax;
update invmaster set sale = @sale,tax = @tax where invoicenumber = @invoicenumber
update invregistrar set sale = @sale,tax = @tax,total = @newtotal where invoicenumber = @invoicenumber
update invregistrartotal set totalsale = totalsale - (@diffsale), totaltax = totaltax - (@difftax) where runnumber = @runnumber


COMMIT TRANSACTION;
   
END


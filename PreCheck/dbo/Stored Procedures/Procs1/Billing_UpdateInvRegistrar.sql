
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Billing_UpdateInvRegistrar] 
	-- Add the parameters for the stored procedure here
	(@RunNumber int,@InvoiceNumber int,@CLNO int,@ClientName varchar(255),@CutOffDate datetime,@BillingCycle varchar(8),@Sale money,@Tax money,@Locality 
varchar(8),@Total money)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

declare @invoicedate datetime

set @invoicedate = dateadd(d,-1, @CutOffDate)
--
--    INSERT INTO InvRegistrar (RunNumber,InvoiceNumber,CLNO,ClientName,CutOffDate,BillingCycle,Sale,Tax,Locality,Total,CreatedDate)
--VALUES(@RunNumber,@InvoiceNumber,@CLNO,@ClientName,@CutOffDate,@BillingCycle,@Sale,@Tax,@Locality,@Total,getdate())


    INSERT INTO InvRegistrar (RunNumber,InvoiceNumber,CLNO,ClientName,CutOffDate,BillingCycle,Sale,Tax,Locality,Total,CreatedDate)
VALUES(@RunNumber,@InvoiceNumber,@CLNO,@ClientName,@invoicedate,@BillingCycle,@Sale,@Tax,@Locality,@Total,getdate())

SET NOCOUNT OFF
END






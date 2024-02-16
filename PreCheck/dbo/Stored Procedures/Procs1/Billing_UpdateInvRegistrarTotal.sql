
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Billing_UpdateInvRegistrarTotal] 
	-- Add the parameters for the stored procedure here
	(@RunNumber int,@InvCount int,@CutOffDate datetime,@BillingCycle varchar(8),@TotalSale money,@TotalTax money)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

declare @invoicedate datetime

set @invoicedate = dateadd(d,-1, @CutOffDate)

--    INSERT INTO InvRegistrarTotal (RunNumber,InvCount,CutOffDate,BillingCycle,TotalSale,TotalTax,CreatedDate)
--VALUES(@RunNumber,@InvCount,@CutOffDate,@BillingCycle,@TotalSale,@TotalTax,getDate())

    INSERT INTO InvRegistrarTotal (RunNumber,InvCount,CutOffDate,BillingCycle,TotalSale,TotalTax,CreatedDate)
VALUES(@RunNumber,@InvCount,@invoicedate,@BillingCycle,@TotalSale,@TotalTax,getDate())

SET NOCOUNT OFF

END










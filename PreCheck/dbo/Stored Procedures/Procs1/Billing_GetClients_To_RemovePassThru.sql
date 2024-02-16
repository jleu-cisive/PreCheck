
-- =============================================
-- Author:		Kiran miryala
-- Create date: 7/27/2012
-- Description:	Create a q reports for billing, where they decide which clients have billing this month and look for passthru charges only for those clients.

-- =============================================

Create  PROCEDURE [dbo].[Billing_GetClients_To_RemovePassThru]    
	@year as INT,
    @month as INT
   
AS
BEGIN

SELECT   i.CLNO ,InvDate, InvoiceNumber , Sale , Tax 
FROM dbo.invmaster i inner join  dbo.Billing_PassThruClients b on i.clno = b.clno
where MONTH(InvDate) = @month and Year(InvDate) = @year

END










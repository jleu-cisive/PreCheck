-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 10/15/2019
-- Description:	Qreport for StudentCheck Revenue for SalesForce for Lisa
-- EXEC StudentCheckRevenueForSalesForce '05/31/2020'
-- =============================================
CREATE PROCEDURE [dbo].[StudentCheckRevenueForSalesForce] 
	-- Add the parameters for the stored procedure here
	@InvoiceMonth datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
SELECT c.CLNO, c.Name as ClientName, rct.ClientType, rct.clienttypeid, c.BillCycle, case when c.SchoolWillPay = 0 then 'No' else 'Yes' end as SchoolWillPay,
i.APNO, i.Description, i.Amount as Revenue, i.CreateDate as InvoiceDate, case when c.IsInactive = 0 then 'True' else 'False' end as IsActiveClient,
c.LastInvDate as LastInvoiceDate
FROM InvDetail i  
INNER JOIN InvMaster im on i.InvoiceNumber = im.invoiceNumber
INNER JOIN client c on im.clno = c.clno
INNER JOIN refClientType rct on c.clienttypeid = rct.clienttypeid
WHERE --i.Type = 0
(i.type = 0 or (i.type =1 and Description in ('Service: Drug Test','Service: Immunization')))  -- included all the component charges like ds and Immunization  --kiran 6/8/2020
AND c.clienttypeid in (4,6,7,8,9,11,13) 
AND c.IsInactive =0
AND im.InvDate = EOMONTH(@InvoiceMonth)

END

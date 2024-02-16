CREATE PROCEDURE [dbo].[ReportBillByCycleDroplist] AS

select 0 BillingCycleID,  'All' BillCycle
union all
SELECT BillingCycleID , BillingCycle as BillCycle
FROM         dbo.refBillingCycle
ORDER BY BillingCycleID

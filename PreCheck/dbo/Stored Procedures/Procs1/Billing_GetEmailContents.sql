
-- ================================================
-- Date: 03/18/2014
-- Author: Radhika Dereddy
--
-- Gets the Email Contents for all the Billing Cycle whose Client Invoices are sent through Email
-- ================================================ 
CREATE PROCEDURE [dbo].[Billing_GetEmailContents]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON

	SELECT BillingCycle,EmailSubject,EmailHeader,EmailBody,EmailFooter FROM Billing_EmailContent
  
SET NOCOUNT OFF

END


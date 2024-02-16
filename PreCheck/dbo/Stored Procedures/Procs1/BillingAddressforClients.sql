-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 06/17/2020
-- Description:	Billing addresses for all active Clients 
-- =============================================
CREATE PROCEDURE BillingAddressforClients
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT c.CLNO as 'Client Number', c.Name as 'Client Name', ra.Affiliate as 'Affiliate Name',
	CONCAT(c.BillingAddress1, C.BillingAddress2) as Address, C.BillingCity as City,
	c.BillingState as State, c.BillingZip as Zip
	FROM CLIENT C
	INNER JOIN refAffiliate ra on C.AffiliateID = ra.AffiliateID
	WHERE C.IsInActive = 0 


END

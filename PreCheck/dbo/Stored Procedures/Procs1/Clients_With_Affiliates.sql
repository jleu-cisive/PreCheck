-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 07/26/2017
-- Description:	Get all the Affiliate names and Id's for the Clients
-- =============================================
CREATE PROCEDURE Clients_With_Affiliates
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select clno,name,r.affiliate,r.affiliateID, c.cam, c.state, c.IsInActive 
	from client c with (nolock) 
	inner join refaffiliate r with (nolock)	on c.affiliateid = r.affiliateid
	Order by CLNO ASC

END

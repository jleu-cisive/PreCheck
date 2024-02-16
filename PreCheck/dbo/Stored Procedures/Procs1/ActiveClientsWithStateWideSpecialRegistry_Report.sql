-- =============================================
-- Author:		<Amy Liu>
-- Create date: <04/12/2018>
-- Description:	<Active Clients with statewide and special registries information>
-- Query get from SP: WS_ClientMaster
-- =============================================
CREATE PROCEDURE [dbo].[ActiveClientsWithStateWideSpecialRegistry_Report]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		SELECT c.CLNO, c.Name, c.City, c.[State],  rct.ClientType ,ra.Affiliate, sw.Description AS Statewide, S.Description as SpecialReg
		 FROM client  c with(nolock)
		LEFT JOIN dbo.refRequirementText rrt  with(nolock) ON c.CLNO = rrt.CLNO	
		LEFT JOIN [dbo].[refStatewide]  sw ON rrt.StatewideID = sw.StateWideID
		LEFT JOIN dbo.refStatewide S WITH(NOLOCK) ON S.StateWideID =rrt.SpecialRegID
		left join refAffiliate ra with (nolock) on c.AffiliateID = ra.AffiliateID 
		LEFT JOIN dbo.refClientType rct with(nolock) ON c.ClientTypeID = rct.ClientTypeID and rct.ClientType<>'Medical-StudentCheck'
		WHERE c.NonClient	=0 and c.isinactive = 0
	    ORDER BY  c.name
END



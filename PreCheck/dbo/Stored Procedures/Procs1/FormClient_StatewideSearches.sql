

-- ================================================
-- Date: 06/09/20147
-- Author: Radhika Dereddy
--
-- FormClient in OASIS to fill the drop downs (Special registries, federal, Civil, Statewide)
-- ================================================ 
CREATE PROCEDURE [dbo].[FormClient_StatewideSearches]
	@SearchID int
AS
SET NOCOUNT ON


SELECT rsw.Description, rsw.StatewideID  From refStatewide rsw 
inner join refStatewideSearches rss on rsw.StatewideSearchID = rss.StatewideSearchID 
Where rss.StatewideSearchID = @SearchID
Order by rsw.Description
   


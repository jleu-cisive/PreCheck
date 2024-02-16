-- =====================================================================
-- Author:		Radhika Dereddy
-- Modified date: 08/02/2017
-- Description:	Added a new column ParentCLNo and WebOrderParentCLNO
-- EXEC GetClientCAMAssignment '9/1/2000','9/24/2019'
-- Modified by: Radhika Dereddy on 10/09/2019
-- Changed the Group by clause and the Count(*) Volume.
-- Modified by: Prasanna on 10/26/2019 for HDT#59915 Missing accounts 
-- ==================================================================
CREATE PROCEDURE [dbo].[GetClientCAMAssignment] 
	-- Add the parameters for the stored procedure here
	@StartDate date,
	@EndDate date
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
select c.Name, c.CLNO, c.State, r.Affiliate, c.ParentCLNO, c.WebOrderParentCLNO, Max(a.Apdate)as [LastDateOfActivity], c.CAM, 
(select max(a2.apdate) from Appl a2 with (nolock) where a2.clno = c.clno and a2.UserID = c.CAM and a2.Apdate IS NOT NULL) as [CAMAssigned], 
count(c.CLNO) as Volume
from Client c 
left outer join appl a on c.CLNO = a.CLNO
inner join refaffiliate r on c.AffiliateID = r.AffiliateID
where NOT(c.IsInactive = 1)
--and a.apdate is not NULL
--and (convert(date, a.ApDate) >= convert(date,@StartDate) AND (convert(date, a.ApDate) <= convert(date,@EndDate)))
and ((convert(date, a.ApDate) >= convert(date,@StartDate) AND (convert(date, a.ApDate) <= convert(date,@EndDate))) OR apdate is null)
GROUP BY c.Name, c.CLNO, r.Affiliate, c.ParentCLNO, c.WebOrderParentCLNO, c.CAM, c.[State]
order by c.CLNO

END

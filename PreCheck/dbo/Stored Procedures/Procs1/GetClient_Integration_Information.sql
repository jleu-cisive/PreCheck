-- =============================================
-- Author:		Douglas Degenaro
-- Modified date: 08/02/2019
-- Description:	Report to identify integration clients
-- EXEC [dbo].[GetClient_Integration_Information] '08/01/2019','06/01/2020'
-- =============================================
CREATE PROCEDURE [dbo].[GetClient_Integration_Information]
	@StartDate date = '08/01/2019',
	@EndDate date = '06/02/2020'
AS
BEGIN

	SET NOCOUNT ON;
	
	select c.Name, c.CLNO, c.State, r.Affiliate, c.ParentCLNO, c.WebOrderParentCLNO,
	COALESCE(c.password,COALESCE((select password from dbo.client c1 where clno = c.weborderparentclno),(select password from dbo.client c1 where clno = c.ParentCLNO)),'Not Set') as [Web Service Password],
	(select Max(a1.Apdate) from Appl a1 with (nolock) where a1.clno = c.clno and a1.Apdate IS NOT NULL) as [LastDateOfActivity], c.CAM, 
	(select max(a2.apdate) from Appl a2 with (nolock) where a2.clno = c.clno and a2.UserID = c.CAM and a2.Apdate IS NOT NULL) as [CAMAssigned], 
	(select Top(1) Userid from Appl a3 with (nolock) where a3.CLno = c.CLNO and a3.UserID <> c.CAM and a3.Apdate IS NOT NULL) as [PriorCAM], 
	(select count(*) from Appl a4 with (nolock) where a4.CLNO = c.CLNO and (convert(date, a4.ApDate) >= convert(date,@StartDate)) AND (convert(date, a4.ApDate) <= convert(date,@EndDate))) as Volume
	from Client c
	inner join refaffiliate r on c.AffiliateID = r.AffiliateID
	where NOT(c.IsInactive = 1)
	order by c.CLNO

END

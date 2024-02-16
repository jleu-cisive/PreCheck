-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 09/14/2018
-- Description:	New Report for Accounting Department dont change this report.
-- EXEC Revenue_By_CLNO '08/01/2018','09/01/2018'
-- Modified by Radhika Dereddy on 09/17/2018 to add Revenue w/o Pass Thru Fees, Package Revenue
-- Modified by Sahithi Gangaraju on 10/05/2020 to add Affiliate column HDT :79291
-- =============================================
CREATE PROCEDURE [dbo].[Revenue_By_CLNO]
	  @StartDate datetime,
	@EndDate datetime
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    Select C.CLNO, C.Name as ClientName, r.Affiliate , C.State,
	(select sum(sale) from invmaster where clno = C.clno and invdate >= @STARTDATE and invdate < @ENDDATE) as Revenue,
	(select sum(i.amount) from invdetail i inner join invmaster im on i.invoicenumber = im.invoicenumber
		where im.invoicenumber in (select invoicenumber from invmaster where clno = c.clno and invdate >= @STARTDATE and invdate < @ENDDATE)
		and i.type <> 1 and i.description not like '%service charge%'
	) as 'Revenue w/o Pass Thru Fees',
	(select sum(i.amount) from invdetail i inner join invmaster im on i.invoicenumber = im.invoicenumber
	  where im.invoicenumber in (select invoicenumber from invmaster where clno = c.clno and invdate >= @STARTDATE and invdate < @ENDDATE)
	  and i.type = 0
	)as 'Package Revenue'
	from Client C (nolock) inner join refAffiliate r on c.AffiliateID=r.AffiliateID
	WHERE C.State in ('CO', 'WY')	
	order by CLNO 


END

-- =============================================
-- Author:	Radhika Dereddy
-- Create date: 03/11/2020
-- Description:	Report for Lisa
-- EXEC [SalesForceRevenue] '2020', '2'
-- =============================================
CREATE PROCEDURE [dbo].[SalesForceRevenue]
	-- Add the parameters for the stored procedure here
	@year varchar(4),
	@month varchar(2)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
select distinct
c.Name as 'Client Name',
c.clno as 'Client Number',
c.cam as 'CAM',
rc.clienttype as 'Client Type',
c.billcycle as 'Current Billing Cycle',
c.LastInvDate as 'Last Invoice Date',
 CASE WHEN c.IsInactive = 1 then 'InActive'
	  WHEN c.isoncredithold  = 1 then 'Is On Credit Hold'
	  WHEN c.nonclient = 1 then 'NonClient'
	 else 'NoActivity' end As 'Client Status',
(select sum(sale) from invmaster (nolock) where clno = c.clno and month(invdate)=@month and year(invdate) =@year) as 'Revenue FEB Current Year',
(SELECT count(*) from appl (nolock) where clno = c.clno and year(apdate) = @year  and isnull(precheckchallenge,0) = 0)  as 'Total Applications for Current Year YTD',
(select min(apdate) from appl (nolock) where clno = c.clno and isnull(precheckchallenge,0) = 0 ) as  'First Application Date',
(select max(apdate) from appl (nolock) where clno = c.clno and isnull(precheckchallenge,0) = 0 ) as 'Last Application Date'
from client c (nolock)
Inner join refclienttype rc (nolock) on c.clienttypeid = rc.clienttypeid
inner join refaffiliate ra on c.affiliateid = ra.affiliateid
inner join InvMaster im on c.CLNO = im.CLNO
where year(im.invdate) =@year
Order by c.CLNO asc


END

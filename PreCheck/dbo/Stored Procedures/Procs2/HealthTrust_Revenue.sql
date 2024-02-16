-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 06/29/2017
-- Description:	HealthTrust Revenue QReport
-- =============================================
CREATE PROCEDURE HealthTrust_Revenue
	-- Add the parameters for the stored procedure here
	  @STARTDATE datetime,
	  @ENDDATE datetime

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

		select c.clno as ClientID,c.name as ClientName,r.clienttype as ClientType,c.addr1 as Address,c.city,c.state,
			(select sum(sale) from invmaster with (nolock) where clno = c.clno and invdate >= @STARTDATE and invdate < @ENDDATE) as Revenue,
			 (select sum(i.amount) from invdetail i inner join invmaster im on i.invoicenumber = im.invoicenumber
				   where im.invoicenumber in (select invoicenumber from invmaster where clno = c.clno and invdate >= @STARTDATE and invdate < @ENDDATE)  
				   and i.type <> 1 and i.description not like '%service charge%') as 'Revenue w/o Pass Thru Fees',
		   (select sum(i.amount) from invdetail i inner join invmaster im on i.invoicenumber = im.invoicenumber 
				 where im.invoicenumber in (select invoicenumber from invmaster where clno = c.clno and invdate >= @STARTDATE and invdate < @ENDDATE)  
				 and i.type = 0) as 'Package Revenue'
	    from client c with(nolock)
		left join refclienttype r on c.clienttypeid = r.clienttypeid  
		where c.clno in (select clno from clientgroup where groupcode = 0)     
		order by c.CLNO     
END

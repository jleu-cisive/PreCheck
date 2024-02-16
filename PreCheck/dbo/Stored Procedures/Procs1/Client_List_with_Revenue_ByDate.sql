-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 09/11/2018 (old report do not know he author)
-- Description:	Create a stored procedure from an inline query
-- EXEC Client_List_with_Revenue_ByDate '08/01/2018','08/31/2018'
-- =============================================
CREATE PROCEDURE [dbo].[Client_List_with_Revenue_ByDate]
	-- Add the parameters for the stored procedure here
	@StartDate datetime,
	@EndDate datetime

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


select c.clno as ClientID,c.name as ClientName,r.clienttype as ClientType,c.addr1 as Address,c.city [City],c.state [State],
--(select sum(sale) from invmaster where clno = c.clno and invdate >= @STARTDATE and invdate < @ENDDATE) as Revenue,
(select Sum(Amount) from invdetail where apno in (
select Apno from invmaster im  inner join invdetail i on  i.invoicenumber = im.invoicenumber
where CLNO = c.clno and invdate >=@STARTDATE and invdate < @ENDDATE ) ) as Revenue,
(select sum(i.amount) from invdetail i inner join invmaster im on i.invoicenumber = im.invoicenumber
where im.invoicenumber in (select invoicenumber from invmaster where clno = c.clno and invdate >= @STARTDATE and invdate < @ENDDATE)
and i.type <> 1 and i.description not like '%service charge%') as 'Revenue w/o Pass Thru Fees',
(select sum(i.amount) from invdetail i inner join invmaster im on i.invoicenumber = im.invoicenumber
where im.invoicenumber in (select invoicenumber from invmaster where clno = c.clno and invdate >= @STARTDATE and invdate < @ENDDATE)
and i.type = 0)as 'Package Revenue',
(select count(distinct i.apno) from invdetail i inner join invmaster im on i.invoicenumber = im.invoicenumber
where im.invoicenumber in (select invoicenumber from invmaster where clno = c.clno and invdate >= @STARTDATE and invdate < @ENDDATE)
and i.type = 0) as Appcount

from client c
left join refclienttype r on c.clienttypeid = r.clienttypeid




	/* Commented by Radhika Dereddy on 10/02/2018*/
--select c.clno as ClientID,c.name as ClientName,rf.Affiliate,rf.Affiliateid,c.addr1 as Address,c.city,c.state,--r.clienttype as ClientType,

--(select Sum(Amount) from invdetail where apno in (
--select Apno from invmaster im  inner join invdetail i on  i.invoicenumber = im.invoicenumber
--where CLNO = @CLNO and invdate >=@STARTDATE and invdate < @ENDDATE and  P.PackageID = Subkey ) ) as Revenue,

--(select sum(i.amount)  from invdetail i 
--where APno in (select Apno from invmaster im  inner join invdetail i on  i.invoicenumber = im.invoicenumber where CLNO =  @CLNO  and invdate >= @STARTDATE and invdate < @ENDDATE and  P.PackageID = Subkey)
--and i.type <> 1 and i.description not like '%service charge%'  
--) as 'Revenue w/o Pass Thru Fees',

--(select sum(i.amount) from invdetail i inner join invmaster im on i.invoicenumber = im.invoicenumber
--where im.invoicenumber in (select invoicenumber from invmaster where CLNO = @CLNO  and invdate >= @STARTDATE and invdate < @ENDDATE)
--and i.type = 0 and i.Subkey = id.Subkey)as 'Package Revenue',

--(select count(distinct i.apno) from invdetail i inner join invmaster im on i.invoicenumber = im.invoicenumber
--where im.invoicenumber in (select invoicenumber from invmaster where CLNO =  @CLNO and invdate >= @STARTDATE and invdate < @ENDDATE)
--and i.type = 0 and i.Subkey = id.Subkey) as Appcount

--from PackageMain P (nolock)
--inner join invdetail id on  P.PackageID = id.Subkey
--inner join invmaster imm on id.invoicenumber = imm.invoicenumber
--inner join Appl a (nolock) on id.apno = a.apno
--inner join CLient c (nolock) on  a.clno = c.clno
--inner join refAffiliate rf (nolock) on c.AffiliateID =rf.AffiliateID
----left join refclienttype r (nolock) on c.clienttypeid = r.clienttypeid
--WHERE Imm.clno = @clno
--OR c.AffiliateID = IIF(@AffiliateID=0,C.AffiliateID,@AffiliateID)
--group by c.clno,c.name,rf.Affiliate,rf.Affiliateid,c.addr1,c.city,c.state,p.PackageID,p.PackageDesc,id.Subkey--r.clienttype,

END

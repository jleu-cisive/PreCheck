-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--exec [dbo].[HCOTX_Revenue] '01/28/2015','04/02/2015'

CREATE PROCEDURE  [dbo].[HCOTX_Revenue]
    @StartDate datetime,
    @Enddate datetime
AS
BEGIN

          select c.clno as ClientID,c.name as ClientName,r.clienttype as ClientType,c.addr1 as Address,c.city,c.state,
            (select sum(sale) from invmaster with (nolock) where clno = c.clno and invdate >= @STARTDATE and invdate < @ENDDATE) as Revenue,
              (select sum(i.amount) from invdetail i inner join invmaster im on i.invoicenumber = im.invoicenumber
                where im.invoicenumber in (select invoicenumber from invmaster
                 where clno = c.clno and invdate >= @STARTDATE and invdate < @ENDDATE)  and i.type <> 1 and 
                 i.description not like '%service charge%') as 'Revenue w/o Pass Thru Fees',
                   (select sum(i.amount) from invdetail i inner join invmaster im on i.invoicenumber = im.invoicenumber 
                    where im.invoicenumber in (select invoicenumber from invmaster
                     where clno = c.clno and invdate >= @STARTDATE and invdate < @ENDDATE)  and i.type = 0) as 'Package Revenue'   from client c with(nolock)
     left join refclienttype r on c.clienttypeid = r.clienttypeid  where c.clno in
     (select clno from clientgroup where groupcode = 1 and clno in(7534,7532,7439,10287,10679,1617,1618,1619,1620,1616,1064,1087,1622,1064,1621,1619,1057,1352,7724,7726,2179,11115,9098,9006,5593,1629,2496,2497))
     
order by c.CLNO     
END

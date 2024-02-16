-- ================================================
-- Date: 03/13/2014
-- Author: Radhika Dereddy
-- EXEC [Client_with_Revenue_ByPackages_ByDate] 3115,125,'01/01/2018','01/31/2018'
/* Modified By: Vairavan A
-- Modified Date: 06/28/2022
-- Description: Main Ticketno-53763 
Modify existing q-reports that have affiliate ids in their search parameters
Details: 
Change search parameters for the Affiliate Id field
     * search by multiple affiliate ids (ex 4:297)
     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates
     * multiple affiliates to be separated by a colon  
Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0)

Subticket id -54476 Update AffiliateID Parameter 130-429
*/
---Testing
/*
EXEC [Client_with_Revenue_ByPackages_ByDate] 3115,'0','01/01/2018','01/31/2018'
EXEC [Client_with_Revenue_ByPackages_ByDate] 3115,'125','01/01/2018','01/31/2018'
EXEC [Client_with_Revenue_ByPackages_ByDate] 3115,'125:30','01/01/2018','01/31/2018'
*/
-- ================================================ 
CREATE PROCEDURE [dbo].[Client_with_Revenue_ByPackages_ByDate]
	 @clno int, 
	 --@AffiliateID int = 0,--code commented by vairavan for ticket id -54476
	 @AffiliateIDs varchar(MAX) = '0',--code added by vairavan for ticket id -54476
	 @STARTDATE datetime,
	 @ENDDATE datetime
AS
BEGIN
SET NOCOUNT ON

 
 	--code added by vairavan for ticket id -54476 starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END
	--code added by vairavan for ticket id -54476 ends

select p.PackageID, p.PackageDesc, 
(select Sum(Amount) from invdetail with(nolock) where apno in (
select Apno from invmaster im with(nolock)   inner join invdetail i with(nolock)  on  i.invoicenumber = im.invoicenumber
where clno = @clno and invdate >=@STARTDATE and invdate < @ENDDATE and  P.PackageID = Subkey ) ) as Revenue,

--(select sum(i.amount) from invdetail i inner join invmaster im on i.invoicenumber = im.invoicenumber
--where im.invoicenumber in (select invoicenumber from invmaster where clno = @clno and invdate >= @STARTDATE and invdate < @ENDDATE)
--and i.type <> 1 and i.description not like '%service charge%')

(select sum(i.amount)  from invdetail i with(nolock) --inner join invmaster im on i.invoicenumber = im.invoicenumber
where APno in (select Apno from invmaster im with(nolock)  inner join invdetail i with(nolock)  on  i.invoicenumber = im.invoicenumber 
where clno = @clno and invdate >= @STARTDATE and invdate < @ENDDATE and  P.PackageID = Subkey)
and i.type <> 1 and i.description not like '%service charge%'  
) as 'Revenue w/o Pass Thru Fees',

(select sum(i.amount)  from invdetail i with(nolock) --inner join invmaster im on i.invoicenumber = im.invoicenumber
where APno in (select Apno from invmaster im with(nolock)  inner join invdetail i with(nolock) on  i.invoicenumber = im.invoicenumber
where clno = @clno and invdate >= @STARTDATE and invdate < @ENDDATE and  P.PackageID = Subkey)
--and i.type <> 1 and i.description not like '%service charge%'  
and i.description not like 'Package:%' and Amount > 0) as 'Revenue with Pass Thru Fees',


(select sum(i.amount) from invdetail i with(nolock)  inner join invmaster im with(nolock) on i.invoicenumber = im.invoicenumber
where im.invoicenumber in (select invoicenumber from invmaster with(nolock)  where clno =@clno and invdate >= @STARTDATE and invdate < @ENDDATE)
and i.type = 0 and i.Subkey = id.Subkey)as 'Package Revenue',

(select count(distinct i.apno) from invdetail i with(nolock)  inner join invmaster im with(nolock)  on i.invoicenumber = im.invoicenumber
where im.invoicenumber in (select invoicenumber from invmaster with(nolock)  where clno = @clno and invdate >= @STARTDATE and invdate < @ENDDATE)
and i.type = 0 and i.Subkey = id.Subkey) as Appcount,cp.Rate,rf.AffiliateID
from PackageMain P  with(nolock) 
inner join invdetail id with(nolock) on  PackageID = Subkey
inner join invmaster imm with(nolock)  on id.invoicenumber = imm.invoicenumber
inner join ClientPackages cp with(nolock)  on p.PackageID = cp.PackageID and Imm.clno = cp.CLNO
inner join Appl a with(nolock) on id.apno = a.apno
inner join CLient c with(nolock) on  a.clno = c.clno
inner join refAffiliate rf with(nolock) on c.affiliateid = rf.AffiliateID
where Imm.clno = @clno
--and c.AffiliateID =IIF(@AffiliateID=0,C.AffiliateID,@AffiliateID)--code commented by vairavan for ticket id -54476
and (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -54476
group by p.PackageID,p.PackageDesc,id.Subkey,cp.Rate, rf.AffiliateID

END


  

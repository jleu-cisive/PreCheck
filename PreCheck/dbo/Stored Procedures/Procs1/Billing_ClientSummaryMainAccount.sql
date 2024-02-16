


-- [dbo].[Billing_ClientSummaryMainAccount]  9121702, 6977
-- =============================================
-- Author:		Kiran miryala
-- Create date: 2/10/2014
-- Description:	Main account pull report In billing application
-- =============================================
CREATE PROCEDURE [dbo].[Billing_ClientSummaryMainAccount] 
	-- Add the parameters for the stored procedure here
	@invoicenumber int,
	@CLNO int
AS
BEGIN

SET ANSI_WARNINGS ON
SET ARITHABORT ON


Select * into #Temp1 from invdetail i with (nolock) where type = 1 
 and invoicenumber = @invoicenumber
--check if no package
and (select count(*) from invdetail where apno = i.apno and invoicenumber = @invoicenumber and type = 0) = 0

--Select * From #Temp1

Update  #temp1
 set Description = (case when i.description like 'package: %' then I.Description else 'No Packages' end)
 from #temp1 T inner join invdetail i on T.Apno = i.Apno
 where i.Type = 0



select REPLACE(description,'Package:','') as Description,max(amount) as 'Package Price',
(select sum(amount) from invdetail with (nolock) where invoicenumber = @invoicenumber and 
apno in (select apno from invdetail with (nolock) where invoicenumber = @invoicenumber and 
description = i.description)  and (type = 1 or (type = 2 and description like '%service charge%' ))) as 'Service Charge',
(select sum(amount) from invdetail with (nolock) where invoicenumber = @invoicenumber and 
apno in (select apno from invdetail with (nolock) where invoicenumber = @invoicenumber and 
description = i.description) and type = 0 and type= 1 and not (type = 2 and description like '%service charge%') and amount= 0) as 'AdditionalItem',
count(*) as Quantity,
(select sum(amount) from invdetail with (nolock) where invoicenumber = @invoicenumber and apno in (select apno from invdetail with (nolock) where invoicenumber = @invoicenumber and description = i.description)) as 'Sub Total',
((select sum(amount) from invdetail with (nolock) where invoicenumber = @invoicenumber and apno in (select apno from invdetail where invoicenumber = @invoicenumber and description = i.description)) * (select r.taxrate from reftaxrate r inner join client c on c.taxrateid = r.taxrateid where c.clno = @CLNO) * .01) as Tax,
((select sum(amount) from invdetail with (nolock) where invoicenumber = @invoicenumber and apno in (select apno from invdetail where invoicenumber = @invoicenumber and description = i.description))+ ((select sum(amount) from invdetail with (nolock) where invoicenumber = @invoicenumber and apno in (select apno from invdetail where invoicenumber = @invoicenumber and description = i.description)) * (select r.taxrate from reftaxrate r inner join client c on c.taxrateid = r.taxrateid where c.clno = @CLNO) * .01)) as Amount
 from invdetail i with (nolock) where type = 0 
and invoicenumber = @invoicenumber
group by description
union all
--select 'No Package' as Description,max(amount) as 'Package Price',
--(select sum(amount) from invdetail with (nolock) where invoicenumber = @invoicenumber and 
--apno in (select apno from invdetail with (nolock) where invoicenumber = @invoicenumber and 
--description = i.description)  and (type = 1 or (type = 2 and description like '%service charge%' ))) as 'Service Charge',
--(select sum(amount) from invdetail with (nolock) where invoicenumber = @invoicenumber and 
--apno in (select apno from invdetail with (nolock) where invoicenumber = @invoicenumber and 
--description = i.description) and type= 0 and type = 1 and not (type = 2 and description like '%service charge%') and amount = 0) as 'AdditionalItem',
--count(*) as Quantity,
--(select sum(amount) from invdetail with (nolock) where invoicenumber = @invoicenumber and apno in (select apno from invdetail with (nolock) where invoicenumber = @invoicenumber and description = i.description)) as 'Sub Total',
--((select sum(amount) from invdetail with (nolock) where invoicenumber = @invoicenumber and apno in (select apno from invdetail where invoicenumber = @invoicenumber and description = i.description)) * (select r.taxrate from reftaxrate r inner join client c on c.taxrateid = r.taxrateid where c.clno = @CLNO) * .01) as Tax,
--((select sum(amount) from invdetail with (nolock) where invoicenumber = @invoicenumber and apno in (select apno from invdetail where invoicenumber = @invoicenumber and description = i.description))+ ((select sum(amount) from invdetail with (nolock) where invoicenumber = @invoicenumber and apno in (select apno from invdetail where invoicenumber = @invoicenumber and description = i.description)) * (select r.taxrate from reftaxrate r inner join client c on c.taxrateid = r.taxrateid where c.clno = @CLNO) * .01)) as Amount
-- from invdetail i with (nolock) where type = 1 
--and invoicenumber = @invoicenumber
----check if no package
--and (select count(*) from invdetail where apno = i.apno and invoicenumber = @invoicenumber and type = 0) = 0
--group by description
select --'No Package' as Description,
REPLACE(description,'Package:','') as Description,
0.00 as 'Package Price',
(select sum(amount) from  #temp1 with (nolock) where invoicenumber = @invoicenumber and apno in (select apno from  #temp1 with (nolock) where invoicenumber = @invoicenumber and description = i.description)  and (type = 1 or (type = 2 and description like '%service charge%' ))) as 'Service Charge',
(select sum(amount) from  #temp1 with (nolock) where invoicenumber = @invoicenumber and 
apno in (select apno from  #temp1 with (nolock) where invoicenumber = @invoicenumber and 
description = i.description) and type= 0 and type = 1 and not (type = 2 and description like '%service charge%') and amount = 0) as 'AdditionalItem',
count(*) as Quantity,
(select sum(amount) from  #temp1 with (nolock) where invoicenumber = @invoicenumber and apno in (select apno from  #temp1 with (nolock) where invoicenumber = @invoicenumber and description = i.description)) as 'Sub Total',
((select sum(amount) from  #temp1 with (nolock) where invoicenumber = @invoicenumber and apno in (select apno from  #temp1 where invoicenumber = @invoicenumber and description = i.description)) * (select r.taxrate from reftaxrate r inner join client c on c.taxrateid = r.taxrateid where c.clno = @CLNO) * .01) as Tax,
((select sum(amount) from  #temp1 with (nolock) where invoicenumber = @invoicenumber and apno in (select apno from  #temp1 where invoicenumber = @invoicenumber and description = i.description))+ ((select sum(amount) from  #temp1 with (nolock) where invoicenumber = @invoicenumber and apno in (select apno from  #temp1 where invoicenumber = @invoicenumber and description = i.description)) * (select r.taxrate from reftaxrate r inner join client c on c.taxrateid = r.taxrateid where c.clno = @CLNO) * .01)) as Amount

 from  #temp1 i with (nolock) where type = 1 
and invoicenumber = @invoicenumber
--check if no package
and (select count(*) from  #temp1 where apno = i.apno and invoicenumber = @invoicenumber and type = 0) = 0
group by description

END





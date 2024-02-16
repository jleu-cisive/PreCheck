


-- [Billing_ClientSubAccountSummary] 9121702
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Billing_ClientSubAccountSummary] 
	-- Add the parameters for the stored procedure here
	@invoicenumber int
AS
BEGIN

SET ANSI_WARNINGS ON
SET ARITHABORT ON

declare @CLNO int


select @CLNO = CLNO from InvMaster where invoicenumber = @invoicenumber

Select * into #Temp1 from invdetail i with (nolock) where type = 1 
 and invoicenumber = @invoicenumber
--check if no package
and (select count(*) from invdetail where apno = i.apno and invoicenumber = @invoicenumber and type = 0) = 0

--Select * From #Temp1

Update  #temp1
 set Description = (case when i.description like 'package: %' then I.Description else 'No Packages' end)
 from #temp1 T inner join invdetail i on T.Apno = i.Apno
 where i.Type = 0

--select (case when description like 'package: %' then description else 'No Packages' end) as Description,
--(case when description like 'package: %' then max(amount) else 0 end) as 'Package Price',
--(select sum(amount) from invdetail with (nolock) where invoicenumber = @invoicenumber and invdetail.apno in (select invdetail.apno from invdetail with (nolock) inner join 
--applclientdata with (nolock) on invdetail.apno = applclientdata.apno where invoicenumber = @invoicenumber and description = i.description
-- and applclientdata.xmld.value('(/ClientMeta/GL_SITE)[1]', 'varchar(20)') = p.siteid ) and (type = 1 or (type = 2 and description like '%service charge%' ))) as 'Service Charge',
--
--(select sum(amount) from invdetail with (nolock) where invoicenumber = @invoicenumber and invdetail.apno in (select invdetail.apno from invdetail with (nolock) inner join 
--applclientdata with (nolock) on invdetail.apno = applclientdata.apno where invoicenumber = @invoicenumber and description = i.description
-- and applclientdata.xmld.value('(/ClientMeta/GL_SITE)[1]', 'varchar(20)') = p.siteid ) and type <> 0 and type <> 1 and not (type = 2 and description like '%service charge%') and amount > 0) as 'AdditionalItem',
--(case when description like 'package: %' then count(*) else 0 end) as Quantity,
--(select sum(amount) from invdetail with (nolock) where invoicenumber = @invoicenumber
-- and invdetail.apno in (select invdetail.apno from invdetail  with (nolock) inner join 
--applclientdata with (nolock) on invdetail.apno = applclientdata.apno where invoicenumber = @invoicenumber and description = i.description
-- and applclientdata.xmld.value('(/ClientMeta/GL_SITE)[1]', 'varchar(20)') = p.siteid )) as 'Sub Total',
--((select sum(amount) from invdetail with (nolock) where invoicenumber = @invoicenumber
-- and invdetail.apno in (select invdetail.apno from invdetail  with (nolock) inner join 
--applclientdata with (nolock) on invdetail.apno = applclientdata.apno where invoicenumber = @invoicenumber and description = i.description
-- and applclientdata.xmld.value('(/ClientMeta/GL_SITE)[1]', 'varchar(20)') = p.siteid )) * .0825) as Tax,
--((select sum(amount) from invdetail with (nolock) where invoicenumber = @invoicenumber
-- and invdetail.apno in (select invdetail.apno from invdetail  with (nolock) inner join 
--applclientdata with (nolock) on invdetail.apno = applclientdata.apno where invoicenumber = @invoicenumber and description = i.description
-- and applclientdata.xmld.value('(/ClientMeta/GL_SITE)[1]', 'varchar(20)') = p.siteid ))+ ((select sum(amount) from invdetail with (nolock) where invoicenumber = @invoicenumber
-- and apno in (select invdetail.apno from invdetail  with (nolock) inner join 
--applclientdata with (nolock) on invdetail.apno = applclientdata.apno where invoicenumber = @invoicenumber and description = i.description
-- and applclientdata.xmld.value('(/ClientMeta/GL_SITE)[1]', 'varchar(20)') = p.siteid )) * .0825)) as Amount,
--p.siteid
-- from 
--(select a.apno,xmld.value('(/ClientMeta/GL_SITE)[1]', 'varchar(20)') as siteid
--from applclientdata a  with (nolock) inner join (select distinct apno from invdetail with (nolock) where invoicenumber = @invoicenumber) i
-- on a.apno = i.apno) p  left outer join invdetail i with (nolock) on i.apno = p.apno
--where 
--(i.type = 0 or (select count(*) from invdetail where invoicenumber = @invoicenumber and type = 0 and apno = i.apno) = 0)and
--i.invoicenumber = @invoicenumber
--group by description,siteid
--order by siteid


--Select * into # from invdetail where invoicenumber = 9121702
--Update  #temp1
-- set Description = (case when i.description like 'package: %' then I.Description else 'No Packages' end)
-- from #temp1 T inner join invdetail i on T.Apno = i.Apno
-- where Type = 0



--Select * into #temp1 from
--(
--select (case when description like 'package: %' then description else 'No Packages' end) as Description,
--(case when description like 'package: %' then max(amount) else 0 end) as 'Package Price',
--(select sum(amount) from invdetail with (nolock) where invoicenumber = @invoicenumber and invdetail.apno in (select invdetail.apno from invdetail with (nolock) inner join 
--applclientdata with (nolock) on invdetail.apno = applclientdata.apno where invoicenumber = @invoicenumber and description = i.description
-- and isnull(applclientdata.xmld.value('(/ClientMeta/PRACTICE_DESC)[1]', 'varchar(100)'),'Unknown') + '(' + isnull(applclientdata.xmld.value('(/ClientMeta/PRACTICE_CODE)[1]', 'varchar(50)'),'Unknown') + ')' = p.siteid ) and (type = 1 or (type = 2 and description like '%service charge%' ))) as 'Service Charge',

--(select sum(amount) from invdetail with (nolock) where invoicenumber = @invoicenumber and invdetail.apno in (select invdetail.apno from invdetail with (nolock) inner join 
--applclientdata with (nolock) on invdetail.apno = applclientdata.apno where invoicenumber = @invoicenumber and description = i.description
-- and isnull(applclientdata.xmld.value('(/ClientMeta/PRACTICE_DESC)[1]', 'varchar(100)'),'Unknown') + '(' + isnull(applclientdata.xmld.value('(/ClientMeta/PRACTICE_CODE)[1]', 'varchar(50)'),'Unknown') + ')' = p.siteid ) and type <> 0 and type <> 1 and not (type = 2 and description like '%service charge%') and amount > 0) as 'AdditionalItem',
--(case when description like 'package: %' then count(*) else 0 end) as Quantity,
--(select sum(amount) from invdetail with (nolock) where invoicenumber = @invoicenumber
-- and invdetail.apno in (select invdetail.apno from invdetail  with (nolock) inner join 
--applclientdata with (nolock) on invdetail.apno = applclientdata.apno where invoicenumber = @invoicenumber and description = i.description
-- and isnull(applclientdata.xmld.value('(/ClientMeta/PRACTICE_DESC)[1]', 'varchar(100)'),'Unknown') + '(' + isnull(applclientdata.xmld.value('(/ClientMeta/PRACTICE_CODE)[1]', 'varchar(50)'),'Unknown') + ')' = p.siteid )) as 'Sub Total',
--((select sum(amount) from invdetail with (nolock) where invoicenumber = @invoicenumber
-- and invdetail.apno in (select invdetail.apno from invdetail  with (nolock) inner join 
--applclientdata with (nolock) on invdetail.apno = applclientdata.apno where invoicenumber = @invoicenumber and description = i.description
-- and isnull(applclientdata.xmld.value('(/ClientMeta/PRACTICE_DESC)[1]', 'varchar(100)'),'Unknown') + '(' + isnull(applclientdata.xmld.value('(/ClientMeta/PRACTICE_CODE)[1]', 'varchar(50)'),'Unknown') + ')' = p.siteid )) * .0825) as Tax,
--((select sum(amount) from invdetail with (nolock) where invoicenumber = @invoicenumber
-- and invdetail.apno in (select invdetail.apno from invdetail  with (nolock) inner join 
--applclientdata with (nolock) on invdetail.apno = applclientdata.apno where invoicenumber = @invoicenumber and description = i.description
-- and isnull(applclientdata.xmld.value('(/ClientMeta/PRACTICE_DESC)[1]', 'varchar(100)'),'Unknown') + '(' + isnull(applclientdata.xmld.value('(/ClientMeta/PRACTICE_CODE)[1]', 'varchar(50)'),'Unknown') + ')' = p.siteid ))+ ((select sum(amount) from invdetail with (nolock) where invoicenumber = @invoicenumber
-- and apno in (select invdetail.apno from invdetail  with (nolock) inner join 
--applclientdata with (nolock) on invdetail.apno = applclientdata.apno where invoicenumber = @invoicenumber and description = i.description
-- and isnull(applclientdata.xmld.value('(/ClientMeta/PRACTICE_DESC)[1]', 'varchar(100)'),'Unknown') + '(' + isnull(applclientdata.xmld.value('(/ClientMeta/PRACTICE_CODE)[1]', 'varchar(50)'),'Unknown') + ')' = p.siteid )) * .0825)) as Amount,
--p.siteid
-- from 
--(select a.apno,isnull(xmld.value('(/ClientMeta/PRACTICE_DESC)[1]', 'varchar(100)'),'Unknown') + '(' + isnull(xmld.value('(/ClientMeta/PRACTICE_CODE)[1]', 'varchar(50)'),'Unknown') + ')' as siteid,  xmld.value('(/ClientMeta/PRACTICE_CODE)[1]', 'varchar(20)')  as PRACTICE_CODE
--from applclientdata a  with (nolock) inner join (select distinct apno from invdetail with (nolock) where invoicenumber = @invoicenumber) i
-- on a.apno = i.apno) p  left outer join invdetail i with (nolock) on i.apno = p.apno
--where  PRACTICE_CODE is not null and 
--(i.type = 0 or (select count(*) from invdetail where invoicenumber = @invoicenumber and type = 0 and apno = i.apno) = 0)and
--i.invoicenumber = @invoicenumber
--group by description,siteid
--union all

select  Description,
(case when description like 'package: %' then max(amount) else 0 end) as 'Package Price',
(select sum(amount) from invdetail with (nolock) where invoicenumber = @invoicenumber and 
apno in (select invdetail.apno from invdetail with (nolock) inner join 
applclientdata with (nolock) on invdetail.apno = applclientdata.apno where invoicenumber = @invoicenumber and description = i.description
 and isnull(applclientdata.xmld.value('(/ClientMeta/PRACTICE_DESC)[1]', 'varchar(100)'),' ') + '(' + isnull(applclientdata.xmld.value('(/CustomClientData/ClientData3)[1]', 'varchar(50)'),'Unknown') + ')' = p.siteid )
and (type = 1 or (type = 2 and description like '%service charge%' ))) as 'Service Charge',
(select sum(amount) from invdetail with (nolock) where invoicenumber = @invoicenumber and 
apno in (select invdetail.apno from invdetail with (nolock) inner join 
applclientdata with (nolock) on invdetail.apno = applclientdata.apno where invoicenumber = @invoicenumber and description = i.description
 and isnull(applclientdata.xmld.value('(/ClientMeta/PRACTICE_DESC)[1]', 'varchar(100)'),' ') + '(' + isnull(applclientdata.xmld.value('(/CustomClientData/ClientData3)[1]', 'varchar(50)'),'Unknown') + ')' = p.siteid ) and type = 0 and type= 1 and not (type = 2 and description like '%service charge%') and amount= 0) as 'AdditionalItem',
count(*) as Quantity,
(select sum(amount) from invdetail with (nolock) where invoicenumber = @invoicenumber and apno in (select invdetail.apno from invdetail with (nolock) inner join 
applclientdata with (nolock) on invdetail.apno = applclientdata.apno where invoicenumber = @invoicenumber and description = i.description
 and isnull(applclientdata.xmld.value('(/ClientMeta/PRACTICE_DESC)[1]', 'varchar(100)'),' ') + '(' + isnull(applclientdata.xmld.value('(/CustomClientData/ClientData3)[1]', 'varchar(50)'),'Unknown') + ')' = p.siteid )) as 'Sub Total',
((select sum(amount) from invdetail with (nolock) where invoicenumber = @invoicenumber and apno in (select invdetail.apno from invdetail with (nolock) inner join 
applclientdata with (nolock) on invdetail.apno = applclientdata.apno where invoicenumber = @invoicenumber and description = i.description
 and isnull(applclientdata.xmld.value('(/ClientMeta/PRACTICE_DESC)[1]', 'varchar(100)'),' ') + '(' + isnull(applclientdata.xmld.value('(/CustomClientData/ClientData3)[1]', 'varchar(50)'),'Unknown') + ')' = p.siteid )) * (select r.taxrate from reftaxrate r inner join client c on c.taxrateid = r.taxrateid where c.clno = @CLNO) * .01) as Tax,
((select sum(amount) from invdetail with (nolock) where invoicenumber = @invoicenumber and apno in (select invdetail.apno from invdetail with (nolock) inner join 
applclientdata with (nolock) on invdetail.apno = applclientdata.apno where invoicenumber = @invoicenumber and description = i.description
 and isnull(applclientdata.xmld.value('(/ClientMeta/PRACTICE_DESC)[1]', 'varchar(100)'),' ') + '(' + isnull(applclientdata.xmld.value('(/CustomClientData/ClientData3)[1]', 'varchar(50)'),'Unknown') + ')' = p.siteid ))+ ((select sum(amount) from invdetail with (nolock) where invoicenumber = @invoicenumber and apno in
 (select invdetail.apno from invdetail with (nolock) inner join 
applclientdata with (nolock) on invdetail.apno = applclientdata.apno where invoicenumber = @invoicenumber and description = i.description
 and isnull(applclientdata.xmld.value('(/ClientMeta/PRACTICE_DESC)[1]', 'varchar(100)'),' ') + '(' + isnull(applclientdata.xmld.value('(/CustomClientData/ClientData3)[1]', 'varchar(50)'),'Unknown') + ')' = p.siteid )) * (select r.taxrate from reftaxrate r inner join client c on c.taxrateid = r.taxrateid where c.clno = @CLNO) * .01)) as Amount
 ,p.siteid
 from
 (select i.apno,isnull(xmld.value('(/ClientMeta/PRACTICE_DESC)[1]', 'varchar(100)'),' ') + '(' + isnull(xmld.value('(/CustomClientData/ClientData3)[1]', 'varchar(50)'),'Unknown') + ')' as siteid,  xmld.value('(/CustomClientData/ClientData3)[1]', 'varchar(20)')  as PRACTICE_CODE
from applclientdata a  with (nolock) inner join (select distinct apno from invdetail with (nolock) where invoicenumber = @invoicenumber) i
 on a.apno = i.apno) p  left outer join invdetail i with (nolock) on i.apno = p.apno
where  PRACTICE_CODE is not null and 
(i.type = 0) and
i.invoicenumber = @invoicenumber
group by description,siteid

Union all

select Description, --(case when description like 'package: %' then description else 'No Packages' end) as Description,
 0  as 'Package Price',
(select sum(amount) from  #temp1 with (nolock) where invoicenumber = @invoicenumber and  #temp1.apno in 
(select  #temp1.apno from  #temp1 with (nolock) inner join 
applclientdata with (nolock) on  #temp1.apno = applclientdata.apno where invoicenumber = @invoicenumber and description = i.description
 and isnull(applclientdata.xmld.value('(/ClientMeta/PRACTICE_DESC)[1]', 'varchar(100)'),' ') + '(' + isnull(applclientdata.xmld.value('(/CustomClientData/ClientData3)[1]', 'varchar(50)'),'Unknown') + ')' = p.siteid ) and (type = 1 or (type = 2 and description like '%service charge%' ))) as 'Service Charge',

(select sum(amount) from  #temp1 with (nolock) where invoicenumber = @invoicenumber and  #temp1.apno in (select  #temp1.apno from  #temp1 with (nolock) inner join 
applclientdata with (nolock) on  #temp1.apno = applclientdata.apno where invoicenumber = @invoicenumber and description = i.description
 and isnull(applclientdata.xmld.value('(/ClientMeta/PRACTICE_DESC)[1]', 'varchar(100)'),' ') + '(' + isnull(applclientdata.xmld.value('(/CustomClientData/ClientData3)[1]', 'varchar(50)'),'Unknown') + ')' = p.siteid ) and type <> 0 and type <> 1 and not (type = 2 and description like '%service charge%') and amount > 0) as 'AdditionalItem',
(case when description like 'package: %' then count(*) else 0 end) as Quantity,
(select sum(amount) from  #temp1 with (nolock) where invoicenumber = @invoicenumber
 and  #temp1.apno in (select  #temp1.apno from  #temp1  with (nolock) inner join 
applclientdata with (nolock) on  #temp1.apno = applclientdata.apno where invoicenumber = @invoicenumber and description = i.description
 and isnull(applclientdata.xmld.value('(/ClientMeta/PRACTICE_DESC)[1]', 'varchar(100)'),' ') + '(' + isnull(applclientdata.xmld.value('(/CustomClientData/ClientData3)[1]', 'varchar(50)'),'Unknown') + ')' = p.siteid )) as 'Sub Total',
((select sum(amount) from  #temp1 with (nolock) where invoicenumber = @invoicenumber
 and  #temp1.apno in (select  #temp1.apno from  #temp1  with (nolock) inner join 
applclientdata with (nolock) on  #temp1.apno = applclientdata.apno where invoicenumber = @invoicenumber and description = i.description
 and isnull(applclientdata.xmld.value('(/ClientMeta/PRACTICE_DESC)[1]', 'varchar(100)'),' ') + '(' + isnull(applclientdata.xmld.value('(/CustomClientData/ClientData3)[1]', 'varchar(50)'),'Unknown') + ')' = p.siteid )) * .0825) as Tax,
((select sum(amount) from  #temp1 with (nolock) where invoicenumber = @invoicenumber
 and  #temp1.apno in (select  #temp1.apno from  #temp1  with (nolock) inner join 
applclientdata with (nolock) on  #temp1.apno = applclientdata.apno where invoicenumber = @invoicenumber and description = i.description
 and isnull(applclientdata.xmld.value('(/ClientMeta/PRACTICE_DESC)[1]', 'varchar(100)'),' ') + '(' + isnull(applclientdata.xmld.value('(/CustomClientData/ClientData3)[1]', 'varchar(50)'),'Unknown') + ')' = p.siteid ))+ ((select sum(amount) from  #temp1 with (nolock) where invoicenumber = @invoicenumber
 and apno in (select  #temp1.apno from  #temp1  with (nolock) inner join 
applclientdata with (nolock) on  #temp1.apno = applclientdata.apno where invoicenumber = @invoicenumber and description = i.description
 and isnull(applclientdata.xmld.value('(/ClientMeta/PRACTICE_DESC)[1]', 'varchar(100)'),' ') + '(' + isnull(applclientdata.xmld.value('(/CustomClientData/ClientData3)[1]', 'varchar(50)'),'Unknown') + ')' = p.siteid )) * .0825)) as Amount,
p.siteid
 from 
(select i.apno,isnull(xmld.value('(/ClientMeta/PRACTICE_DESC)[1]', 'varchar(100)'),' ') + '(' + isnull(xmld.value('(/CustomClientData/ClientData3)[1]', 'varchar(50)'),'Unknown') + ')' as siteid,  xmld.value('(/CustomClientData/ClientData3)[1]', 'varchar(20)')  as PRACTICE_CODE
from applclientdata a  with (nolock) inner join (select distinct apno from  #temp1 with (nolock) where invoicenumber = @invoicenumber) i
 on a.apno = i.apno) p  left outer join  #temp1 i with (nolock) on i.apno = p.apno
where  PRACTICE_CODE is not null and 
(i.type = 0 or (select count(*) from  #temp1 where invoicenumber = @invoicenumber and type = 0 and apno = i.apno) = 0)and
i.invoicenumber = @invoicenumber
group by description,siteid


----select * from #temp1
--Update  #temp1
-- set Description = (case when i.description like 'package: %' then I.Description else 'No Packages' end)
-- from #temp1 T inner join invdetail i on T.Apno = i.Apno
-- where Type = 0

-- select Description,[Package Price] ,[Service Charge],AdditionalItem,Quantity, ([Package Price] +isnull([Service Charge],0.00)+isnull(AdditionalItem,0.0)) [Sub Total], (([Package Price] +isnull([Service Charge],0.00)+isnull(AdditionalItem,0.0))* .0825) as Tax,(([Package Price] +isnull([Service Charge],0.00)+isnull(AdditionalItem,0.0))+(([Package Price] +isnull([Service Charge],0.00)+isnull(AdditionalItem,0.0))* .0825)) as Amount ,siteid

-- from #temp1
order by siteid

drop table #temp1

END








-- =============================================
-- Author:		Kiran Miryala
-- Create date: 04/08/2021
-- Description:	/*This Sp will give list of Clients which  had a change in last 24hrs. */
-- =============================================

CREATE PROCEDURE [dbo].[NetSuite_CustomerList]
	
	
AS
SET NOCOUNT ON

	

      BEGIN 

	  declare @date datetime
	  set @date = dateadd(dd,-7,getdate())
	 -- set @date = dateadd(dd,-30,getdate())
	  
	    SELECT distinct [CLNO] into #tempChangeclients 
		from (
		select  distinct [CLNO]
  FROM [PRECHECK].[dbo].[ChangeLogCM] 
  where ChangeDate > @date and [CLNO] >0
  union all 
  SELECT [CLNO]
       FROM [ALA-sql-05].[Precheck_Staging].[dbo].[NotificationConfig] where refNotificationTypeid = 11 and [ModifyDate] > @date
  --and clno in (16678,15957,13932)
  union all
  select clno from client 
  --where clno in (8667,11644,13894,7017,7527,12450)
   --where BillCycle <> 'Z'
  where  clno in (select ParentCLNO from client where clno in(
  select  distinct [CLNO]
  FROM [PRECHECK].[dbo].[ChangeLogCM] 
  where ChangeDate > @date and [CLNO] >0) and ParentCLNO is not null)
 
  ) T1

--select * from #tempChangeclients
select distinct [CLNO]
      ,[Email] into #tblemail
	  from (
SELECT [CLNO]
      ,ltrim(rtrim([Email])) [Email]     
  FROM [ALA-sql-05].[Precheck_Staging].[dbo].[NotificationConfig] where refNotificationTypeid = 11 
  )t 
  where isnull([CLNO],'') <> ''
  and isnumeric([CLNO]) = 1
  and ltrim(rtrim(isnull([Email],'')))<> ''
 and CLNO in (SELECT distinct [CLNO] From #tempChangeclients)
 --select * from #tblemail order by CLNO

  SELECT OutTab.[CLNO] ,
      [Email] =

              STUFF ( ( SELECT ';'+InrTab.[Email]

						FROM #tblemail InrTab

						WHERE InrTab.CLNO = OutTab.clno

						 --AND  InrTab.subtitle = OutTab.subtitle

						ORDER BY InrTab.[Email]

						FOR XML PATH(''),TYPE

					   ).value('.','VARCHAR(MAX)')

					  , 1,1,SPACE(0))
					  into #EmailAddresses
FROM #tblemail OutTab
GROUP BY OutTab.CLNO
order by CLNO

--select * from  #EmailAddresses


--customer name lenth need to be set at 70
--item description - 60 char

select --top 10
--Zip,
--len(Name) length,LastInvDate,LastInvAmount,
 cast(c.clno as varchar(10))  as ExternalID,
 cast(c.clno as varchar(10)) + '-' + substring((case when len(Name) >70 then replace(DescriptiveName,',','-') else replace(Name,',','-') end),1,70)   as 	[Customer ID],
'False'	Individual,
--len(Name) [Company Name length],
substring(( case when len(Name) >70 then replace(DescriptiveName,',','-') else replace(Name,',','-') end),1,70)  as	[Company Name],
--replace(Name,',','-') cname,
--''	[First Name],''	[Middle Name],''	[Last Name],
--len(DescriptiveName) [Display Name length],
--replace(DescriptiveName,',','-')  as	[Display Name],
--len(case when len(Name) >70 then replace(DescriptiveName,',','-') else replace(Name,',','-') end) clength,
'Cisive : Healthcare Solutions [PreCheck]'	Subsidiary,''	[Represents Subsidiary],--''	[Business Unit],
	isnull(c.Email,'') Email,	replace(isnull(Phone,''),',','-')  Phone,	
	'CUSTOMER-Closed Won' Status,
	--SalesPersonUserID -- will come back and fix this as we need to understand how we are getting this
	--''
	SalesPersonUserID	[Sales Rep],--''	[Lead Source],
	cast(case when isnull(c.ParentCLNO,'') = c.clno then '' else isnull(c.ParentCLNO,'') end as varchar(8)) [Child Of],
	-- case when (case when isnull(c.ParentCLNO,'') = c.clno then '' else replace(isnull(c.ParentCLNO,''),0,'') end) = 0 then '' else   	[Child Of],
	 c.CIP_Industry	[Category],
	isinactive	Inactive,''	[Contact 1],
	'Cisive : Healthcare Solutions [PreCheck]'	[Contact 1 Subsidiary],--''	[Account],
	'1210 Receivables : Accounts Receivable'	[Default Receivables Account],'USD'	[Primary Currency],'NET 30'	[Terms],
	--''	[Price Level],''	[Credit Limit],
	case when IsTaxExempt = 1 then 'False' else 'True' end Taxable,
	''	[Tax Item],
	isnull(TaxExemptionNumber,'') 	[Tax Reg. Number],--''	[Deferred Revenue Account for Revenue Reclassification],''	[Additional Currency 1],
	case when replace(isnull(BillingAddress1,''),',',' ') <> '' then replace(replace(replace(BillingAddress1,',','-'),CHAR(10),''),char(13),'')  --,replace(replace(c.Description,',','-'),CHAR(10),'') Description
		else case when  replace(isnull(BillingAddress2,''),',',' ') <> '' then replace(replace(replace(BillingAddress2,',','-'),CHAR(10),''),char(13),'')
		else 'Bill To' end end 
	[Label],
	substring(replace(isnull([AttnTo],''),',','-'),1,32) 	Attention, replace(Name,',','-')  [Addressee], replace(isnull(phone,''),',','-')	Phone2,
	replace(replace(replace(BillingAddress1,',','-'),CHAR(10),''),char(13),'') 	[Address 1],replace(replace(replace(BillingAddress2,',','-'),CHAR(10),''),char(13),'')	[Address 2], replace(isnull(BillingCity,''),',',' ') 	City, replace(isnull(BillingState,''),',',' ') 	[Province/State],
	--isnull(BillingZip,'')	[Postal Code/Zip],
	case when substring(isnull(BillingZip,''),1, 5) = '' then substring(isnull(c.ZIP,''),1, 5) else substring(isnull(BillingZip,''),1, 5) end 	 [Postal Code/Zip],
		'UNITED STATES' Country,
	'TRUE'	[Default Billing],'TRUE'	[Default Shipping],
		--''	[Label3],''	[Attention4],''	[Addressee5],''	[Phone6],''	[Address 17],''	[Address 28],''	[City9],''	[Province/State10]
			--,''	[Postal Code/Zip11],''	[Country12],''	[Default Billing13],''	[Default Shipping14],''	[Number Format],	
			--''	[Language],''	[Negative Number Format],''	[Email Preference],
			''	[Print on Check As], --''	[Send Transactions Via Email],''	[Send Transactions Via Print],''	[Send Transactions Via Fax]	
			--,''	[Ship Complete],''	[Shipping Carrier],''	[Shipping Method],				
			isnull([Customer-Vendor],'Customer') [Customer/Vendor],'RETAIL'	[Retail/Wholesale],  replace(isnull([Accounting System Grouping],''),',','-') 	[Accounting System Grouping],--''	[Customer Status],''	[AcctPriority],
			''	[Revenue Type],
			''	[Process Level],''	[Customer Subsidiary],isnull(Ltrim(Rtrim(billcycle)),'')	[BillingCycle] --, len(isnull(Ltrim(Rtrim(billcycle)),''))	 lencycle
			,''	[PartnerId],--''	[Account Manager],''	[Invoice Template],
			--''	[BILLINGFREQUENCY],
			replace(replace(isnull(e.[Email],''),',',''),':','')	[Billing Email Address(es)]--,''	[Dunning Contact ID],''	[ZipCrim Bill To Client Code],''	[Category Code 14 - JDE	ZipCrim Parent/Child]

into #Dailyclient
from client c
left join #EmailAddresses e on c.clno = e.clno 
where	 --isinactive = 0
 --and 
 
 --(c.CLNO in (SELECT distinct [CLNO] From client where IsInactive = 0) or  c.CLNO in  (select clno from client where  clno in (select ParentCLNO from client)))
 c.CLNO in (SELECT distinct [CLNO] From #tempChangeclients)
 --and BillCycle not in ('Z','N','Z','ZC' )
 -- c.clno in (12453,12646,14255,15444,16038,16559,16608,16630,16646,16717,2989,3115,8886,9028,9266,9266,2989,9028)
 --c.clno =7301
  --and BillCycle  in ('S')
 --and  isnull(BillingZip,'') <> '' 
  --and isnull(BillingZip,'') = ''
 --and len(case when len(Name) >70 then replace(DescriptiveName,',','-') else replace(Name,',','-') end)  >70
 --and (isnull(BillingZip,'') = ''  or len(c.name) >= 70)
 --and c.clno = 7005
 --and c.clno > 9673
 and
  C.name <> 'New Client Name' and isnull(c.name,'') <> ''
 --and ((case when substring(isnull(BillingZip,''),1, 5) = '' then substring(isnull(c.ZIP,''),1, 5) else substring(isnull(BillingZip,''),1, 5)end) <> '' 
 --or (C.name <> 'New Client Name' or isnull(c.name,'') <> ''))
 --and (c.Email is not null or phone is not null)
order by c.clno --len(Name) desc
--select  * from client
--len(case when len(Name) >70 then replace(DescriptiveName,',','-') else replace(Name,',','-') end) desc
select --top 10
--Zip,
--len([Company Name]) length,--,LastInvDate,LastInvAmount,
 ExternalID,	[Customer ID],Individual,	[Company Name],	Subsidiary,[Represents Subsidiary],
	 Email,	 Phone,	Status,[Sales Rep],
	 case when  [Child Of] = '0' then '' else [Child Of] end  [Child Of] ,
		[Category],	Inactive,	[Contact 1],	[Contact 1 Subsidiary],[Default Receivables Account],	[Primary Currency],	[Terms],
 Taxable,[Tax Item],	[Tax Reg. Number],
	[Label],
	replace(isnull(Attention,''),',','-') 	Attention,  [Addressee],	Phone2,
	 	[Address 1],	[Address 2],  	City,  	[Province/State],
		 [Postal Code/Zip],Country,	[Default Billing],	[Default Shipping],
			[Print on Check As],			
			 [Customer/Vendor],[Retail/Wholesale], 	[Accounting System Grouping],	[Revenue Type],
				[Process Level],	[Customer Subsidiary],	[BillingCycle] 
			,	[PartnerId],[Billing Email Address(es)]

from #Dailyclient 
where isnull([Customer ID],'')<> '' and  [Customer ID] <> 'New Client Name'
order by ExternalID

drop table #tblemail
drop table #EmailAddresses
drop table #Dailyclient
	 

   END 

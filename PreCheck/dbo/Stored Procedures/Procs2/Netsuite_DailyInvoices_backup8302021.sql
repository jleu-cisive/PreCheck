
-- =============================================
-- Author:		Kiran Miryala
-- Create date: 04/28/2021
-- Description:	Monthly incoice Output for Netsuite thru Celigo
-- =============================================

create PROCEDURE  [dbo].[Netsuite_DailyInvoices_backup8302021]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
  --	truncate table Precheck.[dbo].[NetSuiteDailyInvoice]

select  distinct 'Invoice' FileType , InvoiceId, CustomerId,  [Memo],  TranDate,  PostingPeriod
, cast(isnull([ItemLine_Item],'') as Varchar(40))  [ItemLine_Item], isnull([ItemLine_description],'')  [ItemLine_description], isnull([ItemLine_Rate],0) [ItemLine_Rate], isnull([ItemLine_quantity],1)	[ItemLine_quantity], [Account]
,isnull(GrossCaseVolume,0) GrossCaseVolume, isnull(GrossLeadVolume,0)	GrossLeadVolume
, [Unique Identifier]
, [Bundle Id Print], 
[ItemLine_Item] 'Description [To Print]', 
	QuantityToPrint,

 Rate as 'Rate [To Print]',Amount 'Amount [Print]',SalesTax, IsMonthlyInvoice,	[Do Not Email],
[Invoice Layout], 	ShipToZip
from (

select distinct 'SC-' + cast(i.Invoicenumber as varchar(10)) as InvoiceId, 
cast(c.CLNO as varchar(10)) as CustomerId, 
i.Invoicenumber [Memo], InvoiceDate TranDate, CONVERT(CHAR(4), InvoiceDate, 100) + CONVERT(CHAR(4), i.InvoiceDate, 120) as PostingPeriod
,cast ((Case  when i.Leadtypeid= 2 then 'STUDCHK-CRIM-FEE' else
	(Case  when i.Leadtypeid= 7 then 'STUDCHK-SANCTIONBG-FEE' else
	(Case  when i.Leadtypeid= 8 then 'STUDCHK-DRUG-FEE' else
	(Case  when i.Leadtypeid= 9 then 'STUDCHK-IMMU-FEE'  end )end ) end ) end) as Varchar(40)) [ItemLine_Item]

, i.[LeadtypeDescription] [ItemLine_description], --GLPostRevenue 
(Case  when i.Leadtypeid= 2 then GLPostRevenue/cast(4 AS DECIMAL(18,4)) else GLPostRevenue end) [ItemLine_Rate], 
(Case  when i.Leadtypeid= 2 then 4 else 1 end)		[ItemLine_quantity], '1210 Accounts Receivable' [Account]

,cast(t2.GLPostNumCase as decimal(18,8)) GrossCaseVolume,
(Case  when i.Leadtypeid= 2 then 4 else 1 end)	GrossLeadVolume
,isnull(cast(i.InvoiceNumber as varchar(8) )+ cast(i.leadtypeid as varchar(2)),'') as [Unique Identifier]
,'' as [Bundle Id Print], i.Description 'Description', 
(Case  when i.Leadtypeid= 2 then 4 else 1 end)	QuantityToPrint, 

(Case  when i.Leadtypeid= 2 then GLPostRevenue/cast(4 AS DECIMAL(18,4)) else GLPostRevenue end) 'Rate',
--(Case  when i.Amount > 0  then i.Amount else GLPostRevenue end)  'Rate',
 (Case  when i.Amount > 0  then i.Amount else GLPostRevenue end)	'Amount',0.00	SalesTax, 'False'	IsMonthlyInvoice,'True'	[Do Not Email],
'HealthCare'	[Invoice Layout], a.Zip	ShipToZip
from Precheck.[dbo].[NetSuiteDailyInvoice]  i 
inner join appl a on i.Invoicenumber = a.APNO
inner join client c on a.clno = c.CLNO
left join (select InvoiceNumber,leadtypeid,cast(Sum(GLPostNumCases)  AS DECIMAL(18,8) ) as GLPostNumCase, Sum(GLPostNumLeads) GLPostNumLeads,
cast(sum(GLPostRevenue)  AS DECIMAL(18,8) )  GLPostRevenue 
		from
(select InvoiceNumber,leadtypeid,cast(Sum(Numcase) AS DECIMAL(18,8) ) as GLPostNumCases, Sum(NumLead) GLPostNumLeads,sum(case when [AdjustedPriceperPackage] <> 0 then [AdjustedPriceperPackage] else
	    case when Passthru <>0 then Passthru else 0.00 end end) GLPostRevenue 
from [NetSuiteDailyInvoice] where leadtypeid is not null   group by InvoiceNumber,leadtypeid
--union all
--select InvoiceNumber,2 leadtypeid,0 GLPostNumCases,0 GLPostNumLeads,cast(Sum([AdjustedPriceperPackage]) as decimal(18,8)) GLPostRevenue  from  InvDetailForCisive2021 where  type = 0 group by InvoiceNumber,leadtypeid
) t3
group by InvoiceNumber,leadtypeid
)t2 on i.invoicenumber = t2.InvoiceNumber and i.Leadtypeid = t2.Leadtypeid
--inner join (select Invoicenumber, Amount  from  [dbo].[NetSuiteDailyInvoice]
--			where  type = 0
--			 ) t on i.invoicenumber = t2.InvoiceNumber

where i.Invoicenumber in (5888700,5888750,5888753) -- 7/29
--(5887420,5887422,5887424) 7/28
--(5887308,5887312,5887329) 7/21
--(5886803,5886825,5886837) -- (5886881,5886888,5886889)
--(5886743,5886770,5886782)
--(5886710,5886719,5886741)
--(5886413,5886417)
--(5886347,5886376) 7/12
--(5886238,5886248) 7/12
--(5841268,5841263)--in (5838247,5838251,5838264,5838276,5838278) 
--Union All
--select 'EC-1000'  as InvoiceId, v.employerid as CustomerId, Transactionid [Memo], Transdate TranDate, CONVERT(CHAR(4), Transdate, 100) + CONVERT(CHAR(4), Transdate, 120) as PostingPeriod
--,15 [ItemLine_Item], 'EMPCK-FEE' [ItemLine_description], v.BaseAmount [ItemLine_Rate],1	[ItemLine_quantity], '1210 Accounts Receivable' [Account]
--,1 GrossCaseVolume, 1	GrossLeadVolume
----,isnull(cast(i.InvoiceNumber as varchar(8) )
--,'EC-1000'+ cast(15 as varchar(2)) as [Unique Identifier]
--,'' as [Bundle Id Print], 'Employee Check' AS  'Description', 1	QuantityToPrint,  v.BaseAmount 'Rate',  v.BaseAmount	'Amount',BilledTaX	SalesTax, 'False'	IsMonthlyInvoice,'True'	[Do Not Email],
--'HealthCare'	[Invoice Layout], ver.Zip	ShipToZip
 
--from hevn.[dbo].[CCTransactionLog] t inner join hevn.[dbo].Verify v on t.VerifyID = v.VerifyID 
--inner join hevn.[dbo].Verifier ver on v.VerifierID = ver.VerifierID
--where transdate >  '6/10/2021' and transdate <  '6/11/2021' and T.verifyid is not null 
--and t.verifyid in (660396,660397,660398,660399,660400,660401)
) z
where  cast([ItemLine_Item] as Varchar(40)) is not null
order by Invoiceid,[ItemLine_description]

--select *  from [NetSuiteDailyInvoice] where Invoicenumber = 5838276
--select Sum(Amount),sum([AdjustedPriceperPackage]) ,cast(sum([AdjustedPriceperPackage]) as  DECIMAL(18,8) )  from [NetSuiteDailyInvoice] where Invoicenumber = 5838276
----select top 100 * from verifier 

--select top 100 * from Verify where verifyid in (select  verifyid from [dbo].[CCTransactionLog] where transdate >  '6/10/2021' and transdate <  '6/11/2021' and verifyid is not null ) order by 1 desc
--select  top 100 * from [dbo].[CCTransactionLog] where transdate >  '6/10/2021' and transdate <  '6/11/2021' and verifyid is not null order by 1 desc







select 'Payment' FileType ,PaymentId,  AccountId, 	InvoiceId,	InvoiceDate, 	PaymentDate,	Amount,	Tax, 	PNRefNo, 	PaymentMethod 
from 
(
select PaymentId, 'HC-'+ cast(c.CLNO as varchar(10))  AccountId, 'SC-' + cast(APPNo as varchar(10))	InvoiceId, Timecreated 	InvoiceDate, Timecreated	PaymentDate,	i.Amount,I.TaxAmount	Tax, PFPReference	PNRefNo, CCType	PaymentMethod 

from [PrecheckServices].[dbo].[Payment] i
inner join  [PrecheckServices].[dbo].ccpayment cc on i.ccpaymentid = cc.ccpaymentid
inner join appl a on i.AppNo = a.APNO
inner join client c on a.clno = c.CLNO
where APPNO in   (5888700,5888750,5888753) 
--(5887420,5887422,5887424)
-- (5887308,5887312,5887329)--(5886803,5886825,5886837) -- (5886881,5886888,5886889)
--(5886743,5886770,5886782)
--(5886710,5886719,5886741)
--(5886413,5886417)
--(select Distinct Invoicenumber from NetSuiteDailyInvoice)
--union all
--select Transactionid PaymentId,Employerid  AccountId, 'EC-1000'	InvoiceId, TransDate 	InvoiceDate, TransDate	PaymentDate, Baseamount Amount, BilledTax	Tax, TransREF	PNRefNo, CCType	PaymentMethod 
--from hevn.[dbo].[CCTransactionLog] t inner join hevn.[dbo].Verify v on t.VerifyID = v.VerifyID 
--where transdate >  '6/10/2021' and transdate <  '6/11/2021' and T.verifyid is not null 
--and t.verifyid in (660396,660397,660398,660399,660400,660401)
) t
order by InvoiceId
-- check on the changelog to see if there is any ZIP code change. and pick the orginal ZIP to be sent to NETsuite.

END

-- =============================================
-- Author:		Kiran Miryala
-- Create date: 04/28/2021
-- Description:	Monthly incoice Output for Netsuite thru Celigo
-- =============================================

CREATE PROCEDURE  [dbo].[Netsuite_MonthlyInvoices_20000plus]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @Invdate datetime
	declare @month int
	declare @year int

	--select @Invdate = Max(invdate) from InvMaster
	set @Invdate = '2021-04-30 00:00:00.000'
	set @month = MONTH(@Invdate)
	set @year = year(@Invdate)
	-- Insert statements for procedure here

	--select distinct BillingCycle from InvRegistrarTotal where CutOffDate = (  select  Max(CutOffDate) from InvRegistrarTotal) and BillingCycle not in ('Z','zc','N','S')
		select distinct BillingCycle into #temp1 from InvRegistrarTotal where CutOffDate = (  select  Max(CutOffDate) from InvRegistrarTotal) and BillingCycle not in ('Z','N','Z','ZC','S' )
		--select * from #temp1
		--select Count(distinct c.InvoiceNumber) from [dbo].[InvDetailForCisive2021] c inner join InvRegistrar r on c.InvoiceNumber = r.InvoiceNumber where BillingCycle in ('A') -- (select BillingCycle from #temp1)
		--and  InvoiceMonth = @month and InvoiceYear = @year
		--	select distinct c.InvoiceNumber,BillingCycle,count(c.InvoiceNumber) from [dbo].[InvDetailForCisive2021] c inner join InvRegistrar r on c.InvoiceNumber = r.InvoiceNumber where BillingCycle in  (select BillingCycle from #temp1)
		--and  InvoiceMonth = @month and InvoiceYear = @year
		--group by c.InvoiceNumber,BillingCycle
		--order by count(c.InvoiceNumber) 
    
		select  a.Clno,
	replace(clientname,',', '-')	clientname,
		BillingCycle,
 EOMONTH(cast(c.InvoiceMonth as varchar(2)) +'/1/'+ cast(InvoiceYear as varchar(4)) )as InvoiceDate,
	c.APNO,
isnull(Last,'') + '  '+ First + ' ' + isnull(DeptCode,'') as ApplicantName,
convert(varchar(10), Compdate, 120)  as ReportCompletionDate,
	--c.InvoiceNumber--,	c.InvoiceMonth,	c.InvoiceYear
	'19315793' InvoiceNumber
,replace(c.Description,',','-') Description
,(case when BillingCycle = 'S' and Type<> 0 and Amount <>0 and  isnull(LeadCountInPackage,0) not in (10,11) then 0.00 else Amount end ) as AMT 
    	,PrecheckPrice,	isnull(AdjustedPriceperPackage,0.00) AdjustedPriceperPackage,	isnull(Passthru,0.00) Passthru
		,	NumCase
,Case when LeadCountInPackage in( 2,3,4,5,6,7,8,9,10,11,12,13,14) and AdjustedPriceperPackage > 0  then 1 else 0 end as Leads 
,	isnull(c.Leadtypeid,'') Leadtypeid,
	isnull(LeadtypeDescription,'') LeadtypeDescription,	
	 case when [AdjustedPriceperPackage] <> 0 then [AdjustedPriceperPackage] else
	    case when Passthru <>0 then Passthru else 0.00 end end   as Price ,	
		--case when leadtypedescription  like '%Pass Thru%' then 'PASS THROUGH FEE SALES' Else'SALES' END   [GL Account],	
		--isnull(LeadtypeDescription,'') AS Class,
		isnull(c.Leadtypeid,'')	GLPostItemID, isnull(LeadtypeDescription,'')	GLPostItemName,
		
		--isnull(cast(c.InvoiceNumber as varchar(8) )+ cast(c.leadtypeid as varchar(2)),'')	GLPostUniqueID,
		--case when leadtypedescription  like '%Pass Thru%' then 'PASS THROUGH FEE SALES' Else'SALES' END 	GLPostGLAccount,
		--isnull(leadType,'')	GLPostClass,
			 isnull(cast(19315793 as varchar(8) )+ cast(c.leadtypeid as varchar(2)),'')	GLPostUniqueID,
		 		--c.invoicenumber	GLPostInvoiceNumber
				'19315793' GLPostInvoiceNumber
		--,a.clno,	GLPostCLNO,
			--GLPostRevenue	GLPostCaseVolume	GLPostLeadVolume

,isnull(GLPostNumCases,0) GLPostNumCases
,isnull(GLPostNumLeads,0) GLPostNumLeads
,isnull(GLPostRevenue,0) GLPostRevenue
, case when isnull(GLPostNumLeads,0) = 0 and isnull(GLPostRevenue,0) > 0 then 1 else isnull(GLPostNumLeads,0) end    Quantity
, cast((case when isnull(GLPostNumLeads,0) > 0  and isnull(GLPostRevenue,0) > 0 then isnull(GLPostRevenue,0)/isnull(GLPostNumLeads,0) else isnull(GLPostRevenue,0) end)  AS DECIMAL(18,8) )  Rate
, 'TRUE' IsMonthlyInvoice

into #temp2
from [dbo].[InvDetailToNetsuite] c inner join InvRegistrar r on c.InvoiceNumber = r.InvoiceNumber
left join 
		(select InvoiceNumber,leadtypeid,Sum(GLPostNumCases) as GLPostNumCases, Sum(GLPostNumLeads) GLPostNumLeads,
		cast(sum(GLPostRevenue)  AS DECIMAL(18,8) )  GLPostRevenue 
				from
					(select InvoiceNumber,leadtypeid,Sum(Numcase) as GLPostNumCases, Sum(NumLead) GLPostNumLeads,sum(case when [AdjustedPriceperPackage] <> 0 then [AdjustedPriceperPackage] else
							case when Passthru <>0 then Passthru else 0.00 end end) GLPostRevenue 
					from [dbo].[InvDetailToNetsuite] where  Leadtypeid is not null  group by InvoiceNumber,leadtypeid
					union all
					select InvoiceNumber,2 leadtypeid,0 GLPostNumCases,0 GLPostNumLeads,Sum([AdjustedPriceperPackage]) GLPostRevenue  from  [dbo].[InvDetailToNetsuite] where  type = 0 and Leadtypeid is  null group by InvoiceNumber,leadtypeid) t3
		group by InvoiceNumber,leadtypeid)t2 
		on c.invoicenumber = t2.InvoiceNumber and c.Leadtypeid = t2.Leadtypeid



inner join appl a on c.apno = a.apno
where 
 --BillingCycle in  (select BillingCycle from #temp1)
 --and 
    
	 c.InvoiceNumber in (9315793) --(9282692,9295946)
 --(9282692,9287256,9276710,9281680,9295946)
  --and InvoiceMonth = @month and InvoiceYear = @year
   --and c.apno  = 5299130
 --and c.InvoiceNumber in (9320805,9320806,9320807,9320808)
 --(9320814,9320815,9320816) 7/28 11.pm
 -- (9320388,9320389,9320417,9320418) 7/28/2021
 --(9318504,9318505,9318506,9318507)
 -- (9319924,9319925)
 --(9318803,9318804,9318805)
 --(9308706,9308721) -- (9310500,9310503)
 -- (9309533,9309555)
 --(9306338,9306339)
-- (9306382,9314729) --(9308202,9307327)--( 9306807,9306810)
  --and BillingCycle = 'A'
 and  a.clno <> 3468
  
  order by A.apno 

  select  InvoiceNumber, Count(InvoiceNumber) invcount into #tempInv20000  from #Temp2   group by InvoiceNumber

select InvoiceNumber,apno, sum(AMT) amt into #tempfinal20000  from #Temp2
where   InvoiceNumber in (select InvoiceNumber from #tempInv20000 where invcount > 19999)
 group by InvoiceNumber,apno

 select  Clno,	clientname,	BillingCycle,	InvoiceDate,	APNO,	ApplicantName,	ReportCompletionDate,	InvoiceNumber,	Description,	AMT,	PrecheckPrice,	AdjustedPriceperPackage	,Passthru,	NumCase,	Leads,	Leadtypeid,	LeadtypeDescription,
	Price,	GLPostItemID,	GLPostItemName,	GLPostUniqueID,	GLPostInvoiceNumber,	GLPostNumCases,	GLPostNumLeads,	GLPostRevenue,	Quantity,	cast(Rate AS DECIMAL(18,8)) Rate,	IsMonthlyInvoice
	into #Temp3
  from (
	--		select  Clno,	clientname,	BillingCycle,	InvoiceDate,	tf.APNO,	ApplicantName,	ReportCompletionDate,	tf.InvoiceNumber,	Description,	tf2.AMT,	PrecheckPrice,	AdjustedPriceperPackage	,Passthru,	NumCase,	Leads,	Leadtypeid,	LeadtypeDescription,
	--Price,	GLPostItemID,	GLPostItemName,	GLPostUniqueID,	GLPostInvoiceNumber,	GLPostNumCases,	GLPostNumLeads,	GLPostRevenue,	Quantity,	cast(Rate AS DECIMAL(18,8)) Rate,	IsMonthlyInvoice
	--											from #Temp2 tf inner join #tempfinal20000 tf2 on tf.InvoiceNumber = tf2.InvoiceNumber and tf.apno = tf2.apno
	--											where tf.apno is not null and Leadtypeid = 0 
	--											union all 
			select  Clno,	clientname,	BillingCycle,	InvoiceDate,	APNO,	ApplicantName,	ReportCompletionDate,	InvoiceNumber,	Description,	AMT,	PrecheckPrice,	AdjustedPriceperPackage	,Passthru,	NumCase,	Leads,	Leadtypeid,	LeadtypeDescription,
	Price,	GLPostItemID,	GLPostItemName,	GLPostUniqueID,	GLPostInvoiceNumber,	GLPostNumCases,	GLPostNumLeads,	GLPostRevenue,	Quantity,	cast(Rate AS DECIMAL(18,8)) Rate,	IsMonthlyInvoice
												from #Temp2 where apno is not null --and invoicenumber not in (select distinct  invoicenumber from #tempfinal20000)
												) k
												order by InvoiceNumber,APNO
--select * from #Temp2
--select * from #Temp3

  select InvoiceNumber, amt, GLamt,  diffAmt into #tempdiffAMT from
					(select InvoiceNumber, Sum(amt) amt,Sum(GLamt) GLamt, Sum(amt) - Sum(GLamt) diffAmt from (

					select InvoiceNumber, Sum(amt) amt, 0 GLamt from #Temp3 group by InvoiceNumber
					union all
					select GLPostInvoiceNumber InvoiceNumber,0 amt, cast(sum(Quantity *  Rate)as decimal(10,2)) GLamt 
					from 	(select Distinct GLPostInvoiceNumber,GLPostItemID,GLPostNumLeads,Quantity,Rate from #Temp2 where GLPostItemID <> 0 
					) a  group by GLPostInvoiceNumber,GLPostNumLeads) z 
					
					Group by InvoiceNumber) d
where diffAmt <> 0 order by diffAmt desc

--select * from #tempdiffAMT

select Clno,	clientname,	BillingCycle,	InvoiceDate,	APNO,	ApplicantName,	ReportCompletionDate,	InvoiceNumber,	Description,	AMT,	PrecheckPrice,	AdjustedPriceperPackage	,Passthru,	NumCase,	Leads,	Leadtypeid,	LeadtypeDescription,
	Price,	GLPostItemID,	GLPostItemName,	GLPostUniqueID,	GLPostInvoiceNumber,	GLPostNumCases,	GLPostNumLeads,	GLPostRevenue,	Quantity,	cast(Rate AS DECIMAL(18,8)) Rate,	IsMonthlyInvoice 
	into #Tempfinal from 
 (select  Clno,	clientname,	BillingCycle,	InvoiceDate,	APNO,	ApplicantName,	ReportCompletionDate,	InvoiceNumber,	Description,	AMT,	PrecheckPrice,	AdjustedPriceperPackage	,Passthru,	NumCase,	Leads,	Leadtypeid,	LeadtypeDescription,
	Price,	GLPostItemID,	GLPostItemName,	GLPostUniqueID,	GLPostInvoiceNumber,	GLPostNumCases,	GLPostNumLeads,	GLPostRevenue,	Quantity,	cast(Rate AS DECIMAL(18,8)) Rate,	IsMonthlyInvoice
 from #Temp2
 union all
 select distinct t.clno,clientname,	BillingCycle,	InvoiceDate,	null,	null,	null,	t.InvoiceNumber,	null,	null,	null,	null	,null,	null,	null,	20 Leadtypeid, 'INVADJ'	LeadtypeDescription,
	null,	20 GLPostItemID, 'INVADJ'	GLPostItemName,
	isnull(cast(a.InvoiceNumber as varchar(8) )+ cast(20 as varchar(2)),'')	GLPostUniqueID
	,a.InvoiceNumber	GLPostInvoiceNumber, 1	GLPostNumCases, 1	GLPostNumLeads,diffAmt GLPostRevenue,1 	Quantity, cast(diffAmt AS DECIMAL(18,8)) 	Rate,	 'TRUE' IsMonthlyInvoice
 from #tempdiffAMT a inner join #Temp2 t  on a.InvoiceNumber = t.InvoiceNumber) b

--		select  InvoiceNumber, Count(InvoiceNumber) invcount into #tempInv20000  from #Tempfinal   group by InvoiceNumber

--select InvoiceNumber,apno, sum(AMT) amt into #tempfinal20000  from #Tempfinal 
--where   InvoiceNumber in (select InvoiceNumber from #tempInv20000 where invcount > 19999)
-- group by InvoiceNumber,apno


		select 'Detail' FileType ,Clno,clientname,		BillingCycle, InvoiceDate,	APNO, ApplicantName, ReportCompletionDate,	InvoiceNumber, Description, AMT ,    	--,PrecheckPrice,	AdjustedPriceperPackage,	 Passthru	,	NumCase, Leads , Price ,
		--											'' Leadtypeid, '' LeadtypeDescription,	 	''GLPostItemID,''	GLPostItemName,	'' GLPostUniqueID, '' GLPostInvoiceNumber,''  GLPostNumCases, '' GLPostNumLeads, 0 GLPostRevenue,  0  Quantity, 0 Rate, 
		IsMonthlyInvoice 
												from #Temp3 where apno is not null order by InvoiceNumber,APNO
		--select  'Detail' FileType ,Clno,clientname,		BillingCycle, InvoiceDate,	APNO, ApplicantName, ReportCompletionDate,	InvoiceNumber, Description, AMT ,   
		--IsMonthlyInvoice from (
		--	select  'Detail' FileType ,Clno,clientname,		BillingCycle, InvoiceDate,	tf.APNO, ApplicantName, ReportCompletionDate,	tf.InvoiceNumber, Description, tf2.AMT ,    	--,PrecheckPrice,	AdjustedPriceperPackage,	 Passthru	,	NumCase, Leads , Price ,
		--											 Leadtypeid,  LeadtypeDescription,	 	''GLPostItemID,''	GLPostItemName,	'' GLPostUniqueID, '' GLPostInvoiceNumber,''  GLPostNumCases, '' GLPostNumLeads, 0 GLPostRevenue,  0  Quantity, 0 Rate, 
		--IsMonthlyInvoice 
		--										from #Tempfinal tf inner join #tempfinal20000 tf2 on tf.InvoiceNumber = tf2.InvoiceNumber and tf.apno = tf2.apno
		--										where tf.apno is not null and Leadtypeid = 0 
		--										union all 
		--	select  'Detail' FileType ,Clno,clientname,		BillingCycle, InvoiceDate,	APNO, ApplicantName, ReportCompletionDate,	InvoiceNumber, Description, AMT ,    	--,PrecheckPrice,	AdjustedPriceperPackage,	 Passthru	,	NumCase, Leads , Price ,
		--											 Leadtypeid,  LeadtypeDescription,	 	''GLPostItemID,''	GLPostItemName,	'' GLPostUniqueID, '' GLPostInvoiceNumber,''  GLPostNumCases, '' GLPostNumLeads, 0 GLPostRevenue,  0  Quantity, 0 Rate, 
		--IsMonthlyInvoice 
		--										from #Tempfinal where apno is not null and invoicenumber not in (select distinct  invoicenumber from #tempfinal20000)
		--										) k
		--										order by InvoiceNumber,APNO

												select distinct 'GL' FileType , Clno,InvoiceDate ,-- CONVERT(CHAR(4), InvoiceDate, 100) + CONVERT(CHAR(4),InvoiceDate, 120) as PostingPeriod ,
												'Dec 2025' as PostingPeriod ,
												--InvoiceNumber, 					Leadtypeid,  LeadtypeDescription,	
													GLPostItemID,	GLPostItemName,	 GLPostUniqueID,  GLPostInvoiceNumber, GLPostNumCases, GLPostNumLeads,  GLPostRevenue,    Quantity,  Rate, IsMonthlyInvoice 
					from #Tempfinal where GLPostItemID <> 0 --and GLPostRevenue > 0
					and Quantity >0
						order by GLPostInvoiceNumber

					--select * from #temp2

					--select * from InvDetailForCisive2021 where InvoiceNumber in ( 9306807,9306810) order by Apno,type

  drop table #temp2 
    drop table #temp1 
	 drop table #temp3
	 	  drop table #tempdiffAMT 
    drop table #Tempfinal
	drop table #tempInv20000
	 	  drop table #Tempfinal20000

END



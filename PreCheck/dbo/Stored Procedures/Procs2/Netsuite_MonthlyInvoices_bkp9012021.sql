
-- =============================================
-- Author:		Kiran Miryala
-- Create date: 04/28/2021
-- Description:	Monthly incoice Output for Netsuite thru Celigo
-- =============================================

create PROCEDURE  [dbo].[Netsuite_MonthlyInvoices_bkp9012021]
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
	set @Invdate = '2021-06-30 00:00:00.000'
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
	c.InvoiceNumber--,	c.InvoiceMonth,	c.InvoiceYear
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

		isnull(cast(c.InvoiceNumber as varchar(8) )+ cast(c.leadtypeid as varchar(2)),'')	GLPostUniqueID,
		--case when leadtypedescription  like '%Pass Thru%' then 'PASS THROUGH FEE SALES' Else'SALES' END 	GLPostGLAccount,
		--isnull(leadType,'')	GLPostClass,
		c.invoicenumber	GLPostInvoiceNumber
		--,a.clno,	GLPostCLNO,
			--GLPostRevenue	GLPostCaseVolume	GLPostLeadVolume

,isnull(GLPostNumCases,0) GLPostNumCases
,isnull(GLPostNumLeads,0) GLPostNumLeads
,isnull(GLPostRevenue,0) GLPostRevenue
, case when isnull(GLPostNumLeads,0) = 0 and isnull(GLPostRevenue,0) > 0 then 1 else isnull(GLPostNumLeads,0) end    Quantity
, cast((case when isnull(GLPostNumLeads,0) > 0  and isnull(GLPostRevenue,0) > 0 then isnull(GLPostRevenue,0)/isnull(GLPostNumLeads,0) else isnull(GLPostRevenue,0) end)  AS DECIMAL(18,8) )  Rate
, 'TRUE' IsMonthlyInvoice

into #temp2
from [dbo].[InvDetailForCisive2021] c inner join InvRegistrar r on c.InvoiceNumber = r.InvoiceNumber
left join (select InvoiceNumber,leadtypeid,Sum(GLPostNumCases) as GLPostNumCases, Sum(GLPostNumLeads) GLPostNumLeads,
cast(sum(GLPostRevenue)  AS DECIMAL(18,8) )  GLPostRevenue 
		from
(select InvoiceNumber,leadtypeid,Sum(Numcase) as GLPostNumCases, Sum(NumLead) GLPostNumLeads,sum(case when [AdjustedPriceperPackage] <> 0 then [AdjustedPriceperPackage] else
	    case when Passthru <>0 then Passthru else 0.00 end end) GLPostRevenue 
from InvDetailForCisive2021   group by InvoiceNumber,leadtypeid
union all
select InvoiceNumber,2 leadtypeid,0 GLPostNumCases,0 GLPostNumLeads,Sum([AdjustedPriceperPackage]) GLPostRevenue  from  InvDetailForCisive2021 where  type = 0 group by InvoiceNumber,leadtypeid) t3
group by InvoiceNumber,leadtypeid)t2 on c.invoicenumber = t2.InvoiceNumber and c.Leadtypeid = t2.Leadtypeid

--(select InvoiceNumber,leadtypeid,Sum(Numcase) as GLPostNumCases, Sum(NumLead) GLPostNumLeads,sum(case when [AdjustedPriceperPackage] <> 0 then [AdjustedPriceperPackage] else
--	    case when Passthru <>0 then Passthru else 0.00 end end) GLPostRevenue 
--from InvDetailForCisive2021 
--where InvoiceNumber = 9308668
--group by InvoiceNumber,leadtypeid) 
--t2 on c.invoicenumber = t2.InvoiceNumber and c.Leadtypeid = t2.Leadtypeid


inner join appl a on c.apno = a.apno
where  BillingCycle in  (select BillingCycle from #temp1)
-- abd c.InvoiceNumber = 9308668
  and InvoiceMonth = @month and InvoiceYear = @year
   --and c.apno  = 5299130
and c.InvoiceNumber in --(9320150,9320144,9320142)
(9319658,9320345,9320560,9318307)
--(9319656,9318925,9319990,9320390)
 -- (9320805,9320806,9320807,9320808)
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
 --and 
  
  order by A.apno 



  select InvoiceNumber, amt, GLamt,  diffAmt into #tempdiffAMT from
					(select InvoiceNumber, Sum(amt) amt,Sum(GLamt) GLamt, Sum(amt) - Sum(GLamt) diffAmt from (

					select InvoiceNumber, Sum(amt) amt, 0 GLamt from #temp2 group by InvoiceNumber
					union all
					select GLPostInvoiceNumber InvoiceNumber,0 amt, cast(sum(Quantity *  Rate)as decimal(10,2)) GLamt 
					from 	(select Distinct GLPostInvoiceNumber,GLPostItemID,GLPostNumLeads,Quantity,Rate from #temp2 --where GLPostItemID <> 0 and GLPostRevenue > 0 
					) a  group by GLPostInvoiceNumber,GLPostNumLeads) z 
					
					Group by InvoiceNumber) d
where diffAmt <> 0 order by diffAmt desc

--select * from #tempdiffAMT

select Clno,	clientname,	BillingCycle,	InvoiceDate,	APNO,	ApplicantName,	ReportCompletionDate,	InvoiceNumber,	Description,	AMT,	PrecheckPrice,	AdjustedPriceperPackage	,Passthru,	NumCase,	Leads,	Leadtypeid,	LeadtypeDescription,
	Price,	GLPostItemID,	GLPostItemName,	GLPostUniqueID,	GLPostInvoiceNumber,	GLPostNumCases,	GLPostNumLeads,	GLPostRevenue,	Quantity,	cast(Rate AS DECIMAL(18,8)) Rate,	IsMonthlyInvoice 
	into #Tempfinal from 
 (select  Clno,	clientname,	BillingCycle,	InvoiceDate,	APNO,	ApplicantName,	ReportCompletionDate,	InvoiceNumber,	Description,	AMT,	PrecheckPrice,	AdjustedPriceperPackage	,Passthru,	NumCase,	Leads,	Leadtypeid,	LeadtypeDescription,
	Price,	GLPostItemID,	GLPostItemName,	GLPostUniqueID,	GLPostInvoiceNumber,	GLPostNumCases,	GLPostNumLeads,	GLPostRevenue,	Quantity,	cast(Rate AS DECIMAL(18,8)) Rate,	IsMonthlyInvoice
 from #temp2
 union all
 select distinct t.clno,clientname,	BillingCycle,	InvoiceDate,	null,	null,	null,	t.InvoiceNumber,	null,	null,	null,	null	,null,	null,	null,	20 Leadtypeid, 'INVADJ'	LeadtypeDescription,
	null,	20 GLPostItemID, 'INVADJ'	GLPostItemName,
	isnull(cast(a.InvoiceNumber as varchar(8) )+ cast(20 as varchar(2)),'')	GLPostUniqueID
	,a.InvoiceNumber	GLPostInvoiceNumber, 1	GLPostNumCases, 1	GLPostNumLeads,diffAmt GLPostRevenue,1 	Quantity, cast(diffAmt AS DECIMAL(18,8)) 	Rate,	 'TRUE' IsMonthlyInvoice
 from #tempdiffAMT a inner join #temp2 t  on a.InvoiceNumber = t.InvoiceNumber) b

-- select InvoiceNumber, amt, GLamt,  diffAmt  from
--					(select InvoiceNumber, Sum(amt) amt,Sum(GLamt) GLamt, Sum(amt) - Sum(GLamt) diffAmt from (

--					select InvoiceNumber, Sum(amt) amt, 0 GLamt from #Tempfinal group by InvoiceNumber
--					union all
--					select GLPostInvoiceNumber InvoiceNumber,0 amt, cast(sum(Quantity *  Rate)as decimal(10,2)) GLamt 
--					from 	(select Distinct GLPostInvoiceNumber,GLPostItemID,GLPostNumLeads,Quantity,Rate from #Tempfinal  ) a  group by GLPostInvoiceNumber,GLPostNumLeads) z 
					
--					Group by InvoiceNumber) d
--where diffAmt <> 0 order by diffAmt desc


  --select --BillingCycle as FileType,
  --InvoiceNumber,count(InvoiceNumber)
  -- from #temp2
  -- group by InvoiceNumber
  -- order by InvoiceNumber
  --select Top 1000 1 FileType, * from #temp2 order by apno ,Leadtypeid

   --select  distinct  InvoiceNumber into #temp3
   --from #temp2
   --order by InvoiceNumber
   --declare @index int = 1
   --declare @fileID int = 1


  --While (@Index <= (select count(InvoiceNumber) from #temp3) )
		--Begin
		----select count(InvoiceNumber) from #temp3
		--DROP TABLE IF EXISTS #temp4;
		--select Top 150 InvoiceNumber  into #temp4 from #temp3

		--	if (Select count(invoicenumber) from #temp2 where InvoiceNumber in (select InvoiceNumber from #temp4)) > 40000
		--		begin
		--			DROP TABLE IF EXISTS #temp5;
		--			select Top 125 InvoiceNumber  into #temp5 from #temp3
		--			if (Select count(invoicenumber) from #temp2 where InvoiceNumber in (select InvoiceNumber from #temp5)) > 40000
		--					begin
		--						DROP TABLE IF EXISTS #temp6;
		--						select Top 100 InvoiceNumber  into #temp6 from #temp3
		--						if (Select count(invoicenumber) from #temp2 where InvoiceNumber in (select InvoiceNumber from #temp6)) > 40000
		--								begin
		--									DROP TABLE IF EXISTS #temp7;
		--									select Top 75 InvoiceNumber  into #temp7 from #temp3
		--									--select @fileID FileType,* from #temp2 where InvoiceNumber in (select InvoiceNumber from #temp7) order by clno,Apno,Leadtypeid
		--									   select @fileID FileType,Clno,clientname,		BillingCycle, InvoiceDate,	APNO, ApplicantName, ReportCompletionDate,	InvoiceNumber, Description, AMT ,PrecheckPrice,	AdjustedPriceperPackage,	 Passthru	,	NumCase, Leads ,  Price ,
		--											Leadtypeid, LeadtypeDescription,			GLPostItemID,	GLPostItemName,	GLPostUniqueID,	GLPostInvoiceNumber, GLPostNumCases, GLPostNumLeads, GLPostRevenue,   Quantity, Rate, IsMonthlyInvoice 
		--											from

		--												(	select Clno,clientname,		BillingCycle, InvoiceDate,	APNO, ApplicantName, ReportCompletionDate,	InvoiceNumber, Description, AMT     	,PrecheckPrice,	AdjustedPriceperPackage,	 Passthru	,	NumCase, Leads , Price ,
		--											'' Leadtypeid, '' LeadtypeDescription,	 	''GLPostItemID,''	GLPostItemName,	'' GLPostUniqueID, '' GLPostInvoiceNumber,''  GLPostNumCases, '' GLPostNumLeads, 0 GLPostRevenue,  0  Quantity, 0 Rate, IsMonthlyInvoice 
		--											from #temp2 where InvoiceNumber in (select InvoiceNumber from #temp7) 
		--											union all
		--												select distinct ''  Clno,'' clientname,	'' 	BillingCycle, '' InvoiceDate,	'' APNO, '' ApplicantName,''  ReportCompletionDate,	'' InvoiceNumber, '' Description,0  AMT     	,0 PrecheckPrice,	0 AdjustedPriceperPackage,	0  Passthru	,0 	NumCase, '' Leads , 0 Price,
		--											 Leadtypeid,  LeadtypeDescription,		GLPostItemID,	GLPostItemName,	 GLPostUniqueID,  GLPostInvoiceNumber, GLPostNumCases, GLPostNumLeads,  GLPostRevenue,    Quantity,  Rate, IsMonthlyInvoice 
		--											 from #temp2 where InvoiceNumber in (select InvoiceNumber from #temp7) and Leadtypeid <> 0 ) t 
		--											 order by clno,Apno,Leadtypeid
		--									delete #temp3 where InvoiceNumber in (select InvoiceNumber from #temp7)
		--								end
		--							else
		--								begin
		--									--select @fileID FileType,* from #temp2 where InvoiceNumber in (select InvoiceNumber from #temp6) order by clno,Apno,Leadtypeid
		--									select @fileID FileType,Clno,clientname,		BillingCycle, InvoiceDate,	APNO, ApplicantName, ReportCompletionDate,	InvoiceNumber, Description, AMT ,PrecheckPrice,	AdjustedPriceperPackage,	 Passthru	,	NumCase, Leads ,  Price ,
		--											Leadtypeid, LeadtypeDescription,			GLPostItemID,	GLPostItemName,	GLPostUniqueID,	GLPostInvoiceNumber, GLPostNumCases, GLPostNumLeads, GLPostRevenue,   Quantity, Rate, IsMonthlyInvoice 
		--											from

		--												(	select Clno,clientname,		BillingCycle, InvoiceDate,	APNO, ApplicantName, ReportCompletionDate,	InvoiceNumber, Description, AMT     	,PrecheckPrice,	AdjustedPriceperPackage,	 Passthru	,	NumCase, Leads , Price ,
		--											'' Leadtypeid, '' LeadtypeDescription,	 	''GLPostItemID,''	GLPostItemName,	'' GLPostUniqueID, '' GLPostInvoiceNumber,''  GLPostNumCases, '' GLPostNumLeads, 0 GLPostRevenue,  0  Quantity, 0 Rate, IsMonthlyInvoice 
		--											from #temp2 where InvoiceNumber in (select InvoiceNumber from #temp6) 
		--											union all
		--												select distinct ''  Clno,'' clientname,	'' 	BillingCycle, '' InvoiceDate,	'' APNO, '' ApplicantName,''  ReportCompletionDate,	'' InvoiceNumber, '' Description,0  AMT     	,0 PrecheckPrice,	0 AdjustedPriceperPackage,	0  Passthru	,0 	NumCase, '' Leads , 0 Price,
		--											 Leadtypeid,  LeadtypeDescription,		GLPostItemID,	GLPostItemName,	 GLPostUniqueID,  GLPostInvoiceNumber, GLPostNumCases, GLPostNumLeads,  GLPostRevenue,    Quantity,  Rate, IsMonthlyInvoice 
		--											 from #temp2 where InvoiceNumber in (select InvoiceNumber from #temp6) and Leadtypeid <> 0 ) t 
		--											 order by clno,Apno,Leadtypeid
		--										delete #temp3 where InvoiceNumber in (select InvoiceNumber from #temp6)
							
		--								end
								
		--					end
		--				else
		--				begin
		--					--Select @fileID FileType,* from #temp2 where InvoiceNumber in (select InvoiceNumber from #temp5)  order by clno,Apno,Leadtypeid
		--					select @fileID FileType,Clno,clientname,		BillingCycle, InvoiceDate,	APNO, ApplicantName, ReportCompletionDate,	InvoiceNumber, Description, AMT ,PrecheckPrice,	AdjustedPriceperPackage,	 Passthru	,	NumCase, Leads ,  Price ,
		--					Leadtypeid, LeadtypeDescription,			GLPostItemID,	GLPostItemName,	GLPostUniqueID,	GLPostInvoiceNumber, GLPostNumCases, GLPostNumLeads, GLPostRevenue,   Quantity, Rate, IsMonthlyInvoice 
		--					from

		--						(	select Clno,clientname,		BillingCycle, InvoiceDate,	APNO, ApplicantName, ReportCompletionDate,	InvoiceNumber, Description, AMT     	,PrecheckPrice,	AdjustedPriceperPackage,	 Passthru	,	NumCase, Leads , Price ,
		--					'' Leadtypeid, '' LeadtypeDescription,	 	''GLPostItemID,''	GLPostItemName,	'' GLPostUniqueID, '' GLPostInvoiceNumber,''  GLPostNumCases, '' GLPostNumLeads, 0 GLPostRevenue,  0  Quantity, 0 Rate, IsMonthlyInvoice 
		--					from #temp2 where InvoiceNumber in (select InvoiceNumber from #temp5) 
		--					union all
		--						select distinct ''  Clno,'' clientname,	'' 	BillingCycle, '' InvoiceDate,	'' APNO, '' ApplicantName,''  ReportCompletionDate,	'' InvoiceNumber, '' Description,0  AMT     	,0 PrecheckPrice,	0 AdjustedPriceperPackage,	0  Passthru	,0 	NumCase, '' Leads , 0 Price,
		--						Leadtypeid,  LeadtypeDescription,		GLPostItemID,	GLPostItemName,	 GLPostUniqueID,  GLPostInvoiceNumber, GLPostNumCases, GLPostNumLeads,  GLPostRevenue,    Quantity,  Rate, IsMonthlyInvoice 
		--						from #temp2 where InvoiceNumber in (select InvoiceNumber from #temp5) and Leadtypeid <> 0 ) t 
		--						order by clno,Apno,Leadtypeid
		--					delete #temp3 where InvoiceNumber in (select InvoiceNumber from #temp5)
		--			end
		--		end
		--	else
		--	begin
		--		--select @fileID FileType,* from #temp2 where InvoiceNumber in (select InvoiceNumber from #temp4)  order by clno,Apno,Leadtypeid
		--		select @fileID FileType,Clno,clientname,		BillingCycle, InvoiceDate,	APNO, ApplicantName, ReportCompletionDate,	InvoiceNumber, Description, AMT ,PrecheckPrice,	AdjustedPriceperPackage,	 Passthru	,	NumCase, Leads ,  Price ,
		--		Leadtypeid, LeadtypeDescription,			GLPostItemID,	GLPostItemName,	GLPostUniqueID,	GLPostInvoiceNumber, GLPostNumCases, GLPostNumLeads, GLPostRevenue,   Quantity, Rate, IsMonthlyInvoice 
		--		from

		--			(	select Clno,clientname,		BillingCycle, InvoiceDate,	APNO, ApplicantName, ReportCompletionDate,	InvoiceNumber, Description, AMT     	,PrecheckPrice,	AdjustedPriceperPackage,	 Passthru	,	NumCase, Leads , Price ,
		--		'' Leadtypeid, '' LeadtypeDescription,	 	''GLPostItemID,''	GLPostItemName,	'' GLPostUniqueID, '' GLPostInvoiceNumber,''  GLPostNumCases, '' GLPostNumLeads, 0 GLPostRevenue,  0  Quantity, 0 Rate, IsMonthlyInvoice 
		--		from #temp2 where InvoiceNumber in (select InvoiceNumber from #temp4) 
		--		union all
		--			select distinct ''  Clno,'' clientname,	'' 	BillingCycle, '' InvoiceDate,	'' APNO, '' ApplicantName,''  ReportCompletionDate,	'' InvoiceNumber, '' Description,0  AMT     	,0 PrecheckPrice,	0 AdjustedPriceperPackage,	0  Passthru	,0 	NumCase, '' Leads , 0 Price,
		--			Leadtypeid,  LeadtypeDescription,		GLPostItemID,	GLPostItemName,	 GLPostUniqueID,  GLPostInvoiceNumber, GLPostNumCases, GLPostNumLeads,  GLPostRevenue,    Quantity,  Rate, IsMonthlyInvoice 
		--			from #temp2 where InvoiceNumber in (select InvoiceNumber from #temp4) and Leadtypeid <> 0 ) t 
		--			order by clno,Apno,Leadtypeid
		--		delete #temp3 where InvoiceNumber in (select InvoiceNumber from #temp4)
		--	end
		--set @fileID = @fileID+1
		--end
		select  InvoiceNumber, Count(InvoiceNumber) invcount into #tempInv20000  from #Tempfinal   group by InvoiceNumber

select InvoiceNumber,apno, sum(AMT) amt into #tempfinal20000  from #Tempfinal 
where   InvoiceNumber in (select InvoiceNumber from #tempInv20000 where invcount > 19999)
 group by InvoiceNumber,apno


		--select 'Detail' FileType ,Clno,clientname,		BillingCycle, InvoiceDate,	APNO, ApplicantName, ReportCompletionDate,	InvoiceNumber, Description, AMT ,    	--,PrecheckPrice,	AdjustedPriceperPackage,	 Passthru	,	NumCase, Leads , Price ,
		----											'' Leadtypeid, '' LeadtypeDescription,	 	''GLPostItemID,''	GLPostItemName,	'' GLPostUniqueID, '' GLPostInvoiceNumber,''  GLPostNumCases, '' GLPostNumLeads, 0 GLPostRevenue,  0  Quantity, 0 Rate, 
		--IsMonthlyInvoice 
		--										from #Tempfinal where apno is not null
		select  'Detail' FileType ,Clno,clientname,		BillingCycle, InvoiceDate,	APNO, ApplicantName, ReportCompletionDate,	InvoiceNumber, Description, AMT ,   
		IsMonthlyInvoice from (
			select  'Detail' FileType ,Clno,clientname,		BillingCycle, InvoiceDate,	tf.APNO, ApplicantName, ReportCompletionDate,	tf.InvoiceNumber, Description, tf2.AMT ,    	--,PrecheckPrice,	AdjustedPriceperPackage,	 Passthru	,	NumCase, Leads , Price ,
													 --Leadtypeid,  LeadtypeDescription,	 	''GLPostItemID,''	GLPostItemName,	'' GLPostUniqueID, '' GLPostInvoiceNumber,''  GLPostNumCases, '' GLPostNumLeads, 0 GLPostRevenue,  0  Quantity, 0 Rate, 
		IsMonthlyInvoice 
												from #Tempfinal tf inner join #tempfinal20000 tf2 on tf.InvoiceNumber = tf2.InvoiceNumber and tf.apno = tf2.apno
												where tf.apno is not null and Leadtypeid = 0 
												union all 
			select  'Detail' FileType ,Clno,clientname,		BillingCycle, InvoiceDate,	APNO, ApplicantName, ReportCompletionDate,	InvoiceNumber, Description, AMT ,    	--,PrecheckPrice,	AdjustedPriceperPackage,	 Passthru	,	NumCase, Leads , Price ,
													-- Leadtypeid,  LeadtypeDescription,	 	''GLPostItemID,''	GLPostItemName,	'' GLPostUniqueID, '' GLPostInvoiceNumber,''  GLPostNumCases, '' GLPostNumLeads, 0 GLPostRevenue,  0  Quantity, 0 Rate, 
		IsMonthlyInvoice 
												from #Tempfinal where apno is not null and invoicenumber not in (select distinct  invoicenumber from #tempfinal20000)
												) k
												order by InvoiceNumber,APNO

												select distinct 'GL' FileType , Clno,InvoiceDate ,-- CONVERT(CHAR(4), InvoiceDate, 100) + CONVERT(CHAR(4),InvoiceDate, 120) as PostingPeriod ,
												'March 2024' as PostingPeriod ,
												--InvoiceNumber, 					Leadtypeid,  LeadtypeDescription,	
													GLPostItemID,	GLPostItemName,	 GLPostUniqueID,  GLPostInvoiceNumber, GLPostNumCases, GLPostNumLeads,  GLPostRevenue,    Quantity,  Rate, IsMonthlyInvoice 
					from #Tempfinal where GLPostItemID <> 0 --and GLPostRevenue > 0
						order by GLPostInvoiceNumber

					--select * from #temp2

					--select * from InvDetailForCisive2021 where InvoiceNumber in ( 9306807,9306810) order by Apno,type

  drop table #temp2 
    drop table #temp1 
	 --drop table #temp3
	 	  drop table #tempdiffAMT 
    drop table #Tempfinal
	drop table #tempInv20000
	 	  drop table #Tempfinal20000

END



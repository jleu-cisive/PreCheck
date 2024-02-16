
-- =============================================
-- Author:		Kiran Miryala
-- Create date: 04/28/2021
-- Description:	Monthly incoice Output for Netsuite thru Celigo
-- =============================================

CREATE PROCEDURE  [dbo].[Netsuite_MonthlyInvoices_bkp10212021]
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
	set @Invdate = '2021-08-31 00:00:00.000'
	set @month = MONTH(@Invdate)
	set @year = year(@Invdate)
	-- Insert statements for procedure here
	--select distinct invoicemonth from  InvDetailToNetsuite

	-- This block of code is used to group and calculate GL data at the invoicenumber and leadtypeid
	
select InvoiceNumber,leadtypeid,Sum(GLPostNumCases) as GLPostNumCases, Sum(GLPostNumLeads) GLPostNumLeads,
cast(sum(GLPostRevenue)  AS DECIMAL(18,8) )  GLPostRevenue  into #tempGL
		from
(select InvoiceNumber,leadtypeid,Sum(Numcase) as GLPostNumCases, Sum(NumLead) GLPostNumLeads,sum(case when [AdjustedPriceperPackage] <> 0 then [AdjustedPriceperPackage] else
	    case when Passthru <>0 then Passthru else 0.00 end end) GLPostRevenue 
from InvDetailToNetsuite where leadtypeid is not null  and  InvoiceMonth = @month and InvoiceYear = @year  group by InvoiceNumber,leadtypeid
union all
select InvoiceNumber,2 leadtypeid,0 GLPostNumCases,0 GLPostNumLeads,Sum([AdjustedPriceperPackage]) GLPostRevenue  from  InvDetailToNetsuite where  type = 0 and leadtypeid is null
 and  InvoiceMonth = @month and InvoiceYear = @year
 group by InvoiceNumber,leadtypeid) t3
 where GLPostRevenue <> 0

 --InvoiceNumber  in (9309614,9309084,9309313)
group by InvoiceNumber,leadtypeid


--select * from #tempgl --where leadtypeid = 2 and GLPostNumLeads = 0

Select InvoiceNumber, min(leadtypeid) leadtypeid  into #tempGLUpdate from #tempgl where leadtypeid <> 2 and InvoiceNumber in (select InvoiceNumber from #tempgl where leadtypeid = 2 and GLPostNumLeads = 0)
group by InvoiceNumber

--select * from #tempgl gl inner join #tempGLUpdate u on gl.InvoiceNumber = u.InvoiceNumber
--where gl.leadtypeid = 2 and gl.GLPostNumLeads = 0

update gl set gl.leadtypeid = u.leadtypeid
from #tempgl gl inner join #tempGLUpdate u on gl.InvoiceNumber = u.InvoiceNumber
where gl.leadtypeid = 2 and gl.GLPostNumLeads = 0

	--select distinct BillingCycle from InvRegistrarTotal where CutOffDate = (  select  Max(CutOffDate) from InvRegistrarTotal) and BillingCycle not in ('Z','zc','N','S')
		select distinct BillingCycle into #temp1 from InvRegistrarTotal where CutOffDate = (  select  Max(CutOffDate) from InvRegistrarTotal) and BillingCycle not in ('Z','N','Z','ZC','S' )
		--select * from #temp1
		--select Count(distinct c.InvoiceNumber) from [dbo].[InvDetailToNetsuite] c inner join InvRegistrar r on c.InvoiceNumber = r.InvoiceNumber where BillingCycle in ('A') -- (select BillingCycle from #temp1)
		--and  InvoiceMonth = @month and InvoiceYear = @year
		--	select distinct c.InvoiceNumber,BillingCycle,count(c.InvoiceNumber) from [dbo].[InvDetailToNetsuite] c inner join InvRegistrar r on c.InvoiceNumber = r.InvoiceNumber where BillingCycle in  (select BillingCycle from #temp1)
		--and  InvoiceMonth = @month and InvoiceYear = @year
		--group by c.InvoiceNumber,BillingCycle
		--order by count(c.InvoiceNumber) 
    
	select  R.Clno,
	replace(clientname,',', '-')	clientname,
		BillingCycle,
 EOMONTH(cast(c.InvoiceMonth as varchar(2)) +'/1/'+ cast(InvoiceYear as varchar(4)) )as InvoiceDate,
	c.APNO,
replace(isnull(Last,'') + '  '+ First + ' ' + isnull(DeptCode,''),',',' ') as ApplicantName,
convert(varchar(10), Compdate, 120)  as ReportCompletionDate,
	c.InvoiceNumber
	--cast(c.InvoiceNumber as varchar(10))+ 'A' as InvoiceNumber
	----,	c.InvoiceMonth,	c.InvoiceYear
,replace(replace(replace(c.Description,',','-'),CHAR(10),''),char(13),'') Description
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
		isnull(cast(c.InvoiceNumber as varchar(8) ) + cast(c.leadtypeid as varchar(2)),'')	GLPostUniqueID,
		--isnull(cast(c.InvoiceNumber as varchar(8) ) + 'A'+ cast(c.leadtypeid as varchar(2)),'')	GLPostUniqueID,
		--case when leadtypedescription  like '%Pass Thru%' then 'PASS THROUGH FEE SALES' Else'SALES' END 	GLPostGLAccount,
		--isnull(leadType,'')	GLPostClass,
		c.invoicenumber	GLPostInvoiceNumber
		--cast(c.InvoiceNumber as varchar(10))+ 'A' as GLPostInvoiceNumber
		--,a.clno,	GLPostCLNO,
			--GLPostRevenue	GLPostCaseVolume	GLPostLeadVolume

,isnull(GLPostNumCases,0) GLPostNumCases
,isnull(GLPostNumLeads,0) GLPostNumLeads
,isnull(t2.GLPostRevenue,0) GLPostRevenue 
, case when isnull(GLPostNumLeads,0) = 0 and isnull(GLPostRevenue,0) > 0 then 1 else isnull(GLPostNumLeads,0) end    Quantity
, cast((case when isnull(GLPostNumLeads,0) > 0  and isnull(GLPostRevenue,0) > 0 then isnull(GLPostRevenue,0)/isnull(GLPostNumLeads,0) else isnull(GLPostRevenue,0) end)  AS DECIMAL(18,8) )  Rate
, 'TRUE' IsMonthlyInvoice
,c.type
into #temp2
from [dbo].[InvDetailToNetsuite] c 
inner join (SELECT DISTINCT InvoiceNumber,BillingCycle,CLNO,clientname FROM  InvRegistrar WHERE MONTH(CutoffDate) = @month and year(CutoffDate) = @year) r  on c.InvoiceNumber = r.InvoiceNumber
--left join 
--(select InvoiceNumber,leadtypeid,Sum(GLPostNumCases) as GLPostNumCases, Sum(GLPostNumLeads) GLPostNumLeads,
--cast(sum(GLPostRevenue)  AS DECIMAL(18,8) )  GLPostRevenue 
--		from
--(select InvoiceNumber,leadtypeid,Sum(Numcase) as GLPostNumCases, Sum(NumLead) GLPostNumLeads,sum(case when [AdjustedPriceperPackage] <> 0 then [AdjustedPriceperPackage] else
--	    case when Passthru <>0 then Passthru else 0.00 end end) GLPostRevenue 
--from InvDetailToNetsuite where leadtypeid is not null  group by InvoiceNumber,leadtypeid
--union all
--select InvoiceNumber,2 leadtypeid,0 GLPostNumCases,0 GLPostNumLeads,Sum([AdjustedPriceperPackage]) GLPostRevenue  from  InvDetailToNetsuite where  type = 0 and leadtypeid is null
-- group by InvoiceNumber,leadtypeid) t3
--group by InvoiceNumber,leadtypeid) t2 on c.invoicenumber = t2.InvoiceNumber and c.Leadtypeid = t2.Leadtypeid
left join (select InvoiceNumber,leadtypeid,Sum(GLPostNumCases) as GLPostNumCases, Sum(GLPostNumLeads) GLPostNumLeads,
cast(sum(GLPostRevenue)  AS DECIMAL(18,8) )  GLPostRevenue  
		from #tempgl group by InvoiceNumber,leadtypeid) t2 on c.invoicenumber = t2.InvoiceNumber and c.Leadtypeid = t2.Leadtypeid

--(select InvoiceNumber,leadtypeid,Sum(Numcase) as GLPostNumCases, Sum(NumLead) GLPostNumLeads,sum(case when [AdjustedPriceperPackage] <> 0 then [AdjustedPriceperPackage] else
--	    case when Passthru <>0 then Passthru else 0.00 end end) GLPostRevenue 
--from InvDetailToNetsuite 
--where InvoiceNumber = 9308668
--group by InvoiceNumber,leadtypeid) 
--t2 on c.invoicenumber = t2.InvoiceNumber and c.Leadtypeid = t2.Leadtypeid


inner join appl a on c.apno = a.apno
where  BillingCycle in  (select BillingCycle from #temp1)

  and InvoiceMonth = @month and InvoiceYear = @year
   --and c.apno  = 5299130
   and c.InvoiceNumber in (9324654)
-- (9321133,9322341,9322624,9322721,9323360)
--(9320931,9320935,9321019,9321041,9321034,9321027,9321044,9321095,9321133,9321355,9321367,9321391,9321389,9321404,9321422,9321484,9321988,9322077,9322105,9322099
--,9322124,9322122,9322116,9322128,
--9322127,9322147,9322146,9322139,9322148,9322158,9322165,9322160,9322161,9322257,9322262,9322275,9322316,9322302,9322334,9322356,9322352,9322341,9322376,9322392,9322395,9322380,
--9322384,9322387,9322453,9322466,9322463,9322484,9322480,9322487,9322532,9322520,9322536,9322539,9322544,9322556,9322553,9322600,9322624,9322628,9322627,9322658,9322657,9322651,
--9322650,9322672,9322671,9322697,9322698,9322689,9322691,9322684,9322717,9322709,9322719,9322712,9322715,9322702,9322721,9322738,9322911,9322925,9322976,
--9322961,9322990,9322982,9322987,9323007,9323025,9323021,9323045,9323071,9323097,9323080,9323091,9323100,9323111,9323135,9323155,9323148,9323166,9323173,9323185,
--9323192,9323208,9323250,9323270,9323299,9323325,9323329,9323360,9323436,9323447,9323483,9323484,9323490 ) 
--AND A.CLNO NOT IN (3468)
--and r.clno in (2167,15591,10865,14858,15349,3035,15389,10045,1616,12643,14368,13248)  
--and r.clno not in (2167,12693 ,1616,13366,16014,16231,14877)
-- 9322216 mvr
--(9320150,9320144,9320142)
--(9319658,9320345,9320560,9318307)
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

-- select InvoiceNumber,leadtypeid,Sum(GLPostNumCases) as GLPostNumCases, Sum(GLPostNumLeads) GLPostNumLeads,
--cast(sum(GLPostRevenue)  AS DECIMAL(18,8) )  GLPostRevenue 
--		from
--(select InvoiceNumber,leadtypeid,Sum(Numcase) as GLPostNumCases, Sum(NumLead) GLPostNumLeads,sum(case when [AdjustedPriceperPackage] <> 0 then [AdjustedPriceperPackage] else
--	    case when Passthru <>0 then Passthru else 0.00 end end) GLPostRevenue 
--from InvDetailToNetsuite where leadtypeid is not null  group by InvoiceNumber,leadtypeid
--union all
--select InvoiceNumber,2 leadtypeid,0 GLPostNumCases,0 GLPostNumLeads,Sum([AdjustedPriceperPackage]) GLPostRevenue  from  InvDetailToNetsuite where  type = 0 and leadtypeid is null
-- group by InvoiceNumber,leadtypeid) t3
-- where  InvoiceNumber = 9311358
--group by InvoiceNumber,leadtypeid

--select InvoiceNumber,leadtypeid,Sum(Numcase) as GLPostNumCases, Sum(NumLead) GLPostNumLeads,sum(case when [AdjustedPriceperPackage] <> 0 then [AdjustedPriceperPackage] else
--	    case when Passthru <>0 then Passthru else 0.00 end end) GLPostRevenue 
--from InvDetailToNetsuite where leadtypeid is not null and InvoiceNumber in (9311358)  group by InvoiceNumber,leadtypeid

--select InvoiceNumber,2 leadtypeid,0 GLPostNumCases,0 GLPostNumLeads,Sum([AdjustedPriceperPackage]) GLPostRevenue  from  InvDetailToNetsuite 
--where  type = 0 and leadtypeid is null  and InvoiceNumber in (9311358)
--group by InvoiceNumber,leadtypeid
--select InvoiceNumber, Sum(amt) amt, 0 GLamt from #temp2 group by InvoiceNumber
			
--			select InvoiceNumber,sum(GLamt) a from (
--					select GLPostInvoiceNumber InvoiceNumber,0 amt, cast(sum(Quantity *  Rate)as decimal(10,2)) GLamt 
--					from 	(select Distinct GLPostInvoiceNumber,GLPostItemID,GLPostNumLeads,Quantity,Rate from #temp2) a  group by GLPostInvoiceNumber,GLPostNumLeads)k group by InvoiceNumber
  select * from #temp2 order by APNO,type
  --select Distinct GLPostInvoiceNumber,GLPostItemID,GLPostNumLeads,Quantity,Rate from #temp2

  select InvoiceNumber, amt, GLamt,  diffAmt into #tempdiffAMT from
					(select InvoiceNumber, Sum(amt) amt,Sum(GLamt) GLamt, Sum(amt) - Sum(GLamt) diffAmt from (

					select InvoiceNumber, Sum(amt) amt, 0 GLamt from #temp2 group by InvoiceNumber
					union all
					select GLPostInvoiceNumber InvoiceNumber,0 amt, sum(GLamt) GLamt 
					from 	(select Distinct GLPostInvoiceNumber,GLPostItemID,GLPostNumLeads,Quantity,Rate,cast((Quantity *  Rate)as decimal(10,2)) GLamt   from #temp2 where  GLPostRevenue > 0 
					) a  group by GLPostInvoiceNumber,GLPostNumLeads) z 
					
					Group by InvoiceNumber) d
where diffAmt <> 0 order by diffAmt desc

	select * from #tempdiffAMT order by diffAmt desc

--select distinct t.clno,clientname,	BillingCycle,	InvoiceDate,	null,	null,	null,	t.InvoiceNumber,	null,	null,	null,	null	,null,	null,	null,	20 Leadtypeid, 'INVADJ'	LeadtypeDescription,
--	null,	20 GLPostItemID, 'INVADJ'	GLPostItemName,
--	isnull(cast(a.InvoiceNumber as varchar(8) )+ cast(20 as varchar(2)),'')	GLPostUniqueID
--	,a.InvoiceNumber	GLPostInvoiceNumber, 1	GLPostNumCases, 1	GLPostNumLeads,diffAmt GLPostRevenue,1 	Quantity, cast(diffAmt AS DECIMAL(18,8)) 	Rate,	 'TRUE' IsMonthlyInvoice
-- from #tempdiffAMT a inner join #temp2 t  on a.InvoiceNumber = t.InvoiceNumber

select Clno,	clientname,	BillingCycle,	InvoiceDate,	APNO,	ApplicantName,	ReportCompletionDate,	InvoiceNumber,	Description,	AMT,	PrecheckPrice,	AdjustedPriceperPackage	,Passthru,	NumCase,	Leads,	Leadtypeid,	LeadtypeDescription,
	Price,	GLPostItemID,	GLPostItemName,	GLPostUniqueID,	GLPostInvoiceNumber,	GLPostNumCases,	GLPostNumLeads,	GLPostRevenue,	Quantity,	cast(Rate AS DECIMAL(18,8)) Rate,	IsMonthlyInvoice 
	into #Tempfinal from 
 (select  Clno,	clientname,	BillingCycle,	InvoiceDate,	APNO,	ApplicantName,	ReportCompletionDate,	InvoiceNumber,	Description,	AMT,	PrecheckPrice,	AdjustedPriceperPackage	,Passthru,	NumCase,	Leads,	Leadtypeid,	LeadtypeDescription,
	Price,	GLPostItemID,	GLPostItemName,	GLPostUniqueID,	GLPostInvoiceNumber,	GLPostNumCases,	GLPostNumLeads,	GLPostRevenue,	Quantity,	cast(Rate AS DECIMAL(18,8)) Rate,	IsMonthlyInvoice,type
 from #temp2
 union all
 select distinct t.clno,clientname,	BillingCycle,	InvoiceDate,	null,	null,	null,	t.InvoiceNumber,	null,	null,	null,	null	,null,	null,	null,	20 Leadtypeid, 'INVADJ'	LeadtypeDescription,
	null,	20 GLPostItemID, 'INVADJ'	GLPostItemName,
	isnull(cast(a.InvoiceNumber as varchar(8) )+ cast(20 as varchar(2)),'')	GLPostUniqueID
	,a.InvoiceNumber	GLPostInvoiceNumber, 1	GLPostNumCases, 1	GLPostNumLeads,diffAmt GLPostRevenue,1 	Quantity, cast(diffAmt AS DECIMAL(18,8)) 	Rate,	 'TRUE' IsMonthlyInvoice,1 type
 from #tempdiffAMT a inner join #temp2 t  on a.InvoiceNumber = t.InvoiceNumber) b

 --select * from #Tempfinal where Leadtypeid = 20
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
 declare @row_num int
 set @row_num = 0; 
-- SELECT id,name,rating, @row_num := @row_num + 1 as row_index FROM users
--ORDER BY rating desc;
		--select 'Detail' FileType ,Clno,clientname,		BillingCycle, InvoiceDate,	APNO, ApplicantName, ReportCompletionDate,	InvoiceNumber, Description, AMT ,    	--,PrecheckPrice,	AdjustedPriceperPackage,	 Passthru	,	NumCase, Leads , Price ,
		----											'' Leadtypeid, '' LeadtypeDescription,	 	''GLPostItemID,''	GLPostItemName,	'' GLPostUniqueID, '' GLPostInvoiceNumber,''  GLPostNumCases, '' GLPostNumLeads, 0 GLPostRevenue,  0  Quantity, 0 Rate, 
		--IsMonthlyInvoice 
		--										from #Tempfinal where apno is not null
	--	select  'Detail' FileType,Clno,clientname,		BillingCycle, InvoiceDate,	APNO, ApplicantName, ReportCompletionDate,	InvoiceNumber, Description, AMT ,   
	--	IsMonthlyInvoice into #TempfinalDetails
	--	from (
	--		select  'Detail' FileType ,Clno,clientname,		BillingCycle, InvoiceDate,	tf.APNO, ApplicantName, ReportCompletionDate,	tf.InvoiceNumber, Description, tf2.AMT ,    	--,PrecheckPrice,	AdjustedPriceperPackage,	 Passthru	,	NumCase, Leads , Price ,
	--												 --Leadtypeid,  LeadtypeDescription,	 	''GLPostItemID,''	GLPostItemName,	'' GLPostUniqueID, '' GLPostInvoiceNumber,''  GLPostNumCases, '' GLPostNumLeads, 0 GLPostRevenue,  0  Quantity, 0 Rate, 
	--	IsMonthlyInvoice ,Leadtypeid
	--											from #Tempfinal tf inner join #tempfinal20000 tf2 on tf.InvoiceNumber = tf2.InvoiceNumber and tf.apno = tf2.apno
	--											where tf.apno is not null and Leadtypeid = 0 
	--											union all 
	--		select  'Detail' FileType ,Clno,clientname,		BillingCycle, InvoiceDate,	APNO, ApplicantName, ReportCompletionDate,	InvoiceNumber, Description, AMT ,    	--,PrecheckPrice,	AdjustedPriceperPackage,	 Passthru	,	NumCase, Leads , Price ,
	--												-- Leadtypeid,  LeadtypeDescription,	 	''GLPostItemID,''	GLPostItemName,	'' GLPostUniqueID, '' GLPostInvoiceNumber,''  GLPostNumCases, '' GLPostNumLeads, 0 GLPostRevenue,  0  Quantity, 0 Rate, 
	--	IsMonthlyInvoice ,Leadtypeid
	--											from #Tempfinal where apno is not null and invoicenumber not in (select distinct  invoicenumber from #tempfinal20000)
	--											) k
	--											order by InvoiceNumber,APNO,Leadtypeid

	--											select  FileType,ROW_NUMBER() OVER(ORDER BY (SELECT 1))   as [Index] ,Clno,clientname,		BillingCycle, InvoiceDate,	APNO, 
	--ApplicantName, ReportCompletionDate, 	InvoiceNumber, Description, AMT ,		IsMonthlyInvoice 
	--from #TempfinalDetails order by [Index]

	--											select distinct 'GL' FileType , Clno,InvoiceDate ,-- CONVERT(CHAR(4), InvoiceDate, 100) + CONVERT(CHAR(4),InvoiceDate, 120) as PostingPeriod ,
	--											'Aug 2024' as PostingPeriod ,
	--											--InvoiceNumber, 					Leadtypeid,  LeadtypeDescription,	
	--												GLPostItemID,	GLPostItemName,	 GLPostUniqueID,  GLPostInvoiceNumber, GLPostNumCases, GLPostNumLeads,  GLPostRevenue,    Quantity,  Rate, IsMonthlyInvoice 
	--				from #Tempfinal where GLPostItemID <> 0 and GLPostRevenue <> 0
	--					order by GLPostInvoiceNumber,GLPostItemID

	select * from  #Tempfinal where apno = 5964087


	select  'Detail' FileType ,Clno,clientname,		BillingCycle, InvoiceDate,	APNO, 
	replace(ApplicantName,',',' ') ApplicantName, ReportCompletionDate, '3' + cast(InvoiceNumber as varchar(8))	InvoiceNumber, Description, AMT ,		IsMonthlyInvoice,Leadtypeid  into #TempfinalDetails
	from (
			select  'Detail' FileType ,Clno,clientname,		BillingCycle, InvoiceDate,	tf.APNO, ApplicantName, ReportCompletionDate,	tf.InvoiceNumber, Description, tf2.AMT ,    	--,PrecheckPrice,	AdjustedPriceperPackage,	 Passthru	,	NumCase, Leads , Price ,
													 --Leadtypeid,  LeadtypeDescription,	 	''GLPostItemID,''	GLPostItemName,	'' GLPostUniqueID, '' GLPostInvoiceNumber,''  GLPostNumCases, '' GLPostNumLeads, 0 GLPostRevenue,  0  Quantity, 0 Rate, 
		IsMonthlyInvoice ,Leadtypeid,type
												from #Tempfinal tf inner join #tempfinal20000 tf2 on tf.InvoiceNumber = tf2.InvoiceNumber and tf.apno = tf2.apno
												where tf.apno is not null and Leadtypeid = 0 
												union all 
			select  'Detail' FileType ,Clno,clientname,		BillingCycle, InvoiceDate,	APNO, ApplicantName, ReportCompletionDate,	InvoiceNumber, Description, AMT ,    	--,PrecheckPrice,	AdjustedPriceperPackage,	 Passthru	,	NumCase, Leads , Price ,
													-- Leadtypeid,  LeadtypeDescription,	 	''GLPostItemID,''	GLPostItemName,	'' GLPostUniqueID, '' GLPostInvoiceNumber,''  GLPostNumCases, '' GLPostNumLeads, 0 GLPostRevenue,  0  Quantity, 0 Rate, 
		IsMonthlyInvoice ,Leadtypeid,type
												from #Tempfinal where apno is not null and invoicenumber not in (select distinct  invoicenumber from #tempfinal20000)
												) k
												order by InvoiceNumber,APNO,Leadtypeid

													select * from  #TempfinalDetails where apno = 5964087
														select * into #tempDetailsFinal from  #TempfinalDetails where apno = 5964087 order by InvoiceNumber,APNO Asc ,Leadtypeid Asc
														select * from #tempDetailsFinal


	select  FileType,ROW_NUMBER() OVER(ORDER BY (SELECT 1))   as [Index] ,Clno,clientname,		BillingCycle, InvoiceDate,	APNO, 
	ApplicantName, ReportCompletionDate, 	InvoiceNumber, Description, AMT ,		IsMonthlyInvoice 
	from #TempfinalDetails  where apno = 5964087 

select  FileType,ROW_NUMBER() OVER(ORDER BY (SELECT 1))   as [Index] ,Clno,clientname,		BillingCycle, InvoiceDate,	APNO, 
	ApplicantName, ReportCompletionDate, 	InvoiceNumber, Description, AMT ,		IsMonthlyInvoice 
	from
	#tempDetailsFinal where apno = 5964087 

												select distinct 'GL' FileType , Clno,InvoiceDate ,-- CONVERT(CHAR(4), InvoiceDate, 100) + CONVERT(CHAR(4),InvoiceDate, 120) as PostingPeriod ,
												'Aug 2021' as PostingPeriod ,
												--InvoiceNumber, 					Leadtypeid,  LeadtypeDescription,	
													GLPostItemID,	GLPostItemName,	--GLPostUniqueID,GLPostInvoiceNumber,
													'3' + cast(GLPostUniqueID as varchar(8)) GLPostUniqueID, 
													'3' + cast(GLPostInvoiceNumber as varchar(8)) GLPostInvoiceNumber, GLPostNumCases, GLPostNumLeads,  GLPostRevenue,    Quantity,  Rate, IsMonthlyInvoice 
					from #Tempfinal where GLPostItemID <> 0 --and GLPostRevenue > 0
					and Quantity >0
						order by GLPostInvoiceNumber


  drop table #temp2 
    drop table #temp1 
	 --drop table #temp3
	 	  drop table #tempdiffAMT 
    drop table #Tempfinal
	drop table #tempInv20000
	 	  drop table #Tempfinal20000
		   drop table #tempgl
  drop table #tempGLUpdate
  drop table #TempfinalDetails
END




-- =============================================
-- Author:		Kiran Miryala
-- Create date: 04/28/2021
-- Description:	Monthly incoice Output for Netsuite thru Celigo
--schapyala on 09/01/2022 to return DeptCode and SectionKeyID (defaulted to 0) based on Scott and Zach direction to fix MHHS billing reconciliation issue
-- Modified by Lalit on 29 March to move monthly service fee dummy apps to bad apps
-- =============================================

CREATE PROCEDURE  [dbo].[Netsuite_MonthlyInvoices_kirantest]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @Invdate datetime
	--declare @month int
	--declare @year int

	declare @date datetime = getdate()
	--set @date = '08/1/2022'
declare @month int = month(@date)
declare @year int = year(@date)


--declare @startdate datetime 
set @date = cast(cast(@month as varchar(2))+ '/01/' + cast(@Year as varchar(4)) as datetime)
set @Invdate =  dateadd(dd,-1,@date)


--declare @enddate datetime = dateadd(s,-1,@date)
set @month = month(@Invdate)
set @year  = year(@Invdate)
--select @date,@Invdate,@month,@year

--select distinct invoicenumber into #tempGLInvoices from (
--select distinct invoicenumber from [dbo].[invdeatilsFeb2022]
--union
----select *  from [dbo].[invmasterfeb2022]

--select distinct invoicenumber from [dbo].[InvDetailToNetsuite_Stage] where description = 'Employment:The Work Number' and Amount = -39.14
--)t

--select * from #tempGLInvoices
	----select @Invdate = Max(invdate) from InvMaster
	--set @Invdate = '2021-09-30 00:00:00.000'
	--set @month = MONTH(@Invdate)
	--set @year = year(@Invdate)
	-- Insert statements for procedure here
	--select * from  InvDetailToNetsuite_Stage

	-- This block of code is used to group and calculate GL data at the invoicenumber and leadtypeid
	
select InvoiceNumber,leadtypeid,Sum(GLPostNumCases) as GLPostNumCases, Sum(GLPostNumLeads) GLPostNumLeads,
cast(sum(GLPostRevenue)  AS DECIMAL(18,8) )  GLPostRevenue  into #tempGL
		from
(select InvoiceNumber,leadtypeid,Sum(Numcase) as GLPostNumCases, Sum(NumLead) GLPostNumLeads,sum(case when [AdjustedPriceperPackage] <> 0 then [AdjustedPriceperPackage] else
	    case when Passthru <>0 then Passthru else 0.00 end end) GLPostRevenue 
from InvDetailToNetsuite_Stage where leadtypeid is not null  and  InvoiceMonth = @month and InvoiceYear = @year  group by InvoiceNumber,leadtypeid
union all
select InvoiceNumber,2 leadtypeid,0 GLPostNumCases,0 GLPostNumLeads,Sum([AdjustedPriceperPackage]) GLPostRevenue  from  InvDetailToNetsuite_Stage where  type = 0 and leadtypeid is null
 and  InvoiceMonth = @month and InvoiceYear = @year
 group by InvoiceNumber,leadtypeid) t3
 where GLPostRevenue <> 0

--and InvoiceNumber  in (9383585)
group by InvoiceNumber,leadtypeid

--select count(distinct InvoiceNumber) from #tempGL
	--select * from #tempgl --where leadtypeid = 2 and GLPostNumLeads = 0

--Select InvoiceNumber, min(leadtypeid) leadtypeid  into #tempGLUpdate from #tempgl where leadtypeid <> 2 and InvoiceNumber in (select InvoiceNumber from #tempgl where leadtypeid = 2 and GLPostNumLeads = 0)
--group by InvoiceNumber

----select * from #tempgl gl inner join #tempGLUpdate u on gl.InvoiceNumber = u.InvoiceNumber
----where gl.leadtypeid = 2 and gl.GLPostNumLeads = 0

--update gl set gl.leadtypeid = u.leadtypeid
--from #tempgl gl inner join #tempGLUpdate u on gl.InvoiceNumber = u.InvoiceNumber
--where gl.leadtypeid = 2 and gl.GLPostNumLeads = 0

--select * from #tempgl



--select  distinct Invoicenumber into #tempinv from 
--(select  distinct Invoicenumber from invdetail where invoicenumber in (9368174,9367449,9367373 ,9367301,9367317,9367309,9367312,9367275,9367297,9367293,9367294) 
--union all
--select distinct invoicenumber from InvRegistrar where CutOffDate = (  select  Max(CutOffDate) from InvRegistrarTotal) and billingcycle = 'U')ii


	--select distinct BillingCycle from InvRegistrarTotal where CutOffDate = (  select  Max(CutOffDate) from InvRegistrarTotal) and BillingCycle not in ('Z','zc','N','S')
		select distinct BillingCycle into #temp1 from InvRegistrarTotal where CutOffDate = (  select  Max(CutOffDate) from InvRegistrarTotal) and BillingCycle not in ('Z','N','Z','ZC','S' )
		--select * from  InvRegistrarTotal where CutOffDate = (  select  Max(CutOffDate) from InvRegistrarTotal) and BillingCycle not in ('Z','N','Z','ZC','S' )
		
		--select Count(distinct c.InvoiceNumber) from [dbo].[InvDetailToNetsuite_Stage] c inner join InvRegistrar r on c.InvoiceNumber = r.InvoiceNumber where BillingCycle in ('A') -- (select BillingCycle from #temp1)
		--and  InvoiceMonth = @month and InvoiceYear = @year
		--	select distinct c.InvoiceNumber,BillingCycle,count(c.InvoiceNumber) from [dbo].[InvDetailToNetsuite_Stage] c inner join InvRegistrar r on c.InvoiceNumber = r.InvoiceNumber where BillingCycle in  (select BillingCycle from #temp1)
		--and  InvoiceMonth = @month and InvoiceYear = @year
		--group by c.InvoiceNumber,BillingCycle
		--order by count(c.InvoiceNumber) 
    --select * from #temp1

	select  R.Clno,
	replace(clientname,',', '-')	clientname,
		BillingCycle,
 EOMONTH(cast(c.InvoiceMonth as varchar(2)) +'/1/'+ cast(InvoiceYear as varchar(4)) )as InvoiceDate,
	c.APNO,
replace(isnull(Last,'') + '  '+ First + ' ' + replace(replace(replace(isnull(DeptCode,''),char(10),''),char(13),''),',','-') ,',',' ') as ApplicantName,
convert(varchar(10),isnull(Compdate,c.createdate), 120)  as ReportCompletionDate,
	c.InvoiceNumber
	--cast(c.InvoiceNumber as varchar(10))+ 'A' as InvoiceNumber
	--,	c.InvoiceMonth,	c.InvoiceYear
,substring(replace(replace(replace(replace(c.Description,',','-'),'"',''),CHAR(10),''),char(13),''),1,60) Description
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
, case when isnull(GLPostNumLeads,0) = 0 and isnull(GLPostRevenue,0) <> 0 then 1 else isnull(GLPostNumLeads,0) end    Quantity
, cast((case when isnull(GLPostNumLeads,0) > 0  and isnull(GLPostRevenue,0) <> 0 then isnull(GLPostRevenue,0)/isnull(GLPostNumLeads,0) else isnull(GLPostRevenue,0) end)  AS DECIMAL(18,8) )  Rate
, 'TRUE' IsMonthlyInvoice
,c.type
--schapyala on 09/01/2022 to return DeptCode and SectionKeyID
,isnull(a.DeptCode,'') DeptCode,0 SectionKeyID,c.CNTY_NO
into #temp2
from [dbo].[InvDetailToNetsuite_Stage] c 
inner join (SELECT DISTINCT InvoiceNumber,BillingCycle,CLNO,clientname FROM  InvRegistrar WHERE MONTH(CutoffDate) = @month and year(CutoffDate) = @year) r  on c.InvoiceNumber = r.InvoiceNumber

left join (select InvoiceNumber,leadtypeid,Sum(GLPostNumCases) as GLPostNumCases, Sum(GLPostNumLeads) GLPostNumLeads,
cast(sum(GLPostRevenue)  AS DECIMAL(18,8) )  GLPostRevenue  
		from #tempgl group by InvoiceNumber,leadtypeid) t2 on c.invoicenumber = t2.InvoiceNumber and c.Leadtypeid = t2.Leadtypeid
		--inner join
		--(select  invoicenumber from #tempGLInvoices )t5 on c.invoicenumber = t5.invoicenumber


inner join appl a on c.apno = a.apno
where  BillingCycle in  (select BillingCycle from #temp1)

  and InvoiceMonth = @month and InvoiceYear = @year
 --and C.invoicenumber in (9389426,9389427,9389425,9387629)
  --and c.invoicenumber in (select distinct Invoicenumber from [dbo].[MissingNames] )
   --and c.apno  = 5299130
   --and c.invoicenumber not in (select distinct GLPostInvoiceNumber from [dbo].[BillingGLInvoiceList_Nov] --where GLPostInvoiceNumber <> 9332806 
   --)
--and c.InvoiceNumber  in 
--(9358600)

--  (9340112,
--9341048,
--9339806,
--9339804,
--9339988,
--9341120,
--9340522,
--9341020,
--9339122,
--9339838,
--9340837,
--9339836)

--AND A.CLNO NOT IN (3468)
--and r.clno in (2167,15591,10865,14858,15349,3035,15389,10045,1616,12643,14368,13248)  
--and r.clno not in (2167,12693 ,1616,13366,16014,16231,14877)

  --and BillingCycle = 'A'
 --and 
  
  order by A.apno 

  --select distinct invoicenumber from #temp2
	--select * from #temp2 where invoicenumber = 9389879 order by apno,type
	--select * from #temp2 where invoicenumber = 9389879 and adjustedpriceperpackage > 0
	--select * from #temp2 where invoicenumber = 9389879 and  type = 7
	--update  #temp2  set GLPostRevenue = 360.00,Quantity = 60  where invoicenumber = 9389879 and  type = 7
	--select sum(adjustedpriceperpackage),sum(isnull(passthru,0)) from #temp2 where invoicenumber = 9389879

	--select InvoiceNumber, Sum(amt) amt, 0 GLamt from #temp2 group by InvoiceNumber
					
					--select GLPostInvoiceNumber InvoiceNumber,0 amt, cast(sum(GLamt)  AS DECIMAL(10,2) ) GLamt 
					--from 	(select Distinct GLPostInvoiceNumber,GLPostItemID,GLPostNumLeads,Quantity,Rate,cast((Quantity *  Rate)as decimal(10,2)) GLamt 
					--  from #temp2 where  GLPostRevenue <> 0 )a  group by GLPostInvoiceNumber,GLPostNumLeads
					
--	select case when i.description like 'Criminal Search:%' then SUBSTRING(i.description,17,len(i.description)- 21) else i.description end as CNTY_Desc ,
--county,* 
--from #temp2 i
--inner join crim c on i.apno = c.apno 
--and ltrim(rtrim(case when i.description like 'Criminal Search:%' then SUBSTRING(i.description,17,len(i.description)- 21) else i.description end)) = ltrim(rtrim(c.County))
--where type = 2 and invoicenumber = 9373957

  select InvoiceNumber, amt, GLamt,  diffAmt into #tempdiffAMT 
  from
					(select InvoiceNumber, Sum(amt) amt,Sum(GLamt) GLamt, cast(sum(amt)  AS DECIMAL(10,2) ) - cast(sum(GLamt)  AS DECIMAL(10,2) ) diffAmt
					 from (

					select InvoiceNumber, Sum(amt) amt, 0 GLamt from #temp2 group by InvoiceNumber
					union all
					select GLPostInvoiceNumber InvoiceNumber,0 amt, cast(sum(GLamt)  AS DECIMAL(10,2) ) GLamt 
					from 	(select Distinct GLPostInvoiceNumber,GLPostItemID,GLPostNumLeads,Quantity,Rate,cast((Quantity *  Rate)as decimal(10,2)) GLamt   from #temp2 where  GLPostRevenue <> 0 
					) a  group by GLPostInvoiceNumber,GLPostNumLeads) z 
					
					Group by InvoiceNumber) d
where diffAmt <> 0 order by diffAmt desc

-- select * from #temp2
--select Distinct GLPostInvoiceNumber,GLPostItemID,GLPostNumLeads,Quantity,Rate,cast((Quantity *  Rate)as decimal(10,2)) GLamt   from #temp2 where  GLPostRevenue > 0 
					
					
				select * from #tempdiffAMT order by diffAmt desc

--select Clno,	clientname,	BillingCycle,	InvoiceDate,	APNO,	ApplicantName,	ReportCompletionDate,	InvoiceNumber,	Description,	AMT,	PrecheckPrice,	AdjustedPriceperPackage	,Passthru,	NumCase,	Leads,	Leadtypeid,	LeadtypeDescription,
--	Price,	GLPostItemID,	GLPostItemName,	GLPostUniqueID,	GLPostInvoiceNumber,	GLPostNumCases,	GLPostNumLeads,	GLPostRevenue,	Quantity,	cast(Rate AS DECIMAL(18,8)) Rate,	IsMonthlyInvoice ,type
--	,DeptCode,SectionKeyID --schapyala on 09/01/2022 to return DeptCode and SectionKeyID
--	,CNTY_NO
--	into #Tempfinal from 
-- (select  Clno,	clientname,	BillingCycle,	InvoiceDate,	APNO,	ApplicantName,	ReportCompletionDate,	InvoiceNumber,	Description,	AMT,	PrecheckPrice,	AdjustedPriceperPackage	,Passthru,	NumCase,	Leads,	Leadtypeid,	LeadtypeDescription,
--	Price,	GLPostItemID,	GLPostItemName,	GLPostUniqueID,	GLPostInvoiceNumber,	GLPostNumCases,	GLPostNumLeads,	GLPostRevenue,	Quantity,	cast(Rate AS DECIMAL(18,8)) Rate,	IsMonthlyInvoice,type
--	--schapyala on 09/01/2022 to return DeptCode and SectionKeyID
--	,DeptCode,SectionKeyID,CNTY_NO
-- from #temp2
-- union all
-- select distinct t.clno,clientname,	BillingCycle,	InvoiceDate,	null,	null,	null,	t.InvoiceNumber,	null,	null,	null,	null	,null,	null,	null,	20 Leadtypeid, 'INVADJ'	LeadtypeDescription,
--	null,	20 GLPostItemID, 'INVADJ'	GLPostItemName,
--	isnull(cast(a.InvoiceNumber as varchar(8) )+ cast(20 as varchar(2)),'')	GLPostUniqueID
--	,a.InvoiceNumber	GLPostInvoiceNumber, 1	GLPostNumCases, 1	GLPostNumLeads,diffAmt GLPostRevenue,1 	Quantity, cast(diffAmt AS DECIMAL(18,8)) 	Rate,	 'TRUE' IsMonthlyInvoice,1 type
--	--schapyala on 09/01/2022 to return DeptCode and SectionKeyID
--	,DeptCode,SectionKeyID,CNTY_NO
-- from #tempdiffAMT a inner join #temp2 t  on a.InvoiceNumber = t.InvoiceNumber) b



--		select  InvoiceNumber, Count(InvoiceNumber) invcount into #tempInv20000  from #Tempfinal   group by InvoiceNumber

--select InvoiceNumber,apno, sum(AMT) amt into #tempfinal20000  from #Tempfinal 
--where   InvoiceNumber in (select InvoiceNumber from #tempInv20000 where invcount > 19999)
-- group by InvoiceNumber,apno
-- declare @row_num int
-- set @row_num = 0; 

-- --select * from #tempfinal20000
-- --select * from #tempfinal



--	select  'Detail' FileType ,Clno,clientname,		BillingCycle, InvoiceDate,	APNO, 
--	replace(ApplicantName,',',' ') ApplicantName, ReportCompletionDate,-- '6' + cast(InvoiceNumber as varchar(8))
--		InvoiceNumber, Description, AMT ,		IsMonthlyInvoice,Leadtypeid,type,
--		replace(replace(replace(DeptCode,char(10),''),char(13),''),',','-') DeptCode
--		,SectionKeyID  into #TempfinalDetails
--	from (
--			select  'Detail' FileType ,Clno,clientname,		BillingCycle, InvoiceDate,	tf.APNO, ApplicantName, ReportCompletionDate,	tf.InvoiceNumber, Description, tf2.AMT ,    	--,PrecheckPrice,	AdjustedPriceperPackage,	 Passthru	,	NumCase, Leads , Price ,
--													 --Leadtypeid,  LeadtypeDescription,	 	''GLPostItemID,''	GLPostItemName,	'' GLPostUniqueID, '' GLPostInvoiceNumber,''  GLPostNumCases, '' GLPostNumLeads, 0 GLPostRevenue,  0  Quantity, 0 Rate, 
--		IsMonthlyInvoice ,Leadtypeid,type,DeptCode,SectionKeyID
--												from #Tempfinal tf inner join #tempfinal20000 tf2 on tf.InvoiceNumber = tf2.InvoiceNumber and tf.apno = tf2.apno
--												where tf.apno is not null and Leadtypeid = 0 
--												union all 
--												select  'Detail' FileType ,Clno,clientname,		BillingCycle, InvoiceDate,	tf.APNO, ApplicantName, ReportCompletionDate,	tf.InvoiceNumber, Description,tf.AMT ,    	--,PrecheckPrice,	AdjustedPriceperPackage,	 Passthru	,	NumCase, Leads , Price ,
--													 --Leadtypeid,  LeadtypeDescription,	 	''GLPostItemID,''	GLPostItemName,	'' GLPostUniqueID, '' GLPostInvoiceNumber,''  GLPostNumCases, '' GLPostNumLeads, 0 GLPostRevenue,  0  Quantity, 0 Rate, 
--		IsMonthlyInvoice ,Leadtypeid,type,DeptCode,SectionKeyID
--												from #Tempfinal tf inner join #tempfinal20000 tf2 on tf.InvoiceNumber = tf2.InvoiceNumber and tf.apno = tf2.apno
--												where tf.apno is not null --and Leadtypeid = 0 
--												and tf.APNO not in (select Apno from #Tempfinal where Leadtypeid = 0 )
--												union all 

--			select  'Detail' FileType ,Clno,clientname,		BillingCycle, InvoiceDate,	APNO, ApplicantName, ReportCompletionDate, 	InvoiceNumber, Description, AMT ,    	--,PrecheckPrice,	AdjustedPriceperPackage,	 Passthru	,	NumCase, Leads , Price ,
--													-- Leadtypeid,  LeadtypeDescription,	 	''GLPostItemID,''	GLPostItemName,	'' GLPostUniqueID, '' GLPostInvoiceNumber,''  GLPostNumCases, '' GLPostNumLeads, 0 GLPostRevenue,  0  Quantity, 0 Rate, 
--		IsMonthlyInvoice ,Leadtypeid,type,DeptCode,SectionKeyID
--												from #Tempfinal where apno is not null and invoicenumber not in (select distinct  invoicenumber from #tempfinal20000)
--												) k
--												order by InvoiceNumber,APNO,Leadtypeid

--		--			select  'Detail' FileType ,Clno,clientname,		BillingCycle, InvoiceDate,	tf.APNO, ApplicantName, ReportCompletionDate,	tf.InvoiceNumber, Description, tf2.AMT ,    	--,PrecheckPrice,	AdjustedPriceperPackage,	 Passthru	,	NumCase, Leads , Price ,
--		--											 --Leadtypeid,  LeadtypeDescription,	 	''GLPostItemID,''	GLPostItemName,	'' GLPostUniqueID, '' GLPostInvoiceNumber,''  GLPostNumCases, '' GLPostNumLeads, 0 GLPostRevenue,  0  Quantity, 0 Rate, 
--		--IsMonthlyInvoice ,Leadtypeid,type,DeptCode,SectionKeyID
--		--										from #Tempfinal tf inner join #tempfinal20000 tf2 on tf.InvoiceNumber = tf2.InvoiceNumber and tf.apno = tf2.apno
--		--										where tf.apno is not null and Leadtypeid = 0 							


--	select  FileType,ROW_NUMBER() OVER(ORDER BY (SELECT 1))   as [Index] ,Clno,clientname,		BillingCycle, InvoiceDate,	APNO, 
--	ApplicantName, ReportCompletionDate, 	InvoiceNumber, Description, AMT ,		IsMonthlyInvoice 
--	,DeptCode,SectionKeyID --schapyala on 09/01/2022 to return DeptCode and SectionKeyID
--	from #TempfinalDetails -- where apno = 5964087  
--	order by InvoiceNumber,APNO,type 


--	-- select * from #tempfinal where Apno not in (select apno from #TempfinalDetails )



--												select distinct 'GL' FileType , Clno,InvoiceDate , CONVERT(CHAR(4), InvoiceDate, 100) + CONVERT(CHAR(4),InvoiceDate, 120) as PostingPeriod ,
--												--'Sep 2021' as PostingPeriod ,
--												--InvoiceNumber, 					Leadtypeid,  LeadtypeDescription,	
--													GLPostItemID,	GLPostItemName,	GLPostUniqueID,GLPostInvoiceNumber,
--													--'6' + cast(GLPostUniqueID as varchar(8)) GLPostUniqueID, 
--													--'6' + cast(GLPostInvoiceNumber as varchar(8)) GLPostInvoiceNumber, 
--													GLPostNumCases, GLPostNumLeads,  GLPostRevenue,    Quantity,  Rate, IsMonthlyInvoice 
--					from #Tempfinal where GLPostItemID <> 0 --and GLPostRevenue > 0
--					and Quantity >0
--						order by GLPostInvoiceNumber

--					--	select distinct 'GLDetails' FileType , Clno,InvoiceDate , CONVERT(CHAR(4), InvoiceDate, 100) + CONVERT(CHAR(4),InvoiceDate, 120) as PostingPeriod ,
--					--							--'Sep 2021' as PostingPeriod ,
--					--							--InvoiceNumber, 					Leadtypeid,  LeadtypeDescription,	
--					--								GLPostItemID,	GLPostItemName,	GLPostUniqueID,GLPostInvoiceNumber,
--					--								--'6' + cast(GLPostUniqueID as varchar(8)) GLPostUniqueID, 
--					--								--'6' + cast(GLPostInvoiceNumber as varchar(8)) GLPostInvoiceNumber, 
--					--								GLPostNumCases, GLPostNumLeads,  GLPostRevenue,    Quantity,  Rate, IsMonthlyInvoice ,t.CNTY_NO,CountyOrdered
--					--from #Tempfinal t
--					--left join (select Invoicenumber,CNTY_NO,count(CNTY_NO) CountyOrdered
--					--	from #temp2 group by Invoicenumber,CNTY_NO) t2
--					--	on t.Invoicenumber = t2.InvoiceNumber and t.CNTY_NO = t2.CNTY_NO
					
--					--where GLPostItemID <> 0 --and GLPostRevenue > 0
--					--and Quantity >0
--					--	--order by GLPostInvoiceNumber
--					--	--select Invoicenumber,CNTY_NO,count(CNTY_NO) CountyOrdered
--					--	--from #temp2 group by Invoicenumber,CNTY_NO

--  drop table #temp2 
--    drop table #temp1 
--	 --drop table #temp3
--	 	  drop table #tempdiffAMT 
--    drop table #Tempfinal
--	drop table #tempInv20000
--	 	  drop table #Tempfinal20000
--		   drop table #tempgl
--  --drop table #tempGLUpdate
--  --drop table #TempfinalDetails
--    EXEC [dbo].[Billing_DummyAppsMoveToBadApps]

END



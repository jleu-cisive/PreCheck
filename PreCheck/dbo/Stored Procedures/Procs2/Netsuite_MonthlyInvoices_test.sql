
-- =============================================
-- Author:		Kiran Miryala
-- Create date: 04/28/2021
-- Description:	Monthly incoice Output for Netsuite thru Celigo
-- =============================================

CREATE PROCEDURE  [dbo].[Netsuite_MonthlyInvoices_test]
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
	set @Invdate = '2020-03-31 00:00:00.000'
	set @month = MONTH(@Invdate)
	set @year = year(@Invdate)
	-- Insert statements for procedure here

	--select distinct BillingCycle from InvRegistrarTotal where CutOffDate = (  select  Max(CutOffDate) from InvRegistrarTotal) and BillingCycle not in ('Z','zc','N','S')
		select distinct BillingCycle into #temp1 from InvRegistrarTotal where CutOffDate = (  select  Max(CutOffDate) from InvRegistrarTotal) and BillingCycle not in ('Z','N','Z','ZC' )
		--select * from #temp1
		--select Count(distinct c.InvoiceNumber) from [dbo].[InvDetailForCisive2020] c inner join InvRegistrar r on c.InvoiceNumber = r.InvoiceNumber where BillingCycle in ('A') -- (select BillingCycle from #temp1)
		--and  InvoiceMonth = @month and InvoiceYear = @year
		--	select Count(distinct c.InvoiceNumber) from [dbo].[InvDetailForCisive2020] c inner join InvRegistrar r on c.InvoiceNumber = r.InvoiceNumber where BillingCycle in  (select BillingCycle from #temp1)
		--and  InvoiceMonth = @month and InvoiceYear = @year
    
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
, case when isnull(GLPostNumLeads,0) > 0  and isnull(GLPostRevenue,0) > 0 then isnull(GLPostRevenue,0)/isnull(GLPostNumLeads,0) else isnull(GLPostRevenue,0)  end Rate
, 'TRUE' IsMonthlyInvoice

into #temp2
from [dbo].[InvDetailForCisive2020] c inner join InvRegistrar r on c.InvoiceNumber = r.InvoiceNumber
left join (select InvoiceNumber,leadtypeid,Sum(GLPostNumLeads) as GLPostNumCases, Sum(GLPostNumLeads) GLPostNumLeads,
sum(GLPostRevenue) GLPostRevenue 
		from
(select InvoiceNumber,leadtypeid,Sum(Numcase) as GLPostNumCases, Sum(NumLead) GLPostNumLeads,sum(case when [AdjustedPriceperPackage] <> 0 then [AdjustedPriceperPackage] else
	    case when Passthru <>0 then Passthru else 0.00 end end) GLPostRevenue 
from InvDetailForCisive2020   group by InvoiceNumber,leadtypeid
union all
select InvoiceNumber,2 leadtypeid,0 GLPostNumCases,0 GLPostNumLeads,Sum([AdjustedPriceperPackage]) GLPostRevenue  from  InvDetailForCisive2020 where  type = 0 group by InvoiceNumber,leadtypeid) t3
group by InvoiceNumber,leadtypeid)t2 on c.invoicenumber = t2.InvoiceNumber and c.Leadtypeid = t2.Leadtypeid

--(select InvoiceNumber,leadtypeid,Sum(Numcase) as GLPostNumCases, Sum(NumLead) GLPostNumLeads,sum(case when [AdjustedPriceperPackage] <> 0 then [AdjustedPriceperPackage] else
--	    case when Passthru <>0 then Passthru else 0.00 end end) GLPostRevenue 
--from InvDetailForCisive2020 
----where InvoiceNumber = 9282692
--group by InvoiceNumber,leadtypeid) 
--t2 on c.invoicenumber = t2.InvoiceNumber and c.Leadtypeid = t2.Leadtypeid

inner join appl a on c.apno = a.apno
where  
  InvoiceMonth = @month and InvoiceYear = @year
   --and c.apno  = 5299130
  and c.InvoiceNumber in ( 9282692)
  --and BillingCycle = 'A'
  and BillingCycle in  (select BillingCycle from #temp1)
  order by A.apno 

  --select --BillingCycle as FileType,
  --InvoiceNumber,count(InvoiceNumber)
  -- from #temp2
  -- group by InvoiceNumber
  -- order by InvoiceNumber
  --select Top 1000 1 FileType, * from #temp2 order by apno ,Leadtypeid

   select  distinct  InvoiceNumber into #temp3
   from #temp2
   order by InvoiceNumber
   declare @index int = 1
   declare @fileID int = 1

   select @fileID FileType,Clno,clientname,		BillingCycle, InvoiceDate,
	APNO, ApplicantName, ReportCompletionDate,	InvoiceNumber, Description
, AMT     	,PrecheckPrice,	AdjustedPriceperPackage,	 Passthru	,	NumCase, Leads ,  Price ,
Leadtypeid, LeadtypeDescription,			GLPostItemID,	GLPostItemName,
	GLPostUniqueID,
			GLPostInvoiceNumber, GLPostNumCases, GLPostNumLeads, GLPostRevenue,   Quantity, Rate, IsMonthlyInvoice 
from

	(		 select Clno,clientname,		BillingCycle, InvoiceDate,
	APNO, ApplicantName, ReportCompletionDate,	cast(InvoiceNumber as varchar(10)) + '-'+ cast(ROW_NUMBER() OVER(ORDER BY InvoiceNumber,Apno ) as varchar(6))  InvoiceNumber , Description
, AMT     	,PrecheckPrice,
	AdjustedPriceperPackage,	 Passthru	,	NumCase, Leads , Price ,
'' Leadtypeid, '' LeadtypeDescription,	 	
	''GLPostItemID,''	GLPostItemName,
	'' GLPostUniqueID, '' GLPostInvoiceNumber,''  GLPostNumCases, '' GLPostNumLeads, 0 GLPostRevenue,  0  Quantity, 0 Rate, IsMonthlyInvoice from #temp2 where InvoiceNumber in (select InvoiceNumber from #temp2) 
union all
	select distinct ''  Clno,'' clientname,	'' 	BillingCycle, '' InvoiceDate,
	'' APNO, '' ApplicantName,''  ReportCompletionDate,	cast(InvoiceNumber as varchar(15)) InvoiceNumber, '' Description
,0  AMT     	,0 PrecheckPrice,	0 AdjustedPriceperPackage,	0  Passthru	,0 	NumCase, '' Leads , 0 Price,
 Leadtypeid,  LeadtypeDescription,		GLPostItemID,	GLPostItemName,
	 GLPostUniqueID,  GLPostInvoiceNumber, GLPostNumCases, GLPostNumLeads,  GLPostRevenue,    Quantity,  Rate, IsMonthlyInvoice from #temp2 where InvoiceNumber in (select InvoiceNumber from #temp2) and Leadtypeid <> 0 ) t order by clno,Apno,Leadtypeid

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
		--									select @fileID FileType,* from #temp2 where InvoiceNumber in (select InvoiceNumber from #temp7) order by clno,Apno,Leadtypeid
		--									delete #temp3 where InvoiceNumber in (select InvoiceNumber from #temp7)
		--								end
		--							else
		--								begin
		--									select @fileID FileType,* from #temp2 where InvoiceNumber in (select InvoiceNumber from #temp6) order by clno,Apno,Leadtypeid
		--										delete #temp3 where InvoiceNumber in (select InvoiceNumber from #temp6)
							
		--								end
								
		--					end
		--				else
		--				begin
		--					Select @fileID FileType,* from #temp2 where InvoiceNumber in (select InvoiceNumber from #temp5)  order by clno,Apno,Leadtypeid
		--					delete #temp3 where InvoiceNumber in (select InvoiceNumber from #temp5)
		--			end
		--		end
		--	else
		--	begin
		--		select @fileID FileType,* from #temp2 where InvoiceNumber in (select InvoiceNumber from #temp4)  order by clno,Apno,Leadtypeid

		--		delete #temp3 where InvoiceNumber in (select InvoiceNumber from #temp4)
		--	end
		--set @fileID = @fileID+1
		--end

  drop table #temp2 
    drop table #temp1 
	 --drop table #temp3
	 	 

END



﻿/*
-- Author : Radhika Dereddy
-- Created on : 08/26/2021
-- Request: Mirroring Billing_ClientReportInvSummary_ByClientGroup to Add Bill To,Ship To Name / Address / City / State / Zip  field 
-- to the Invoice Detail and Summary for CHI
-- sp_helptext [Billing_ClientReportInvSummary_ByClient]
--Exec [Billing_ClientReportInvSummary_ByClient] 12444,null,null,10
--Exec [Billing_ClientReportInvSummary_ByClient] 13966,null,null,253
*/
CREATE PROCEDURE [dbo].[Billing_ClientReportInvSummary_ByClient] 
@CLNO int,
@ClientGroupCode int = null,
@invDate Date = null,
@AffiliateID Int = null

AS
BEGIN

SET ANSI_WARNINGS ON
SET ARITHABORT ON

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	IF (@invDate IS NULL)
		BEGIN
			IF (@AffiliateID is Not Null)
				Select @invDate = cast(max(invdate) as Date) from invmaster where clno in (select clno from Client t where (t.affiliateid = @AffiliateID));
			else IF (@ClientGroupCode is null)
				Select @invDate = cast(max(invdate) as Date) from invmaster where clno = @CLNO
			else
				Select @invDate = cast(max(invdate) as Date) from invmaster where clno in (select clno from ClientGroup where GroupCode = @ClientGroupCode);
		END

		
	CREATE TABLE #tmpInv 
	(
		apno INT,
		[Last Name] varchar(50),
		[First Name] varchar(50),
		[Middle Name] varchar(20),
		Department varchar(50),
		[Process Level] varchar(50),
		[GLAccount#] varchar(50),
		invoicenumber INT,
		InvDate DateTime,
		CompDate DateTime,
		Client Varchar(250),
		Amount smallmoney,
		TaxRate smallmoney,
		[Description] varchar(100),
		[AddOn Fee]  varchar(3),
		[AttentionTo] varchar(100),
		[Bill To] varchar(100),
		[Ship To] varchar(100),
		[Address] varchar(100),
		[City] varchar(50),
		[State] varchar(2),
		[Zip] varchar(10)
	)

	IF (@AffiliateID is Not Null)
		Insert into #tmpInv
		select i.apno ,
			last [Last Name],first [First Name], Isnull(Middle,'') as [Middle Name],
			Isnull(DeptCode,'')  [Process Level],
			IsNull(a.xmld.value('(/CustomClientData/ClientData1)[1]', 'varchar(50)'),'') as Department,
			IsNull(a.xmld.value('(/CustomClientData/ClientData2)[1]', 'varchar(30)'),'') as [GLAccount#],
			--a.xmld.value('(/CustomClientData/ClientData3)[1]', 'varchar(20)') as LocationCode,
			i.invoicenumber ,ii.InvDate,CompDate ,(cast(appl.CLNO as varchar)  + ' - ' +  C.Name) as Client,
			Amount,(case when C.IsTaxExempt = 1 then 0 else TR.TaxRate end) TaxRate,
			Replace(i.[Description],',','') Description,
			case when i.type = 1 then 'Yes' when i.description like '%service charge%' and i.type = 2 then 'Yes' else 'No' end As [AddOn Fee],
			REPLACE(appl.Attn, ',', ' '),
			C.Name [Bill To] ,
			''[Ship To],
			C.Addr1[Address],
			C.City[City],
			C.State[State],
			C.Zip[Zip]
		from dbo.invdetail i left join 
		     dbo.appl  on i.apno = appl.Apno left join
			 dbo.applclientdata a on appl.apno = a.apno inner join 
			 dbo.Client C on appl.CLNO = C.CLNO left join
			 dbo.reftaxrate TR on C.TaxRateID = TR.TaxRateID inner join
			 dbo.invmaster ii on i.invoicenumber = ii.invoicenumber 
		where 
			i.billed = 1  and cast(invDate as Date) = @invDate and 
			
			(C.affiliateid = @AffiliateID 
			OR  (C.affiliateid = CASE WHEN @AffiliateID=10 THEN 129 ELSE  @AffiliateID END)  -- schapyala added this logic to include conifer affiliate for Tenet Billing - 12/6/2016
			OR  (C.name like (case @AffiliateID WHEN 4 then  'HCA%' 
											   WHEN 10 then  ('%tenet%') else '1' end ))
			)		

	ELSE IF (@ClientGroupCode IS NULL)
		Insert into #tmpInv
		select i.apno ,
			last [Last Name],first [First Name], Isnull(Middle,'') as [Middle Name],
			Isnull(DeptCode,'')  [Process Level],
			IsNull(a.xmld.value('(/CustomClientData/ClientData1)[1]', 'varchar(50)'),'') as Department,
			IsNull(a.xmld.value('(/CustomClientData/ClientData2)[1]', 'varchar(30)'),'') as [GLAccount#],
			--a.xmld.value('(/CustomClientData/ClientData3)[1]', 'varchar(20)') as LocationCode,
			i.invoicenumber ,ii.InvDate,CompDate ,(cast(appl.CLNO as varchar) + ' - ' + C.Name) as Client,Amount,(case when C.IsTaxExempt = 1 then 0 else TR.TaxRate end) TaxRate,
			Replace(i.[Description],',',' ') Description,
			case when i.type = 1 then 'Yes' when i.description like '%service charge%' and i.type = 2 then 'Yes' else 'No' end As [AddOn Fee],
			REPLACE(appl.Attn, ',', ''),
			C.Name [Bill To] ,
			''[Ship To],
			C.Addr1[Address],
			C.City[City],
			C.State[State],
			C.Zip[Zip]
		from dbo.invdetail i left join 
	  		 dbo.appl  on i.apno = appl.Apno left join
			 dbo.applclientdata a on appl.apno = a.apno inner join 
			 dbo.Client C on appl.CLNO = C.CLNO left join
			 dbo.reftaxrate TR on C.TaxRateID = TR.TaxRateID inner join
			 dbo.invmaster ii on i.invoicenumber = ii.invoicenumber 
		where 
			i.billed = 1  and cast(invDate as Date) = @invDate and appl.CLNO = @CLNO
			
	ELSE

		Insert into #tmpInv
		select i.apno ,
			last [Last Name],first [First Name], Isnull(Middle,'') as [Middle Name],
			Isnull(DeptCode,'')  [Process Level],
			IsNull(a.xmld.value('(/CustomClientData/ClientData1)[1]', 'varchar(50)'),'') as Department,
			IsNull(a.xmld.value('(/CustomClientData/ClientData2)[1]', 'varchar(30)'),'') as [GLAccount#],
			--a.xmld.value('(/CustomClientData/ClientData3)[1]', 'varchar(20)') as LocationCode,
			i.invoicenumber ,ii.InvDate,CompDate ,(cast(appl.CLNO as varchar)  + ' - ' +  C.Name) as Client,Amount,(case when C.IsTaxExempt = 1 then 0 else TR.TaxRate end) TaxRate,
			Replace(i.[Description],',',' ') Description,
			case when i.type = 1 then 'Yes' when i.description like '%service charge%' and i.type = 2 then 'Yes' else 'No' end As [AddOn Fee],
			REPLACE(appl.Attn, ',', ''),
			C.Name [Bill To] ,
			''[Ship To],
			C.Addr1[Address],
			C.City[City],
			C.State[State],
			C.Zip[Zip]
		from dbo.invdetail i left join 
		     dbo.appl  on i.apno = appl.Apno left join
		     dbo.applclientdata a on appl.apno = a.apno inner join
			 dbo.ClientGroup CG on appl.clno = CG.clno and CG.GroupCode = @ClientGroupCode inner join 
			 dbo.Client C on appl.CLNO = C.CLNO left join
			 dbo.reftaxrate TR on C.TaxRateID = TR.TaxRateID inner join
			 dbo.invmaster ii on i.invoicenumber = ii.invoicenumber 
		where 
			i.billed = 1  and cast(invDate as Date) = @invDate
			
	--IF(@SPMODE = 1) -- Summary

	--BEGIN

		select  APNO,sum(amount) SubTotal,Round((sum(amount) * TaxRate/100),2) As Tax  into #tmpInv2
		from #tmpInv 
		group by APNO,TaxRate
		
		--select * from #tmpInv
	IF (isnull(@ClientGroupCode,0)  in (2,3)  ) --only include Department and GL Account for HCA Physician recruitment and ParallonWFS
			Select Distinct 'Summary' FileType, (case when isnull(@ClientGroupCode,0) = 2 and isnull(Department,'') = '' then right(Client,3) else Department end) Department,
				[Process Level],isnull([GLAccount#],'') [GLAccount#], [Last Name],[First Name],[Middle Name],invoicenumber [PreCheck Invoice Number],
				Format(InvDate, 'MM/dd/yyyy') [PreCheck Invoice Date], t1.APNO [PreCheck RequestID],
				CompDate [PreCheck Request Completion Date],Client [Precheck CLNO],SubTotal,Tax,
				(Subtotal + Tax) Total, AttentionTo,
				[Bill To],[Ship To],[Address],[City],[State],[Zip]
			from #tmpInv t1 inner join #tmpInv2 t2 on t1.APNO = t2.APNO
			order by Department,[Process Level],[GLAccount#],Client,[Last Name]

	ELSE
			Select Distinct 'Summary' FileType, Case When (len(Department)=5 and len([Process Level]) < 5) 
						then Department else (case when isnull([Process Level],'')='' then Department else [Process Level] end) end [Process Level],
			    [Last Name],[First Name],
				[Middle Name],invoicenumber [PreCheck Invoice Number],Format(InvDate, 'MM/dd/yyyy') [PreCheck Invoice Date],
				t1.APNO [PreCheck RequestID],CompDate [PreCheck Request Completion Date],
				Client [Precheck CLNO],SubTotal,Tax, (Subtotal + Tax) Total,
				AttentionTo,[Bill To],[Ship To],[Address],[City],[State],[Zip]
			from #tmpInv t1 inner join #tmpInv2 t2 on t1.APNO = t2.APNO
			order by [Process Level],Client,[Last Name]			

		DROP TABLE #tmpInv2
	--END

	--IF(@SPMODE = 2) -- Detail

	--BEGIN	

		select APNO,Round((sum(amount) * TaxRate/100),2) As Tax  into #tmpInvTax
		from #tmpInv 
		group by APNO,TaxRate

		Select 'Detail' FileType, Department,[Process Level],[GLAccount#],[Last Name],[First Name],[Middle Name],
		    invoicenumber [PreCheck Invoice Number],InvDate [PreCheck Invoice Date],
			APNO [PreCheck RequestID],CompDate [PreCheck Request Completion Date],
			Client [Precheck CLNO],Replace(Description,',',' ') Description,[AddOn Fee],
			AttentionTo,[Bill To],[Ship To],[Address],[City],[State],[Zip],Amount 
		into #tmpDetail From
			(
				Select Department,[Process Level],isnull([GLAccount#],'') [GLAccount#],
				[Last Name],[First Name],[Middle Name],invoicenumber,
				Format(InvDate, 'MM/dd/yyyy') as InvDate, APNO,CompDate,Client,[Description],[AddOn Fee],
				AttentionTo,[Bill To],[Ship To],[Address],[City],[State],[Zip],Amount
			From #tmpInv
			
			UNION ALL
			
			--TAX ITEMS
				select Distinct Department,[Process Level],isnull([GLAccount#],'') [GLAccount#], [Last Name],
				    [First Name],[Middle Name],invoicenumber,
					Format(InvDate, 'MM/dd/yyyy') as InvDate, t1.APNO,CompDate ,Client,'Tax Amount' [Description],
					'No' As AddOnFee, AttentionTo,[Bill To],[Ship To],[Address],
					[City],[State],[Zip],Tax Amount
				from #tmpInv t1 inner join #tmpInvTax t2 on t1.APNO = t2.APNO
			) QRY

	IF (isnull(@ClientGroupCode,0)  in (2,3) ) --only include Department and GL Account for HCA Physician recruitment and ParallonWFS

			Select FileType, (case when isnull(@ClientGroupCode,0) = 2 and isnull(Department,'') = '' then right([Precheck CLNO],3) else Department end) Department,
				[Process Level],[GLAccount#],[Last Name],[First Name],[Middle Name], [PreCheck Invoice Number],
				[PreCheck Invoice Date], [PreCheck RequestID],[PreCheck Request Completion Date],
				[Precheck CLNO],Replace(Description,',',' ') Description,[AddOn Fee],AttentionTo,
				[Bill To],[Ship To],[Address],[City],[State],[Zip],Amount From #tmpDetail 
			order by Department,[Process Level],[GLAccount#],[Precheck CLNO],[Last Name]
	ELSE

			Select FileType, Case When (len(Department)=5 and len([Process Level]) < 5) then Department else (case when isnull([Process Level],'')='' then Department else [Process Level] end) end [Process Level],
			     [Last Name],[First Name],[Middle Name],[PreCheck Invoice Number], [PreCheck Invoice Date],
				  [PreCheck RequestID], [PreCheck Request Completion Date],[Precheck CLNO],Replace(Description,',',' ') Description,
				  [AddOn Fee],AttentionTo,[Bill To],[Ship To],[Address],[City],[State],[Zip],Amount From #tmpDetail 
			order by [Process Level],[Precheck CLNO],[Last Name]

	
		DROP TABLE #tmpDetail
		DROP TABLE #tmpInvTax
	--END
		DROP TABLE #tmpInv

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET NOCOUNT OFF

END

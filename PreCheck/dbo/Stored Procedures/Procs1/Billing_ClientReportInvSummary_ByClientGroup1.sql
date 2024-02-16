--[Billing_ClientReportInvSummary_ByClientGroup] 10660,3,'11/30/2014'

--[Billing_ClientReportInvSummary_ByClientGroup] 10660,3,'11/30/2014'



--Exec [Billing_ClientReportInvSummary_ByClientGroup] 11045,2 

--Exec [Billing_ClientReportInvSummary_ByClientGroup1] 11045,1



--Exec [Billing_ClientReportInvSummary_ByClientGroup1] 11045,4,'1/31/2015'



CREATE PROCEDURE [dbo].[Billing_ClientReportInvSummary_ByClientGroup1] 

	-- Add the parameters for the stored procedure here

	@CLNO int,@ClientGroupCode int = null, @invDate Date = null,@AffiliateID Int = null

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



	CREATE TABLE #tmpInv (apno INT,[Last Name] varchar(50),[First Name] varchar(50),[Middle Name] varchar(20),Department varchar(20),[Process Level] varchar(50),[GLAccount#] varchar(50),invoicenumber INT,InvDate DateTime,CompDate DateTime,CLNO INT,
	Amount smallmoney,TaxRate smallmoney,[Description] varchar(100),[AddOn Fee]  varchar(3))



	IF (@AffiliateID is Not Null)

		Insert into #tmpInv

		select i.apno ,

		last [Last Name],first [First Name], Isnull(Middle,'') as [Middle Name],

		Isnull(DeptCode,'') Department,

		IsNull(a.xmld.value('(/CustomClientData/ClientData1)[1]', 'varchar(50)'),'') as [Process Level],

		IsNull(a.xmld.value('(/CustomClientData/ClientData2)[1]', 'varchar(30)'),'') as [GLAccount#],

		--a.xmld.value('(/CustomClientData/ClientData3)[1]', 'varchar(20)') as LocationCode,

		i.invoicenumber ,ii.InvDate,CompDate ,appl.CLNO,Amount,(case when C.IsTaxExempt = 1 then 0 else TR.TaxRate end) TaxRate,

		i.[Description],

		case when i.type = 1 then 'Yes' when i.description like '%service charge%' and i.type = 2 then 'Yes' else 'No' end As [AddOn Fee]

		from dbo.invdetail i left join 

		dbo.appl  on i.apno = appl.Apno left join

		dbo.applclientdata a on appl.apno = a.apno inner join 

		dbo.Client C on appl.CLNO = C.CLNO left join

		dbo.reftaxrate TR on C.TaxRateID = TR.TaxRateID inner join

		dbo.invmaster ii on i.invoicenumber = ii.invoicenumber 

		where 

		i.billed = 1  and cast(invDate as Date) = @invDate and (C.affiliateid = @AffiliateID or   (case when @AffiliateID=4 then C.name else '1' end like case when @AffiliateID=4 then  'HCA%' else '1' end ) )		

	ELSE IF (@ClientGroupCode IS NULL)

		Insert into #tmpInv

		select i.apno ,

		last [Last Name],first [First Name], Isnull(Middle,'') as [Middle Name],

		Isnull(DeptCode,'') Department,

		IsNull(a.xmld.value('(/CustomClientData/ClientData1)[1]', 'varchar(50)'),'') as [Process Level],

		IsNull(a.xmld.value('(/CustomClientData/ClientData2)[1]', 'varchar(30)'),'') as [GLAccount#],

		--a.xmld.value('(/CustomClientData/ClientData3)[1]', 'varchar(20)') as LocationCode,

		i.invoicenumber ,ii.InvDate,CompDate ,appl.CLNO,Amount,(case when C.IsTaxExempt = 1 then 0 else TR.TaxRate end) TaxRate,

		i.[Description],

		case when i.type = 1 then 'Yes' when i.description like '%service charge%' and i.type = 2 then 'Yes' else 'No' end As [AddOn Fee]

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

		Isnull(DeptCode,'') Department,

		IsNull(a.xmld.value('(/CustomClientData/ClientData1)[1]', 'varchar(50)'),'') as [Process Level],

		IsNull(a.xmld.value('(/CustomClientData/ClientData2)[1]', 'varchar(30)'),'') as [GLAccount#],

		--a.xmld.value('(/CustomClientData/ClientData3)[1]', 'varchar(20)') as LocationCode,

		i.invoicenumber ,ii.InvDate,CompDate ,appl.CLNO,Amount,(case when C.IsTaxExempt = 1 then 0 else TR.TaxRate end) TaxRate,

		i.[Description],

		case when i.type = 1 then 'Yes' when i.description like '%service charge%' and i.type = 2 then 'Yes' else 'No' end As [AddOn Fee]

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



		Select Distinct 'Summary' FileType,Case When len(Department)=5 then Department else [Process Level] end [Process Level] ,isnull([GLAccount#],'') [GLAccount#], [Last Name],[First Name],[Middle Name],invoicenumber [PreCheck Invoice Number],InvDate [PreChe
ck Invoice Date], t1.APNO [PreCheck RequestID],CompDate [PreCheck Request Completion Date],CLNO [Precheck CLNO],SubTotal,Tax, (Subtotal + Tax) Total

		from #tmpInv t1 inner join #tmpInv2 t2 on t1.APNO = t2.APNO

		order by [Process Level],[GLAccount#],CLNO,[Last Name]



		DROP TABLE #tmpInv2

	--END



	--IF(@SPMODE = 2) -- Detail

	--BEGIN	



		select APNO,Round((sum(amount) * TaxRate/100),2) As Tax  into #tmpInvTax

		from #tmpInv 

		group by APNO,TaxRate



		Select 'Detail' FileType,  [Process Level],[GLAccount#],[Last Name],[First Name],[Middle Name],invoicenumber [PreCheck Invoice Number],InvDate [PreCheck Invoice Date],APNO [PreCheck RequestID],CompDate [PreCheck Request Completion Date],CLNO [Precheck C
LNO]

		,[Description],[AddOn Fee],Amount From

		(

			Select Case When len(Department)=5 then Department else [Process Level] end [Process Level],isnull([GLAccount#],'') [GLAccount#], [Last Name],[First Name],[Middle Name],invoicenumber ,InvDate , APNO,CompDate ,CLNO ,

			[Description],[AddOn Fee],Amount

			From #tmpInv

			UNION ALL

			--TAX ITEMS

			select Distinct Case When len(Department)=5 then Department else [Process Level] end [Process Level],isnull([GLAccount#],'') [GLAccount#], [Last Name],[First Name],[Middle Name],invoicenumber ,InvDate , t1.APNO,CompDate ,CLNO ,

			'Tax Amount' [Description],

			'No' As AddOnFee,

			Tax Amount

			from #tmpInv t1 inner join #tmpInvTax t2 on t1.APNO = t2.APNO

		) QRY

		order by [Process Level],[GLAccount#],CLNO,[Last Name]



		DROP TABLE #tmpInvTax



	--END



	DROP TABLE #tmpInv



SET TRANSACTION ISOLATION LEVEL READ COMMITTED

SET NOCOUNT OFF

END

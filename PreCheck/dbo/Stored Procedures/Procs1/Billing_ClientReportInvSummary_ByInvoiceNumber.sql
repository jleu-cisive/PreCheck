

--Exec [Billing_ClientReportInvSummary_ByInvoiceNumber] 15895,9269072


CREATE PROCEDURE [dbo].[Billing_ClientReportInvSummary_ByInvoiceNumber] 

	-- Add the parameters for the stored procedure here

@CLNO int, @InvoiceNumber int


AS
BEGIN

SET ANSI_WARNINGS ON
SET ARITHABORT ON

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


		
CREATE TABLE #tmpInv (apno INT,[Last Name] varchar(50),[First Name] varchar(50),[Middle Name] varchar(20),Department varchar(50),[Process Level] varchar(50),[GLAccount#] varchar(50),invoicenumber INT,InvDate DateTime,CompDate DateTime,Client Varchar(250)
,Amount smallmoney,TaxRate smallmoney,[Description] varchar(100),[AddOn Fee]  varchar(3))

		Insert into #tmpInv
		select i.apno ,
			last [Last Name],first [First Name], Isnull(Middle,'') as [Middle Name],
			Isnull(DeptCode,'')  [Process Level],
			IsNull(a.xmld.value('(/CustomClientData/ClientData1)[1]', 'varchar(50)'),'') as Department,
			IsNull(a.xmld.value('(/CustomClientData/ClientData2)[1]', 'varchar(30)'),'') as [GLAccount#],
			--a.xmld.value('(/CustomClientData/ClientData3)[1]', 'varchar(20)') as LocationCode,
			i.invoicenumber ,ii.InvDate,CompDate ,(cast(appl.CLNO as varchar)  + ' - ' +  C.Name) as Client,Amount,(case when C.IsTaxExempt = 1 then 0 else TR.TaxRate end) TaxRate,
			Replace(i.[Description],',',' ') Description,
			case when i.type = 1 then 'Yes' when i.description like '%service charge%' and i.type = 2 then 'Yes' else 'No' end As [AddOn Fee]
		from dbo.invdetail i 
		  left join dbo.appl  on i.apno = appl.Apno
		  left join dbo.applclientdata a on appl.apno = a.apno 
		  inner join dbo.Client C on appl.CLNO = C.CLNO
		  left join dbo.reftaxrate TR on C.TaxRateID = TR.TaxRateID 
		  inner join dbo.invmaster ii on i.invoicenumber = ii.invoicenumber 
		where 
			i.billed = 1  and i.InvoiceNumber = @InvoiceNumber and appl.CLNO = @CLNO
			


		select  APNO,sum(amount) SubTotal,Round((sum(amount) * TaxRate/100),2) As Tax  into #tmpInv2
		from #tmpInv 
		group by APNO,TaxRate

		
		Select Distinct 'Summary' FileType, Case When (len(Department)=5 and len([Process Level]) < 5) then Department else (case when isnull([Process Level],'')='' then Department else [Process Level] end) end [Process Level], [Last Name],[First Name],
				[Middle Name],invoicenumber [PreCheck Invoice Number],InvDate [PreCheck Invoice Date], t1.APNO [PreCheck RequestID],CompDate [PreCheck Request Completion Date],Client [Precheck CLNO],SubTotal,Tax, (Subtotal + Tax) Totaln
			from #tmpInv t1 inner join #tmpInv2 t2 on t1.APNO = t2.APNO
			order by [Process Level],Client,[Last Name]			

		DROP TABLE #tmpInv2


		select APNO,Round((sum(amount) * TaxRate/100),2) As Tax  into #tmpInvTax
		from #tmpInv 
		group by APNO,TaxRate

		Select 'Detail' FileType, Department,[Process Level],[GLAccount#],[Last Name],[First Name],[Middle Name],invoicenumber [PreCheck Invoice Number],InvDate [PreCheck Invoice Date],APNO [PreCheck RequestID],CompDate [PreCheck Request Completion Date],
			Client [Precheck CLNO],Replace(Description,',',' ') Description,[AddOn Fee],Amount into #tmpDetail From
			(
				Select Department,[Process Level],isnull([GLAccount#],'') [GLAccount#], [Last Name],[First Name],[Middle Name],invoicenumber ,InvDate , APNO,CompDate ,Client ,
				[Description],[AddOn Fee],Amount
			From #tmpInv
			
			UNION ALL
			
			--TAX ITEMS
				select Distinct Department,[Process Level],isnull([GLAccount#],'') [GLAccount#], [Last Name],[First Name],[Middle Name],invoicenumber ,InvDate , t1.APNO,CompDate ,Client ,
					'Tax Amount' [Description],
					'No' As AddOnFee,
					Tax Amount
				from #tmpInv t1 inner join #tmpInvTax t2 on t1.APNO = t2.APNO
			) QRY


			Select FileType, Case When (len(Department)=5 and len([Process Level]) < 5) then Department else (case when isnull([Process Level],'')='' then Department else [Process Level] end) end [Process Level],[Last Name],[First Name],[Middle Name], 
				[PreCheck Invoice Number], [PreCheck Invoice Date], [PreCheck RequestID], [PreCheck Request Completion Date],
	            [Precheck CLNO],Replace(Description,',',' ') Description,[AddOn Fee],Amount From #tmpDetail 
			order by [Process Level],[Precheck CLNO],[Last Name]

	
		DROP TABLE #tmpDetail
		DROP TABLE #tmpInvTax
		DROP TABLE #tmpInv

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET NOCOUNT OFF

END

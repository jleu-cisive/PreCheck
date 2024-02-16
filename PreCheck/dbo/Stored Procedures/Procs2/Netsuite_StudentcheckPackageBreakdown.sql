-- =============================================
-- Author:		kiran
-- Create date: 9/202021
-- Description:	this procedure is used to breakdown student check packages into components for Netsuite billing purpose.
-- exec [dbo].[Netsuite_StudentcheckPackageBreakdown] '10/6/2021'
-- =============================================
CREATE PROCEDURE [dbo].[Netsuite_StudentcheckPackageBreakdown]
	@invdate Datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   declare @startdate datetime = @invdate
declare @enddate datetime = dateadd(s,-1,dateadd(d,1,@invdate))
declare @month int = month(@invdate)
declare @year int = year(@invdate)

--select @invdate,@startdate,@enddate,@month,@year
--truncate table Precheck.[dbo].[NetSuiteDailyInvoice]

select  * into #tempPayment from [PrecheckServices].[dbo].[Payment]   where TimeCreated > @startdate  and TimeCreated < @enddate and PaymentStatusId = 2 order by 1 desc


select * into #tempAppl from precheck.dbo.appl where apno in (select Appno from #tempPayment)

select  * into #tempInvdetail from precheck.dbo.invdetail  where apno in (select Apno from #tempAppl) and (description like '%Drug%' or description like '%Immuniza%')
select  Apno , sum(amount)amt into #tempInvdetailgroup from #tempInvdetail group by APNO

--select  * from Payment where appno  in (5840440)-- (select Apno from #tempAppl where Investigator in ('DSOnly','Immuniz') )
--select  * from precheck.dbo.Appl where apno = 5838815 --order by Investigator  ** SERVICE NOTES  **Background: , DrugScreen: , Immunization:   ;Job State: ; Salary Range: 
--select  * from precheck.dbo.Invdetail  where apno = 5838815
--select  * from #tempAppl where Priv_Notes like '%Background%'
--select  * from #tempAppl where Priv_Notes like '%DrugScreen%'
--select  * from #tempAppl-- where Priv_Notes like '%Immunization%'

--select  * from #tempPayment where appno in ('6104092') order by appno
--select  * from #tempAppl where Priv_Notes like '%Background%' order by apno
--select  * from #tempAppl where apno in ('6092490','6089941') order by apno
--select  * from #tempInvdetail  where apno in ('6092490','6089941') order by apno
--select  * from #tempInvdetailgroup where apno in ('6092490','6089941') order by apno

--select *, (Amount - isnull(Amt,0)) as BGAmt from #tempPayment p left join #tempInvdetailgroup g on p.appNo = APNO where p.appno in (select  apno from #tempAppl where Priv_Notes like '%Background%')
--select *, (Amount - isnull(Amt,0)) as BGAmt from #tempPayment p left join #tempInvdetailgroup g on p.appNo = APNO where p.appno in (select  apno from #tempAppl where Priv_Notes like '%DrugScreen%') and isnull(amt,0) = 0
--select *, (Amount - isnull(Amt,0)) as BGAmt from #tempPayment p left join #tempInvdetailgroup g on p.appNo = APNO where p.appno in (select  apno from #tempAppl where Priv_Notes like '%DrugScreen%')
--select *, (Amount - isnull(Amt,0)) as BGAmt from #tempPayment p left join #tempInvdetailgroup g on p.appNo = APNO where p.appno in (select  apno from #tempAppl where Priv_Notes like '%Immunization%')
--select *, (Amount - isnull(Amt,0)) as BGAmt from #tempPayment p left join #tempInvdetailgroup g on p.appNo = APNO where p.appno in (select  apno from #tempAppl where Priv_Notes like '%Immunization%') and isnull(amt,0) = 0

--drop Table #temp1
--drop Table #temp2** SERVICE NOTES  **DrugScreen: , Immunization:   ;Job State: ; Salary Range: 
--INSERT INTO [dbo].[NetSuiteDailyInvoice]
--           ([Invoicenumber] ,[Type] ,[InvoiceDate],[InvoiceMonth] ,[InvoiceYear]  ,[CreateDate] ,[Description]  ,[Amount]  ,[PrecheckPrice]
--           ,[ScaleFactor]  ,[LeadCountInPackage] ,[AdjustedPriceperPackage]  ,[Passthru]  ,[Frequency]  ,[componentprice]  ,[leadtype] ,[NumCase]    ,[Leadtypeid]
--           ,[LeadtypeDescription]
--           ,[NumLead])
    iNSERT INTO Precheck.[dbo].[NetSuiteDailyInvoice]
           ([Invoicenumber] ,[Type] ,[InvoiceDate] ,[InvoiceMonth] ,[InvoiceYear],[CreateDate]           ,[Description] ,[Amount]           ,[PrecheckPrice],Frequency	   )
 select 
           P.[APPNO]  , 0 [Type] ,CAST(@invdate as Date)  , month(@invdate),		   year(@invdate)  ,CURRENT_TIMESTAMP,
		   'Student Check Package',  (Amount - isnull(Amt,0))  [Amount]
           ,0,0
				    from #tempPayment p left join #tempInvdetailgroup g on p.appNo = APNO where p.appno in (select  apno from #tempAppl where isnull(Investigator,'') not in ( 'DSImmu', 'Immuniz','DSOnly' ))
					and (Amount - isnull(Amt,0)) > 0
					

			iNSERT INTO Precheck.[dbo].[NetSuiteDailyInvoice]
           ([Invoicenumber] ,[Type] ,[InvoiceDate] ,[InvoiceMonth] ,[InvoiceYear],[CreateDate]           ,[Description] ,[Amount]           ,[PrecheckPrice],Frequency	,[AdjustedPriceperPackage]	   )
 select 
           P.[APPNO]  , 10 [Type] ,CAST(@invdate as Date)  , month(@invdate),		   year(@invdate)  ,CURRENT_TIMESTAMP,
		   'Drug Screen  Package',    [Amount]        ,0,0,    [Amount]
		 

		    from #tempPayment p left join #tempInvdetailgroup g on p.appNo = APNO where p.appno in (select  apno from #tempAppl where Priv_Notes like '%DrugScreen%') and isnull(amt,0) = 0
		
		
		
			iNSERT INTO Precheck.[dbo].[NetSuiteDailyInvoice]
           ([Invoicenumber] ,[Type] ,[InvoiceDate] ,[InvoiceMonth] ,[InvoiceYear],[CreateDate]           ,[Description] ,[Amount]           ,[PrecheckPrice],Frequency,[AdjustedPriceperPackage]		   )
 select 
           P.[APPNO]  , 11 [Type] ,CAST(@invdate as Date)  , month(@invdate),		   year(@invdate)  ,CURRENT_TIMESTAMP,
		   'Immunization  Package',   [Amount]
           ,0,0,    [Amount]
		

		    from #tempPayment p left join #tempInvdetailgroup g on p.appNo = APNO where p.appno in (select  apno from #tempAppl where Priv_Notes like '%Immunization%') and isnull(amt,0) = 0

			iNSERT INTO Precheck.[dbo].[NetSuiteDailyInvoice]
           ([Invoicenumber] ,[Type] ,[InvoiceDate] ,[InvoiceMonth] ,[InvoiceYear],[CreateDate]           ,[Description] ,[Amount]           ,[PrecheckPrice],Frequency	,[AdjustedPriceperPackage]	   )
 select 
           [APNO]  , [Type] ,CAST(@invdate as Date)  , month(@invdate),		   year(@invdate)  ,CURRENT_TIMESTAMP,
		   [Description],   [Amount]
           ,0,0,    [Amount]
		

		    from precheck.dbo.invdetail where APNO in  (select Appno from #tempPayment) and ([Description] like '%Drug%' or [Description] like '%Immun%')
			
			iNSERT INTO Precheck.[dbo].[NetSuiteDailyInvoice]
           ([Invoicenumber] ,[Type] ,[InvoiceDate] ,[InvoiceMonth] ,[InvoiceYear],[CreateDate]           ,[Description] ,[Amount]           ,[PrecheckPrice],Frequency	,[AdjustedPriceperPackage]	   )
 select 
           P.[APNO]  , 10 [Type] ,CAST(@invdate as Date)  , month(@invdate),		   year(@invdate)  ,CURRENT_TIMESTAMP,
		   'Drug Screen  Package',  DSAmount  [Amount]        ,0,0,  DSAmount  [Amount]
		 

		    from #tempAppl p
			inner join ( select [Invoicenumber] as Apno ,totalamt - sumamt as DSAmount from
			((select [Invoicenumber], sum([Amount]) sumamt  from Precheck.[dbo].[NetSuiteDailyInvoice] group by invoicenumber) n
			inner join (select Appno, sum([Amount]) totalamt  from #tempPayment group by Appno) tp on n.invoicenumber = tp.appno)
			) g on p.apno = g.Apno
			--inner join (  
			where Investigator = 'DSImmu'
			
			--p.apno in (select  apno from #tempAppl where Priv_Notes like '%DrugScreen%') and isnull(amt,0) = 0
			--#tempPayment p left join #tempInvdetailgroup g on p.appNo = APNO where p.appno in (select  apno from #tempAppl where Priv_Notes like '%DrugScreen%') and isnull(amt,0) = 0
		
--1 sanctioncheck
-- 1 Social search
-- 1 Criminal Search: SEX OFFENDER, US, USA	13391
-- 2 criminal
			iNSERT INTO Precheck.[dbo].[NetSuiteDailyInvoice]
           ([Invoicenumber] ,[Type] ,[InvoiceDate] ,[InvoiceMonth] ,[InvoiceYear],[CreateDate]           ,[Description] ,[Amount]           ,[PrecheckPrice],Frequency		   )
 select 
           P.[APPNO]  , 2 [Type] ,CAST(@invdate as Date)  , month(@invdate),		   year(@invdate)  ,CURRENT_TIMESTAMP,
		   'Criminal Search: SEX OFFENDER, US, USA',  0  [Amount] ,1.00,1
		   from #tempPayment p left join #tempInvdetailgroup g on p.appNo = APNO where p.appno in (select  apno from #tempAppl where isnull(Investigator,'') not in ( 'DSImmu', 'Immuniz','DSOnly' ))
		   and (Amount - isnull(Amt,0)) > 0

			iNSERT INTO Precheck.[dbo].[NetSuiteDailyInvoice]
           ([Invoicenumber] ,[Type] ,[InvoiceDate] ,[InvoiceMonth] ,[InvoiceYear],[CreateDate]           ,[Description] ,[Amount]           ,[PrecheckPrice],Frequency		   )
 select 
           P.[APPNO]  , 2 [Type] ,CAST(@invdate as Date)  , month(@invdate),		   year(@invdate)  ,CURRENT_TIMESTAMP,
		   'Criminal Search 1 US, USA',  0  [Amount],7.00,2
		 from #tempPayment p left join #tempInvdetailgroup g on p.appNo = APNO where p.appno in (select  apno from #tempAppl where isnull(Investigator,'') not in ( 'DSImmu', 'Immuniz','DSOnly' ))
		 and (Amount - isnull(Amt,0)) > 0

			iNSERT INTO Precheck.[dbo].[NetSuiteDailyInvoice]
           ([Invoicenumber] ,[Type] ,[InvoiceDate] ,[InvoiceMonth] ,[InvoiceYear],[CreateDate]           ,[Description] ,[Amount]           ,[PrecheckPrice],Frequency		   )
 select 
           P.[APPNO]  , 2 [Type] ,CAST(@invdate as Date)  , month(@invdate),		   year(@invdate)  ,CURRENT_TIMESTAMP,
		    'Criminal Search 2 US, USA',  0  [Amount],7.00,2
			 from #tempPayment p left join #tempInvdetailgroup g on p.appNo = APNO where p.appno in (select  apno from #tempAppl where isnull(Investigator,'') not in ( 'DSImmu', 'Immuniz','DSOnly' ))
			 and (Amount - isnull(Amt,0)) > 0

			iNSERT INTO Precheck.[dbo].[NetSuiteDailyInvoice]
           ([Invoicenumber] ,[Type] ,[InvoiceDate] ,[InvoiceMonth] ,[InvoiceYear],[CreateDate]           ,[Description] ,[Amount]           ,[PrecheckPrice],Frequency		   )
 select 
           P.[APPNO]  , 4 [Type] ,CAST(@invdate as Date)  , month(@invdate),		   year(@invdate)  ,CURRENT_TIMESTAMP,
		   'Social Search',  0  [Amount],0.50,1
				    from #tempPayment p left join #tempInvdetailgroup g on p.appNo = APNO where p.appno in (select  apno from #tempAppl where isnull(Investigator,'') not in ( 'DSImmu', 'Immuniz','DSOnly' ))
			and (Amount - isnull(Amt,0)) > 0

			iNSERT INTO Precheck.[dbo].[NetSuiteDailyInvoice]
           ([Invoicenumber] ,[Type] ,[InvoiceDate] ,[InvoiceMonth] ,[InvoiceYear],[CreateDate]           ,[Description] ,[Amount]           ,[PrecheckPrice],Frequency		   )
 select 
           P.[APPNO]  , 14 [Type] ,CAST(@invdate as Date)  , month(@invdate),		   year(@invdate)  ,CURRENT_TIMESTAMP,
		   'Sanction Check',  0  [Amount],0.50,1
		
		    from #tempPayment p left join #tempInvdetailgroup g on p.appNo = APNO where p.appno in (select  apno from #tempAppl where isnull(Investigator,'') not in ( 'DSImmu', 'Immuniz','DSOnly' ))
			and (Amount - isnull(Amt,0)) > 0

			update Precheck.[dbo].[NetSuiteDailyInvoice] set AdjustedPriceperPackage = PrecheckPrice,Frequency = 1   where description = 'Social Search' and  Type = 4 and AMOUNT = 0 and InvoiceMonth = @month and InvoiceYear = @year
update Precheck.[dbo].[NetSuiteDailyInvoice] set AdjustedPriceperPackage = 1, PrecheckPrice = 1   where  description =  'Criminal Search: SEX OFFENDER, US, USA'  and Type = 2 and AMOUNT = 0  and InvoiceMonth = @month and InvoiceYear = @year
update Precheck.[dbo].[NetSuiteDailyInvoice] set AdjustedPriceperPackage = 0.5, PrecheckPrice = 0.5    where  description =  'Sanction Check'  and Type = 14 and AMOUNT = 0 and InvoiceMonth = @month and InvoiceYear = @year


--select * from  Precheck.[dbo].[NetSuiteDailyInvoice]  where  Description  like '%drug%' and InvoiceMonth = @month and InvoiceYear = @year
	

	Update Precheck.[dbo].[NetSuiteDailyInvoice] set type = 10,LeadCountInPackage = 10 ,leadtype  =  'Drug Screening' , NumCase = 1  where  Description  like '%drug%' and InvoiceMonth = @month and InvoiceYear = @year
	
	--select * from  Precheck.[dbo].[NetSuiteDailyInvoice]  where  Description  like '%drug%' and InvoiceMonth = @month and InvoiceYear = @year
	
	Update Precheck.[dbo].[NetSuiteDailyInvoice] set type = 11, LeadCountInPackage = 11 , leadtype  =  'Immunization', NumCase = 1 where  Description  like '%Immuni%' and InvoiceMonth = @month and InvoiceYear = @year
		Update Precheck.[dbo].[NetSuiteDailyInvoice] set LeadCountInPackage = 4 ,leadtype  =  'Social Search',NumCase = 1/cast(5 AS DECIMAL(18,4))   where (LeadCountInPackage is null or LeadCountInPackage = 0) and Type =4 and InvoiceMonth = @month and InvoiceYear = @year
		Update Precheck.[dbo].[NetSuiteDailyInvoice] set LeadCountInPackage = 14,leadtype  =  'Sanction Check',NumCase = 1/cast(5 AS DECIMAL(18,4))    where (LeadCountInPackage is null or LeadCountInPackage = 0) and Type =14 and InvoiceMonth = @month and InvoiceYear = @year
		Update Precheck.[dbo].[NetSuiteDailyInvoice] set LeadCountInPackage = 2 ,leadtype  =  'Criminal',NumCase = 1/cast(5 AS DECIMAL(18,4))   where Type in ( 1,2) and InvoiceMonth = @month and InvoiceYear = @year
		 update Precheck.[dbo].[NetSuiteDailyInvoice] set componentprice =  (Frequency*[PrecheckPrice])   
			 where amount = 0 and Frequency > 0 and isnull(AdjustedPriceperPackage,0) =0  and InvoiceMonth = @month and InvoiceYear = @year
			 --select * from Precheck.[dbo].[NetSuiteDailyInvoice]  where invoicenumber in ('6058807','6058509') order by Invoicenumber

			 	 -- calculating Scale factor

			  select distinct Invoicenumber,type,componentprice into #Temp1 from Precheck.[dbo].[NetSuiteDailyInvoice] where componentprice > 0 and Frequency > 0 and InvoiceMonth = @month and InvoiceYear = @year and isnull(AdjustedPriceperPackage,0) =0 
			 group by Invoicenumber,type,componentprice

			 select  Invoicenumber,AdjustedPriceperPackage,type into #Temp3 from Precheck.[dbo].[NetSuiteDailyInvoice] where AdjustedPriceperPackage > 0 and InvoiceMonth = @month and InvoiceYear = @year
			 group by Invoicenumber,AdjustedPriceperPackage,Type
			 
		
			
			 -- calculating Scale factor
			 --	scale factor  = package price / sum of distinct componentprice by type
			Select Invoicenumber ,((Amount - isnull((Select sum(AdjustedPriceperPackage) from #temp3 t3 where t3.Invoicenumber = i.Invoicenumber and type in (2,4,14)  group by Invoicenumber) ,0))/ (Select sum(componentprice) from #temp1 t where t.Invoicenumber = i.Invoicenumber  group by Invoicenumber )) as [scalefactor] 
			into #temp2 from  Precheck.[dbo].[NetSuiteDailyInvoice] i where Type = 0  and InvoiceMonth = @month and InvoiceYear = @year
				
			 

			update i set [scalefactor] =  t.[scalefactor]   from Precheck.[dbo].[NetSuiteDailyInvoice] i inner join #temp2 t on i.Invoicenumber = t.Invoicenumber

			drop table #temp1
			drop table #temp2
			drop table #temp3

			update Precheck.[dbo].[NetSuiteDailyInvoice] set AdjustedPriceperPackage =  (componentprice*[scalefactor])/Frequency  
			 where componentprice > 0 and Frequency > 0 and  isnull(AdjustedPriceperPackage,0) =0
	 and InvoiceMonth = @month and InvoiceYear = @year


	 update Precheck.[dbo].[NetSuiteDailyInvoice] set Leadtypeid = 0,LeadtypeDescription = 'HC-PACKAGE-HEALTHCARE'
where  AdjustedPriceperPackage = 0  and type =0-- and leadtype = 'criminal' and Leadtypeid is null and description like '%Civil%'
 and InvoiceMonth = @month and InvoiceYear = @year
 			 --select * from Precheck.[dbo].[NetSuiteDailyInvoice]  where invoicenumber in ('6058807','6058509') order by Invoicenumber


update Precheck.[dbo].[NetSuiteDailyInvoice] set Leadtypeid = 2,LeadtypeDescription = 'CRIM'
where  AdjustedPriceperPackage <> 0 and (leadtype = 'criminal' or leadtype = 'Social Search') and Leadtypeid is null 
 and InvoiceMonth = @month and InvoiceYear = @year
 update Precheck.[dbo].[NetSuiteDailyInvoice] set Leadtypeid = 7,LeadtypeDescription = 'SANCTCHKBG'
where  AdjustedPriceperPackage <> 0 and (leadtype = 'Sanction Check') and Leadtypeid is null 
 and InvoiceMonth = @month and InvoiceYear = @year
update Precheck.[dbo].[NetSuiteDailyInvoice] set Leadtypeid = 8,LeadtypeDescription = 'DRUG'
where  AdjustedPriceperPackage <> 0 and (leadtype = 'Drug Screening') and Leadtypeid is null 
 and InvoiceMonth = @month and InvoiceYear = @year
update Precheck.[dbo].[NetSuiteDailyInvoice] set Leadtypeid = 9,LeadtypeDescription = 'IMMU'
where  AdjustedPriceperPackage <> 0 and (leadtype = 'Immunization') and Leadtypeid is null
 and InvoiceMonth = @month and InvoiceYear = @year

 			-- select * from Precheck.[dbo].[NetSuiteDailyInvoice]  where invoicenumber in ('6058807','6058509') order by Invoicenumber

 update i1 set Numcase = Case when LEADTYPEID in( 2,3,4,5,6,7,10) and AdjustedPriceperPackage > 0  then i2.cases else 0 end
 ,Numlead = Case when LEADTYPEID in( 2,3,4,5,6,7,10) and AdjustedPriceperPackage > 0  then 1 else 0 end
from Precheck.[dbo].[NetSuiteDailyInvoice] i1
inner join (select Invoicenumber,1/cast(sum(Case when LEADTYPEID in( 2,3,4,5,6,7,10) and AdjustedPriceperPackage > 0  then 1 else 0 end) AS DECIMAL(10,2)) cases 
from Precheck.[dbo].[NetSuiteDailyInvoice] where InvoiceMonth = @month and InvoiceYear = @year
group by Invoicenumber)  i2
on i1.Invoicenumber = i2.Invoicenumber
where --i1.apno = 5307379
--i1.InvoiceNumber = 9308668 
InvoiceMonth = @month and InvoiceYear = @year

 update i1 set Numcase = 1,Numlead = 1
from Precheck.[dbo].[NetSuiteDailyInvoice] i1
where InvoiceMonth = @month and InvoiceYear = @year and LEADTYPEID in( 8,9)
--order by i1.apno,leadtypeid

Update i set AdjustedPriceperPackage =  i.amount - t.adjprice
from Precheck.[dbo].[NetSuiteDailyInvoice] i inner join 
(
select Invoicenumber,Sum(case when Amount >0 then 0 else AdjustedPriceperPackage end) adjprice from Precheck.[dbo].[NetSuiteDailyInvoice] where InvoiceMonth = @month and InvoiceYear = @year
group by Invoicenumber) t on i.Invoicenumber = t.Invoicenumber
 where --i.invoicenumber = 9308876 and 
 type = 0
 AND InvoiceMonth = @month and InvoiceYear = @year


 --select * from Precheck.[dbo].[NetSuiteDailyInvoice] where invoicenumber in (
 -- select invoicenumber from Precheck.[dbo].[NetSuiteDailyInvoice]  where type = 0 and amount = 0)

 drop table #tempPayment
drop table #tempAppl
drop table #tempInvdetail
drop table #tempInvdetailgroup

			-- select * from Precheck.[dbo].[NetSuiteDailyInvoice]  where invoicenumber in ('6058807','6058509') order by Invoicenumber

END

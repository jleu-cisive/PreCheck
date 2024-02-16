
-- =============================================
-- Author:		Kiran Miryala
-- Create date: 04/28/2021
-- Description:	Monthly incoice Output for Netsuite thru Celigo
-- =============================================

CREATE PROCEDURE  [dbo].[Netsuite_StageMonthlyInvoicesData]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN

declare @date datetime = getdate()
declare @month int = month(@date)
declare @year int = year(@date)


--select @date,@month,@year

declare @startdate datetime 
set @date = cast(cast(@month as varchar(2))+ '/01/' + cast(@Year as varchar(4)) as datetime)
set @startdate =  dateadd(mm,-1,@date)


declare @enddate datetime = dateadd(s,-1,@date)
set @month = month(@startdate)
set @year  = year(@startdate)
select @date,@startdate,@enddate,@month,@year

--declare @startdate datetime = '9/1/2021'
--declare @enddate datetime = dateadd(s,-1,'10/01/2021')
--declare @month int = 9
--declare @year int = 2021
--Truncate Table [InvDetailToNetsuite_Stage]

 if (Select count([InvoiceNumber]) from [dbo].InvDetailToNetsuite_Stage where [InvoiceMonth] = @month and [InvoiceYear] = @year) = 0
 begin
 print 'Truncate the stage table and load new Billing months data'
 INSERT INTO [dbo].[InvDetailToNetsuite]
           ([InvDetID]
           ,[APNO]
           ,[Type]
           ,[Subkey]
           ,[SubKeyChar]
           ,[Billed]
           ,[InvoiceNumber]
           ,[InvoiceMonth]
           ,[InvoiceYear]
           ,[CreateDate]
           ,[Description]
           ,[Amount]
           ,[PrecheckPrice]
           ,[ScaleFactor]
           ,[LeadCountInPackage]
           ,[AdjustedPriceperPackage]
           ,[Passthru]
           ,[Frequency]
           ,[componentprice]
           ,[leadtype]
           ,[NumCase]
           ,[Leadtypeid]
           ,[LeadtypeDescription]
           ,[NumLead])
     SELECT 
      [InvDetID]
      ,[APNO]
      ,[Type]
      ,[Subkey]
      ,[SubKeyChar]
      ,[Billed]
      ,[InvoiceNumber]
      ,[InvoiceMonth]
      ,[InvoiceYear]
      ,[CreateDate]
      ,[Description]
      ,[Amount]
      ,[PrecheckPrice]
      ,[ScaleFactor]
      ,[LeadCountInPackage]
      ,[AdjustedPriceperPackage]
      ,[Passthru]
      ,[Frequency]
      ,[componentprice]
      ,[leadtype]
      ,[NumCase]
      ,[Leadtypeid]
      ,[LeadtypeDescription]
      ,[NumLead]
  FROM [dbo].[InvDetailToNetsuite_Stage]
 Truncate table [dbo].[InvDetailToNetsuite_Stage]
 

----	select * from InvDetailToNetsuite_Stage where invoicemonth = 11 order by APNO
----Delete InvDetailToNetsuite_Stage where invoicemonth = 11
----select Top 500 * from InvMaster order by 1 desc
--Truncate table InvDetailToNetsuite_Stage
------alter table InvDetailToNetsuite_Stage
------add  componentprice [smallmoney] NULL
print 'insert from invdetail'
INSERT INTO [dbo].InvDetailToNetsuite_Stage
           ([InvDetID]
           ,[APNO]
           ,[Type]
           ,[Subkey]
           ,[SubKeyChar]
           ,[Billed]
           ,[InvoiceNumber]
		     ,[InvoiceMonth]
      ,[InvoiceYear]
           ,[CreateDate]
           ,[Description]
           ,[Amount]
           ,[PrecheckPrice]
           --,[ScaleFactor]
           --,[LeadCountInPackage]
           --,[AdjustedPriceperPackage]
           --,[Passthru]
		   ,Frequency
		   )
 select [InvDetID]
           ,i1.[APNO]
           ,[Type]
           ,[Subkey]
           ,[SubKeyChar]
           ,[Billed]
           ,i1.[InvoiceNumber]
		      , month(InvDate),		   year(invdate)
           ,[CreateDate]
           ,[Description]
           ,[Amount]
           --,[PrecheckPrice]
           --,[ScaleFactor]
           --,[LeadCountInPackage]
           --,[AdjustedPriceperPackage]
           --,[Passthru]
		  -- ,Frequency
		   ,(case when Type = 2 then 7 else -- crim
			(case when type = 4 then 0.5 else -- social search
			(case when type = 5 then 4 else   -- MVR 
		   (case when type = 6 then  9 else -- empl
		   (case when type = 7 then 8 else -- education
		  ( case when type = 8 then 6 else  -- license
		   (case when type = 9 then 8 else 0 end)   -- persref
		   end)end)end) end) end) end) as [PrecheckPrice]
		  , (case when Amount = 0  then  Freq  else 0 end) Frequency

		     from invdetail i1 
			inner join InvMaster im on i1.InvoiceNumber = im.InvoiceNumber
			left join 
			(select type as typ,apno,id.InvoiceNumber, Count(type) Freq  from InvDetail id 
			inner join InvMaster m on id.InvoiceNumber = m.InvoiceNumber where 
				amount = 0 and Invdetid not in (select Invdetid from InvDetail id1  inner join InvMaster m1 on id1.InvoiceNumber = m1.InvoiceNumber  
				where  m1.InvDate > @startdate and m1.InvDate < @enddate and
				(Type  in ( 4 , 5) or (Type = 2 and description  in  ('Criminal Search: SEX OFFENDER, US, USA' ,'Criminal Search: NATIONAL, USA, USA'))))
		and m.InvDate > @startdate and m.InvDate < @enddate 
			-- InvoiceNumber = 9262560
			--and apno = 4709843 
			group by type,apno,id.InvoiceNumber)			
			 i2 on i1.InvoiceNumber = i2.InvoiceNumber and i1.apno = i2.apno and type = typ
			 where im.InvDate > @startdate and im.InvDate < @enddate
			 --InvoiceMonth = @month and InvoiceYear = @year
			--and i1.apno = 4677123
			 order by apno
			--update InvDetailToNetsuite_Stage set AdjustedPriceperPackage = 0,ScaleFactor = 0,Passthru = 0
		 --select * from InvDetailToNetsuite_Stage   where 			 InvoiceMonth = 11 and InvoiceYear = 2019
		 --order by apno desc
		 --select
		print 'insert sanction check from medinteg'

		 INSERT INTO [dbo].InvDetailToNetsuite_Stage
           ([InvDetID]
           ,[APNO]
           ,[Type]
           ,[Subkey]
           ,[SubKeyChar]
           ,[Billed]
           ,[InvoiceNumber]
		    ,[InvoiceMonth]
			,[InvoiceYear]
           ,[CreateDate]
           ,[Description]
           ,[Amount]
           ,[PrecheckPrice]
            ,Frequency
		   )
 select		0
           ,im.[APNO]
           ,14
           ,Null
           ,Null
           ,1
           ,im.[InvoiceNumber]
		     ,@month
			 ,@year
           ,@enddate
           ,'Sanction Check'
           ,0.00
          ,0.50
		   , 1 
		    from MedInteg i1 
			inner join InvDetailToNetsuite_Stage im on i1.Apno = im.Apno and Type = 0
			 where 	 InvoiceMonth = @month and InvoiceYear = @year and i1.IsHidden =0
			 order by apno

		 
		 

		 print 'set AdjustedPriceperPackage fro default items '
					
update InvDetailToNetsuite_Stage set AdjustedPriceperPackage = PrecheckPrice,Frequency = 1   where description <> 'Credit Report' and  Type = 4 and AMOUNT = 0 and InvoiceMonth = @month and InvoiceYear = @year
update InvDetailToNetsuite_Stage set AdjustedPriceperPackage = 14,PrecheckPrice = 14   where description = 'Credit Report' and  Type = 4 and AMOUNT = 0 and InvoiceMonth = @month and InvoiceYear = @year
update InvDetailToNetsuite_Stage set AdjustedPriceperPackage = 1, PrecheckPrice = 1   where Type = 2 and description =  'Criminal Search: SEX OFFENDER, US, USA'  and AMOUNT = 0  and InvoiceMonth = @month and InvoiceYear = @year
update InvDetailToNetsuite_Stage set AdjustedPriceperPackage = 3, PrecheckPrice = 3    where Type = 2 and description =  'Criminal Search: NATIONAL, USA, USA'  and AMOUNT = 0 and InvoiceMonth = @month and InvoiceYear = @year
update InvDetailToNetsuite_Stage set AdjustedPriceperPackage = 0.5, PrecheckPrice = 0.5    where Type = 14 and description =  'Sanction Check'  and AMOUNT = 0 and InvoiceMonth = @month and InvoiceYear = @year
update InvDetailToNetsuite_Stage set AdjustedPriceperPackage = PrecheckPrice   where   Type = 5 and AMOUNT = 0 and InvoiceMonth = @month and InvoiceYear = @year

 print 'set LeadCountInPackage '
	Update InvDetailToNetsuite_Stage set LeadCountInPackage = 7    where Type in ( 1,7) and (LeadCountInPackage is null or LeadCountInPackage = 0)  and InvoiceMonth = @month and InvoiceYear = @year
		and  (Description  like '%edu%' or   Description  like '%colleg%' or   Description  like '%GED%'  or   Description  like '%School%'  or   Description  like '%Univ%' or Description   like '%Overseas%')
		 Update InvDetailToNetsuite_Stage set LeadCountInPackage = 6    where Type  in ( 1,6) and (LeadCountInPackage is null or LeadCountInPackage = 0)  and InvoiceMonth = @month and InvoiceYear = @year and  
		  (Description  like '%Employment%' or    Description  like '%Emloyment%' or    Description  like '%Em,ployment%' or Description   like '%Thomas%'  or    Description  like '%Emp%' or   Description  like '%Work%' or Description   like '%ployment%') 
		 Update InvDetailToNetsuite_Stage set LeadCountInPackage = 2    where Type in ( 1,2) and  ( Description  like '%ourt%' or Description  like '%crim%' or Description  like '%Reorder%'  or Description   like '%Pass%' or Description   like '%Adult%') and (LeadCountInPackage is null or LeadCountInPackage = 0)  and InvoiceMonth = @month and InvoiceYear = @year
		Update InvDetailToNetsuite_Stage set LeadCountInPackage = 8    where Type in ( 1,8) and Description  like '%Lic%'  and InvoiceMonth = @month and InvoiceYear = @year
		Update InvDetailToNetsuite_Stage set LeadCountInPackage = 5    where Type in ( 1,5) and Description  like '%MVR%' and InvoiceMonth = @month and InvoiceYear = @year
		Update InvDetailToNetsuite_Stage set LeadCountInPackage = 9    where Type in ( 1,9) and Description  like '%Personal%' and InvoiceMonth = @month and InvoiceYear = @year
		Update InvDetailToNetsuite_Stage set LeadCountInPackage = 10    where Type = 1 and  Description  like '%drug%' and  Description not  like '%Employment%'  and  Description not  like '%Sschool%' and InvoiceMonth = @month and InvoiceYear = @year
		Update InvDetailToNetsuite_Stage set LeadCountInPackage = 11   where Type = 1 and Description  like '%Imm%' and  Description not  like '%Employment%'  and  Description not  like '%Sschool%' and InvoiceMonth = @month and InvoiceYear = @year

		Update InvDetailToNetsuite_Stage set LeadCountInPackage = 10    where AdjustedPriceperPackage > 0 and  Description  like '%drug%' and  Description not  like '%Employment%'  and (LeadCountInPackage is null or LeadCountInPackage = 0)  and InvoiceMonth = @month and InvoiceYear = @year
		Update InvDetailToNetsuite_Stage set LeadCountInPackage = 11   where AdjustedPriceperPackage > 0 and Description  like '%Imm%' and  Description  not like '%Edu%' and  Description not  like '%Employment%'  and  Description not  like '%Sschool%' and (LeadCountInPackage is null or LeadCountInPackage = 0) and InvoiceMonth = @month and InvoiceYear = @year
				
		Update InvDetailToNetsuite_Stage set LeadCountInPackage = 4    where (LeadCountInPackage is null or LeadCountInPackage = 0) and Type =4 and InvoiceMonth = @month and InvoiceYear = @year
		Update InvDetailToNetsuite_Stage set LeadCountInPackage = 14    where (LeadCountInPackage is null or LeadCountInPackage = 0) and Type =14 and InvoiceMonth = @month and InvoiceYear = @year
		
		Update InvDetailToNetsuite_Stage set LeadCountInPackage = 12    where (LeadCountInPackage is null or LeadCountInPackage = 0)and type <> 0 and InvoiceMonth = @month and InvoiceYear = @year

		Update InvDetailToNetsuite_Stage set LeadCountInPackage = 15    where Type in (1) and Description  = 'Data Entry Service' and InvoiceMonth = @month and InvoiceYear = @year
		
		 print 'set leadtype '
		--*************************************************
	update InvDetailToNetsuite_Stage set leadtype  =  'Criminal' where  LeadCountInPackage = 2  and InvoiceMonth = @month and InvoiceYear = @year
update InvDetailToNetsuite_Stage set leadtype  =  'Credit Report' where LeadCountInPackage = 13  and InvoiceMonth = @month and InvoiceYear = @year
update InvDetailToNetsuite_Stage set leadtype  =  'Social Search' where LeadCountInPackage = 4  and InvoiceMonth = @month and InvoiceYear = @year
update InvDetailToNetsuite_Stage set leadtype  = 'MVR' where LeadCountInPackage = 5  and InvoiceMonth = @month and InvoiceYear = @year
update InvDetailToNetsuite_Stage set leadtype  =  'Employment' where LeadCountInPackage = 6  and InvoiceMonth = @month and InvoiceYear = @year
update InvDetailToNetsuite_Stage set leadtype  =  'Education' where LeadCountInPackage = 7  and InvoiceMonth = @month and InvoiceYear = @year
update InvDetailToNetsuite_Stage set leadtype  =  'License' where LeadCountInPackage = 8  and InvoiceMonth = @month and InvoiceYear = @year
update InvDetailToNetsuite_Stage set leadtype  =  'Personal Reference' where LeadCountInPackage = 9  and InvoiceMonth = @month and InvoiceYear = @year
update InvDetailToNetsuite_Stage set leadtype  =  'Drug Screening' where LeadCountInPackage = 10  and InvoiceMonth = @month and InvoiceYear = @year
update InvDetailToNetsuite_Stage set leadtype  =  'Immunization' where LeadCountInPackage = 11  and InvoiceMonth = @month and InvoiceYear = @year
update InvDetailToNetsuite_Stage set leadtype  =  'Gen' where LeadCountInPackage = 12    and InvoiceMonth = @month and InvoiceYear = @year
update InvDetailToNetsuite_Stage set leadtype  =  'Sanction Check' where LeadCountInPackage = 14    and InvoiceMonth = @month and InvoiceYear = @year
update InvDetailToNetsuite_Stage set leadtype  =  'DEMI Passthru' where LeadCountInPackage = 15    and InvoiceMonth = @month and InvoiceYear = @year
	--*******************************************
		 print 'set Numcase '
	-- Calculation and dividing  the Num of cases per app 	
update InvDetailToNetsuite_Stage set NumCase = 1 where    LeadCountInPackage = 10 and isnull(NumCase,0) = 0  and InvoiceMonth = @month and InvoiceYear = @year
update InvDetailToNetsuite_Stage set NumCase = 1 where   LeadCountInPackage = 11 and isnull(NumCase,0) = 0  and InvoiceMonth = @month and InvoiceYear = @year
Update i1 set NumCase = 1/cast([count] AS DECIMAL(18,0))
  from InvDetailToNetsuite_Stage i1 inner join
 (Select Apno,Count(apno) as [count] from InvDetailToNetsuite_Stage where  Type <> 0 and Amount = 0   and InvoiceMonth = @month and InvoiceYear = @year and isnull(NumCase,0) = 0  group by apno) i2 on i1.apno = i2.APNO
 where    Type <> 0 and Amount = 0  and InvoiceMonth = @month and InvoiceYear = @year
 and  isnull(NumCase,0) = 0 and  isnull(LeadCountInPackage,0) not in  (10,11)


 -- for line tem packages
  Update i1 set NumCase = 1/cast([count] AS DECIMAL(18,0))
  from InvDetailToNetsuite_Stage i1 inner join
 (Select Apno,Count(apno) as [count] from InvDetailToNetsuite_Stage where  Type not in (0,1)   and InvoiceMonth = @month and InvoiceYear = @year  and isnull(NumCase,0) = 0  group by apno) i2 on i1.apno = i2.APNO
 where   InvoiceMonth = @month and InvoiceYear = @year and Type not in (0,1) --and Amount = 0 --and APNO = 4898175
 and isnull(NumCase,0) = 0 and  isnull(LeadCountInPackage,0) not in  (10,11)
 and I1.Apno in (select apno from  InvDetailToNetsuite_Stage  where   isnull(NumCase,0) = 0 and InvoiceMonth = @month and InvoiceYear = @year and description like '%Line Item%')
  and I2.Apno in (select apno from  InvDetailToNetsuite_Stage  where   isnull(NumCase,0) = 0 and InvoiceMonth = @month and InvoiceYear = @year and description like '%Line Item%')

  Update i1 set NumCase = 1/cast([count] AS DECIMAL(18,0))
  from InvDetailToNetsuite_Stage i1 inner join
 (Select Apno,Count(apno) as [count] from InvDetailToNetsuite_Stage where  Type not in (0,1)  and InvoiceMonth  = @month  and isnull(NumCase,0) = 0  group by apno) i2 on i1.apno = i2.APNO
 where InvoiceMonth  = @month and Type not in (0,1) --and Amount = 0 --and APNO = 4898175
 and isnull(NumCase,0) = 0 and  isnull(LeadCountInPackage,0) not in  (10,11)
 and I1.Apno in (select apno from  InvDetailToNetsuite_Stage  where   isnull(NumCase,0) = 0 and InvoiceMonth = @month and InvoiceYear = @year and description in   ( select distinct description from  InvDetailToNetsuite_Stage  where  Type  = 0  and description  like '%Item%'  ))
  and I2.Apno in (select apno from  InvDetailToNetsuite_Stage  where   isnull(NumCase,0) = 0 and InvoiceMonth = @month and InvoiceYear = @year and description in   ( select distinct description from  InvDetailToNetsuite_Stage  where  Type  = 0  and description  like '%Item%'  ))
  	
	--select * from InvDetailToNetsuite_Stage where InvoiceMonth = @month and InvoiceYear = @year
	--*******************************************


			--	update InvDetailToNetsuite_Stage set AdjustedPriceperPackage = 0,ScaleFactor = 0,Passthru = 0,componentprice =0 where  InvoiceMonth = 1 and InvoiceYear = 2019

				--update InvDetailToNetsuite_Stage set AdjustedPriceperPackage = 0,ScaleFactor = 0,Passthru = 0
		 --select * from InvDetailToNetsuite_Stage   where 			 InvoiceMonth = 12 and InvoiceYear = 2019
		 --order by apno desc
		 
			-- updating the conponent price

			--select * from InvDetailToNetsuite_Stage where apno = 5553467
					 print 'set componentprice  '
			
			 update InvDetailToNetsuite_Stage set componentprice =  (Frequency*[PrecheckPrice])   
			 from InvDetailToNetsuite_Stage where amount = 0 and Frequency > 0 and isnull(AdjustedPriceperPackage,0) =0  and InvoiceMonth = @month and InvoiceYear = @year

		
			 select distinct Apno,type,componentprice into #Temp1 from InvDetailToNetsuite_Stage where componentprice > 0 and Frequency > 0 and InvoiceMonth = @month and InvoiceYear = @year and isnull(AdjustedPriceperPackage,0) =0 
			 group by Apno,type,componentprice

			 select  Apno,AdjustedPriceperPackage,type into #Temp3 from InvDetailToNetsuite_Stage where AdjustedPriceperPackage > 0 and InvoiceMonth = @month and InvoiceYear = @year
			 group by Apno,AdjustedPriceperPackage,Type
			 
		
			
			 -- calculating Scale factor
			 --	scale factor  = package price / sum of distinct componentprice by type
			Select Apno ,((Amount - isnull((Select sum(AdjustedPriceperPackage) from #temp3 t3 where t3.apno = i.apno  group by apno) ,0))/ (Select sum(componentprice) from #temp1 t where t.apno = i.apno  group by apno )) as [scalefactor] 
			into #temp2 from  InvDetailToNetsuite_Stage i where Type = 0  and InvoiceMonth = @month and InvoiceYear = @year
				
			--	 select * from #temp1  where  apno = 4868367
 
			-- select * from #temp3 where  apno = 4868367
			--select * from InvDetailToNetsuite_Stage where  apno = 4868367
			--select * from #Temp2 where  apno = 4868367 
			--select i.Apno,i.amount,isnull((Select sum(AdjustedPriceperPackage) from #temp3 t3 where t3.apno = i.apno  group by apno) ,0),(i.Amount - isnull((Select sum(AdjustedPriceperPackage) from #temp3 t3 where t3.apno = i.apno  group by apno) ,0)),(Select sum(isnull(componentprice,0)) from #temp1 t where t.componentprice <0 and t.apno = i.apno  group by apno)
			--from   InvDetailToNetsuite_Stage i where Type = 0 and apno = 4873609
				 print 'set scalefactor  '
			update i set [scalefactor] =  t.[scalefactor]   from InvDetailToNetsuite_Stage i inner join #temp2 t on i.apno = t.apno

			drop table #temp1
			drop table #temp2
			drop table #temp3
			--update InvDetailToNetsuite_Stage set AdjustedPriceperPackage = 0 
		
			

 
 	 print 'set AdjustedPriceperPackage and passthru  '
		--select * from InvDetailToNetsuite_Stage  where (LeadCountInPackage is null or LeadCountInPackage = 0) and Type >0 and Description  not like '%SSN%'
		--Package breabdown
	update InvDetailToNetsuite_Stage set AdjustedPriceperPackage =  (componentprice*[scalefactor])/Frequency   from InvDetailToNetsuite_Stage where componentprice > 0 and Frequency > 0 and  isnull(AdjustedPriceperPackage,0) =0
	 and InvoiceMonth = @month and InvoiceYear = @year

			update InvDetailToNetsuite_Stage set AdjustedPriceperPackage =  Amount   from InvDetailToNetsuite_Stage where Amount <> 0 and Type  <> 0 and Description not like '%Fee%' and Description not like '%Employment:Work Number:%'  and InvoiceMonth = @month and InvoiceYear = @year
			update InvDetailToNetsuite_Stage set Passthru =  Amount   from InvDetailToNetsuite_Stage where Amount <> 0 and Type  <> 0 and Description  like '%Fee%'
			 and InvoiceMonth = @month and InvoiceYear = @year
			Select *  from InvDetailToNetsuite_Stage where Amount > 0 and Type  = 0 and Description  like '%Fee%'

			update InvDetailToNetsuite_Stage set Passthru =  Amount,AdjustedPriceperPackage = 0   from InvDetailToNetsuite_Stage where   Type = 1 and LeadCountInPackage not in (10,11)  and InvoiceMonth = @month and InvoiceYear = @year
			--update InvDetailToNetsuite_Stage set Passthru =  Amount,AdjustedPriceperPackage = 0   from InvDetailToNetsuite_Stage where   Type <> 0 and amount <> 0 and LeadCountInPackage not in (10,11)
			--select * from InvDetailToNetsuite_Stage where Description like '%Immunization%' and   Description not like '%Employment%' 

				update InvDetailToNetsuite_Stage set Passthru =  0,AdjustedPriceperPackage = Amount
				where Description like '%drug%' and   Description not like '%Employment%' and   Description not like '%Student%'  and InvoiceMonth = @month and InvoiceYear = @year

				
				update InvDetailToNetsuite_Stage set Passthru =  0,AdjustedPriceperPackage = Amount
				where Description like '%Immunization%' and   Description not like '%Employment%'   and InvoiceMonth = @month and InvoiceYear = @year
			
				print 'set  passthru for non Student check(group S) '
				update m set Passthru = Amount
				from InvDetailToNetsuite_Stage m
				inner join InvRegistrar c on m.InvoiceNumber = c.InvoiceNumber
				where Amount > 0 and Type  >1 and LeadCountInPackage not in (10,11) and isnull(AdjustedPriceperPackage,0) = 0  and isnull(passthru,0) = 0
				and BillingCycle <> 'S'   and InvoiceMonth = @month and InvoiceYear = @year

print 'set  passthru for Student check(group S) '
		Update c set Passthru = amount,AdjustedPriceperPackage = 0
from InvDetailToNetsuite_Stage c inner join InvRegistrar r on c.InvoiceNumber = r.InvoiceNumber
where  BillingCycle = 'S'
and LeadCountInPackage not in (10,11)
and amount > 0 and AdjustedPriceperPackage > 0  and InvoiceMonth = @month and InvoiceYear = @year

Update c set Passthru = 0
from InvDetailToNetsuite_Stage c inner join InvRegistrar r on c.InvoiceNumber = r.InvoiceNumber
where  BillingCycle = 'S'
and LeadCountInPackage not in (10,11)
and amount > 0 and Passthru > 0
 and InvoiceMonth = @month and InvoiceYear = @year
Update c set Passthru = 0
from InvDetailToNetsuite_Stage c inner join InvRegistrar r on c.InvoiceNumber = r.InvoiceNumber
where  BillingCycle = 'S'
and LeadCountInPackage not in (10,11)
and amount < 0 and Passthru < 0
 and InvoiceMonth = @month and InvoiceYear = @year

				update InvDetailToNetsuite_Stage set Passthru = amount,  AdjustedPriceperPackage = 0
				 where  Type =1 and AdjustedPriceperPackage >0 and (LeadCountInPackage is null or LeadCountInPackage = 0 or LeadCountInPackage not in  (10,11))
				 and InvoiceMonth = @month and InvoiceYear = @year

print 'line item packages ' 

	
select Apno,count(APNO)as Leadcount into #temp4 from InvDetailToNetsuite_Stage where InvoiceMonth = @month and invoiceyear = @year and Type > 1 and Description not like '%fee%'
and APNO in (select APNO from InvDetailToNetsuite_Stage where Description like '%Line Item%' and amount > 0 )
 group by APNO order by APNO



select C.apno, (amount/Leadcount) as pkgdistribution into #temp5 from InvDetailToNetsuite_Stage c inner join #temp4 t on c.apno = t.apno where Type =0  and InvoiceMonth = @month and InvoiceYear = @year --and Description not like '%fee%'
order by c.apno 
select Distinct c.APNO into #temp6 from InvDetailToNetsuite_Stage c inner join #temp5 t on c.apno = t.apno where Type > 1 and Description not like '%fee%' and amount = 0  and InvoiceMonth = @month and InvoiceYear = @year
order by c.apno 

delete #temp5 where apno in (select APNO from #temp6)

--select * from InvDetailToNetsuite_Stage c inner join #temp5 t on c.apno = t.apno where Type > 1 and Description not like '%fee%' 
--order by c.apno 

update c set AdjustedPriceperPackage = amount+pkgdistribution
from InvDetailToNetsuite_Stage c inner join #temp5 t on c.apno = t.apno where Type > 1 and Description not like '%fee%'   and InvoiceMonth = @month and InvoiceYear = @year

drop table #temp4
drop table #temp5
drop table #temp6




print 'Non line item packages  '
select * into #temp7 from InvDetailToNetsuite_Stage i --inner join appl a on i.apno = a.apno
where  
i.APNO in (select  apno from InvDetailToNetsuite_Stage where   InvoiceMonth = @month and InvoiceYear = @year and Amount > 0 and type = 0)
and  i.APNO not in (select  apno from InvDetailToNetsuite_Stage where   InvoiceMonth = @month and InvoiceYear = @year --and Amount = 0 and Type not in (0,10,11)
and (isnull(ScaleFactor,0) <> 0   ))
and APNO  not in (select APNO from InvDetailToNetsuite_Stage where Description like '%Line Item%' and amount > 0  and InvoiceMonth = @month and InvoiceYear = @year)
--and Amount <> 0 and Type <> 0 
and isnull(LeadCountInPackage,0) not in (10,11) and Type <> 1
	
select Apno,count(APNO)as Leadcount into #temp8 from #temp7 where  Type > 1 and Description not like '%fee%'

 group by APNO order by APNO

--select * from #temp8


select C.apno, (amount/Leadcount) as pkgdistribution into #temp9 from InvDetailToNetsuite_Stage c inner join #temp8 t on c.apno = t.apno where Type =0  and InvoiceMonth = @month and InvoiceYear = @year --and Description not like '%fee%'
order by c.apno 
select Distinct c.APNO into #temp10 from InvDetailToNetsuite_Stage c inner join #temp9 t on c.apno = t.apno where Type > 1 and Description not like '%fee%' and amount = 0  and InvoiceMonth = @month and InvoiceYear = @year
order by c.apno 

delete #temp9 where apno in (select APNO from #temp10)

--select * from InvDetailToNetsuite_Stage c inner join #temp9 t on c.apno = t.apno where Type > 1 and Description not like '%fee%' 
--order by c.apno 

update c set AdjustedPriceperPackage = amount+pkgdistribution
from InvDetailToNetsuite_Stage c inner join #temp9 t on c.apno = t.apno where Type > 1 and Description not like '%fee%'  and InvoiceMonth = @month and InvoiceYear = @year

drop table #temp7
drop table #temp8
drop table #temp9
drop table #temp10

select * into #temp11 from InvDetailToNetsuite_Stage i --inner join appl a on i.apno = a.apno
where  
i.APNO in (select  apno from InvDetailToNetsuite_Stage where   InvoiceMonth = @month and InvoiceYear = @year and Amount > 0 and type = 0)
and  i.APNO not in (select  apno from InvDetailToNetsuite_Stage where   InvoiceMonth = @month and InvoiceYear = @year--and Amount = 0 and Type not in (0,10,11)
and (isnull(ScaleFactor,0) <> 0   ))
and APNO  not in (select APNO from InvDetailToNetsuite_Stage where Description like '%Line Item%' and amount > 0  and InvoiceMonth = @month and InvoiceYear = @year )
--and Amount <> 0 and Type <> 0 
and isnull(LeadCountInPackage,0) not in (10,11) and Type <> 1
--and 	i.apno = 4886575


select Apno,count(APNO)as Leadcount into #temp12 from #temp11 where  Type > 1 and Description not like '%fee%'

 group by APNO order by APNO




select C.apno, (amount/Leadcount) as pkgdistribution into #temp13 from InvDetailToNetsuite_Stage c inner join #temp12 t on c.apno = t.apno where Type =0  and InvoiceMonth = @month and InvoiceYear = @year--and Description not like '%fee%'
order by c.apno 

select Distinct c.APNO into #temp14 from InvDetailToNetsuite_Stage c inner join #temp13 t on c.apno = t.apno where Type > 1 and Description  like '%fee%' and amount = 0  and InvoiceMonth = @month and InvoiceYear = @year
order by c.apno 


delete #temp13 where apno in (select APNO from #temp14)


update c set AdjustedPriceperPackage = amount+pkgdistribution
from InvDetailToNetsuite_Stage c inner join #temp13 t on c.apno = t.apno where Type > 1 and Description not like '%fee%'   and InvoiceMonth = @month and InvoiceYear = @year


drop table #temp11
drop table #temp12
drop table #temp13
drop table #temp14
--***********************************
print 'Update AdjustedPriceperPackage = 0 when package price is 0'

update [InvDetailToNetsuite_Stage] set AdjustedPriceperPackage = 0
where 
Apno in (Select Apno from [InvDetailToNetsuite_Stage] where type = 0 and  amount = 0)
--Description like '%Line%' and Description like '%Item%' and Amount = 0)
And Amount = 0 and AdjustedPriceperPackage <> 0
--***********************************
print 'Update MVR only package'

select * into #tempMVRpkg from  InvDetailToNetsuite_Stage  where   Type  = 0 and InvoiceMonth = @month and InvoiceYear = @year and APNO in   (  select APNO from  InvDetailToNetsuite_Stage  where  Type  = 0  and description  like '%MVR Only%'  and InvoiceMonth = @month and InvoiceYear = @year  )
order by apno,type

select * into #tempMVRLead from  InvDetailToNetsuite_Stage  where   Type  =5  and InvoiceMonth = @month and InvoiceYear = @year and APNO in   (  select APNO from  InvDetailToNetsuite_Stage  where  Type  = 0  and description  like '%MVR Only%'  and InvoiceMonth = @month and InvoiceYear = @year )
order by apno,type

select * from #tempMVRpkg order by apno

select * from #tempMVRLead order by apno

--select t1.*,t2.*  
Update T1 set t1.AdjustedPriceperPackage = T2.amount
from #tempMVRLead t1 inner  join #tempMVRpkg t2 on t1.apno = t2.apno

drop table #tempMVRpkg
drop table #tempMVRLead

--***********************************************
print 'Update drug and immunization package '
Update InvDetailToNetsuite_Stage set LeadCountInPackage = 10    where Type = 1 and  Description  like '%drug%' and  Description not  like '%Employment%'  and  Description not  like '%Sschool%' and (LeadCountInPackage is null or LeadCountInPackage = 0)  and InvoiceMonth = @month and InvoiceYear = @year
		Update InvDetailToNetsuite_Stage set LeadCountInPackage = 11   where Type = 1 and Description  like '%Imm%' and  Description not  like '%Employment%'  and  Description not  like '%Sschool%' and (LeadCountInPackage is null or LeadCountInPackage = 0)  and InvoiceMonth = @month and InvoiceYear = @year

		Update InvDetailToNetsuite_Stage set LeadCountInPackage = 10    where AdjustedPriceperPackage > 0 and  Description  like '%drug%' and  Description not  like '%Employment%'  and (LeadCountInPackage is null or LeadCountInPackage = 0)  and InvoiceMonth = @month and InvoiceYear = @year
		Update InvDetailToNetsuite_Stage set LeadCountInPackage = 11   where AdjustedPriceperPackage > 0 and Description  like '%Imm%' and  Description  not like '%Edu%' and  Description not  like '%Employment%'  and  Description not  like '%Sschool%' and (LeadCountInPackage is null or LeadCountInPackage = 0)  and InvoiceMonth = @month and InvoiceYear = @year
				

update InvDetailToNetsuite_Stage set leadtype  =  'Drug Screening' where LeadCountInPackage = 10 and leadtype is null  and InvoiceMonth = @month and InvoiceYear = @year
update InvDetailToNetsuite_Stage set leadtype  =  'Immunization' where LeadCountInPackage = 11 and leadtype is null  and InvoiceMonth = @month and InvoiceYear = @year


print 'Update Leadtypeid and LeadtypeDescription  '


update InvDetailToNetsuite_Stage set Leadtypeid = 0,LeadtypeDescription = 'HC-PACKAGE-HEALTHCARE'
where  AdjustedPriceperPackage = 0 and Passthru =0 and type =0-- and leadtype = 'criminal' and Leadtypeid is null and description like '%Civil%'

update InvDetailToNetsuite_Stage set Leadtypeid = 6,LeadtypeDescription = 'CIV-FEE'
where  AdjustedPriceperPackage <> 0 and leadtype = 'criminal' and Leadtypeid is null and description like '%Civil%'
--AdjustedPriceperPackage = PrecheckPrice,Frequency = 1   where description <> 'Credit Report' and  Type = 4 and AMOUNT = 0 and InvoiceMonth = @month and InvoiceYear = @year
update InvDetailToNetsuite_Stage set Leadtypeid = 15,LeadtypeDescription = 'CIV-PTF'
where  Passthru <> 0 and leadtype = 'criminal' and Leadtypeid is null and description like '%Civil%'
update InvDetailToNetsuite_Stage set Leadtypeid = 6,LeadtypeDescription = 'CIV-FEE'
where  AdjustedPriceperPackage = 0 and amount =0 and leadtype = 'criminal' and Leadtypeid is null and description like '%Civil%'
--AdjustedPriceperPackage = PrecheckPrice,Frequency = 1   where description <> 'Credit Report' and  Type = 4 and AMOUNT = 0 and InvoiceMonth = @month and InvoiceYear = @year
update InvDetailToNetsuite_Stage set Leadtypeid = 15,LeadtypeDescription = 'CIV-PTF'
where  Passthru = 0 and Amount <>0 and leadtype = 'criminal' and Leadtypeid is null and description like '%Civil%'

update InvDetailToNetsuite_Stage set Leadtypeid = 2,LeadtypeDescription = 'CRIM-FEE'
where  AdjustedPriceperPackage <> 0 and (leadtype = 'criminal' or leadtype = 'Social Search') and Leadtypeid is null 
update InvDetailToNetsuite_Stage set Leadtypeid = 11,LeadtypeDescription = 'CRIM-PTF'
where  Passthru <> 0 and (leadtype = 'criminal' or leadtype = 'Social Search')  and Leadtypeid is null
update InvDetailToNetsuite_Stage set Leadtypeid = 2,LeadtypeDescription = 'CRIM-FEE'
where  AdjustedPriceperPackage = 0 and amount =0 and (leadtype = 'criminal' or leadtype = 'Social Search') and Leadtypeid is null 
update InvDetailToNetsuite_Stage set Leadtypeid = 11,LeadtypeDescription = 'CRIM-PTF'
where  Passthru= 0 and amount <> 0 and (leadtype = 'criminal' or leadtype = 'Social Search')  and Leadtypeid is null


 
update InvDetailToNetsuite_Stage set Leadtypeid = 3,LeadtypeDescription = 'MVR-FEE'
where  AdjustedPriceperPackage <> 0 and leadtype = 'MVR' and Leadtypeid is null 
update InvDetailToNetsuite_Stage set Leadtypeid = 12,LeadtypeDescription = 'MVR-PTF'
where  Passthru <> 0 and leadtype = 'MVR' and Leadtypeid is null 
update InvDetailToNetsuite_Stage set Leadtypeid = 3,LeadtypeDescription = 'MVR-FEE'
where  AdjustedPriceperPackage = 0 and amount =0 and leadtype = 'MVR' and Leadtypeid is null 
update InvDetailToNetsuite_Stage set Leadtypeid = 12,LeadtypeDescription = 'MVR-PTF'
where  Passthru= 0 and amount <> 0 and leadtype = 'MVR' and Leadtypeid is null 

update InvDetailToNetsuite_Stage set Leadtypeid = 4,LeadtypeDescription = 'EMP-FEE'
where  AdjustedPriceperPackage <> 0 and (leadtype = 'Employment' or leadtype = 'Personal Reference') and Leadtypeid is null 
update InvDetailToNetsuite_Stage set Leadtypeid = 13,LeadtypeDescription = 'EMP-PTF'
where  Passthru <> 0 and (leadtype = 'Employment' or leadtype = 'Personal Reference')  and Leadtypeid is null
update InvDetailToNetsuite_Stage set Leadtypeid = 4,LeadtypeDescription = 'EMP-FEE'
where  AdjustedPriceperPackage = 0 and amount =0 and (leadtype = 'Employment' or leadtype = 'Personal Reference') and Leadtypeid is null 
update InvDetailToNetsuite_Stage set Leadtypeid = 13,LeadtypeDescription = 'EMP-PTF'
where  Passthru = 0 and amount <> 0 and (leadtype = 'Employment' or leadtype = 'Personal Reference')  and Leadtypeid is null

update InvDetailToNetsuite_Stage set Leadtypeid = 5,LeadtypeDescription = 'EDU-FEE'
where  AdjustedPriceperPackage <> 0 and (leadtype = 'Education' or leadtype = 'License') and Leadtypeid is null 
update InvDetailToNetsuite_Stage set Leadtypeid = 14,LeadtypeDescription = 'EDU-PTF'
where  Passthru <> 0 and (leadtype = 'Education' or leadtype = 'License')  and Leadtypeid is null
update InvDetailToNetsuite_Stage set Leadtypeid = 5,LeadtypeDescription = 'EDU-FEE'
where  AdjustedPriceperPackage = 0 and amount =0 and (leadtype = 'Education' or leadtype = 'License') and Leadtypeid is null 
update InvDetailToNetsuite_Stage set Leadtypeid = 14,LeadtypeDescription = 'EDU-PTF'
where  Passthru = 0 and amount <> 0 and (leadtype = 'Education' or leadtype = 'License')  and Leadtypeid is null


update InvDetailToNetsuite_Stage set Leadtypeid = 7,LeadtypeDescription = 'OTHER-FEE'
where  AdjustedPriceperPackage <> 0 and (leadtype = 'Sanction Check') and Leadtypeid is null 
update InvDetailToNetsuite_Stage set Leadtypeid = 16,LeadtypeDescription = 'OTHER-PTF'
where  Passthru <> 0 and (leadtype = 'Sanction Check')  and Leadtypeid is null
update InvDetailToNetsuite_Stage set Leadtypeid = 7,LeadtypeDescription = 'OTHER-FEE'
where  AdjustedPriceperPackage = 0 and amount =0 and (leadtype = 'Sanction Check') and Leadtypeid is null 
update InvDetailToNetsuite_Stage set Leadtypeid = 16,LeadtypeDescription = 'OTHER-PTF'
where  Passthru = 0 and amount <> 0 and (leadtype = 'Sanction Check')  and Leadtypeid is null

update InvDetailToNetsuite_Stage set Leadtypeid = 16,LeadtypeDescription = 'OTHER-PTF'
where  Passthru <> 0  and (leadtype  =  'DEMI Passthru')  and Leadtypeid is null


update InvDetailToNetsuite_Stage set Leadtypeid = 8,LeadtypeDescription = 'DRUG-FEE'
where  AdjustedPriceperPackage <> 0 and (leadtype = 'Drug Screening') and Leadtypeid is null 
update InvDetailToNetsuite_Stage set Leadtypeid = 17,LeadtypeDescription = 'DRUG-PTF'
where  Passthru <> 0 and (leadtype = 'Drug Screening')  and Leadtypeid is null
update InvDetailToNetsuite_Stage set Leadtypeid = 8,LeadtypeDescription = 'DRUG-FEE'
where  AdjustedPriceperPackage = 0 and amount =0 and (leadtype = 'Drug Screening') and Leadtypeid is null 
update InvDetailToNetsuite_Stage set Leadtypeid = 17,LeadtypeDescription = 'DRUG-PTF'
where  Passthru = 0 and amount <> 0 and (leadtype = 'Drug Screening')  and Leadtypeid is null

update InvDetailToNetsuite_Stage set Leadtypeid = 9,LeadtypeDescription = 'IMMU-FEE'
where  AdjustedPriceperPackage <> 0 and (leadtype = 'Immunization') and Leadtypeid is null 
update InvDetailToNetsuite_Stage set Leadtypeid = 18,LeadtypeDescription = 'IMMU-PTF'
where  Passthru <> 0 and (leadtype = 'Immunization')  and Leadtypeid is null
update InvDetailToNetsuite_Stage set Leadtypeid = 9,LeadtypeDescription = 'IMMU-FEE'
where  AdjustedPriceperPackage = 0 and amount= 0 and (leadtype = 'Immunization') and Leadtypeid is null 
update InvDetailToNetsuite_Stage set Leadtypeid = 18,LeadtypeDescription = 'IMMU-PTF'
where  Passthru = 0 and amount <> 0 and (leadtype = 'Immunization')  and Leadtypeid is null

update InvDetailToNetsuite_Stage set Leadtypeid = 10,LeadtypeDescription = 'ADMIN-FEE'
where  AdjustedPriceperPackage <> 0 and (leadtype = 'Gen') and Leadtypeid is null 
update InvDetailToNetsuite_Stage set Leadtypeid = 19,LeadtypeDescription = 'ADMIN-PTF'
where  Passthru <> 0 and (leadtype = 'Gen')  and Leadtypeid is null
update InvDetailToNetsuite_Stage set Leadtypeid = 10,LeadtypeDescription = 'ADMIN-FEE'
where  AdjustedPriceperPackage = 0 and amount =0 and (leadtype = 'Gen') and Leadtypeid is null 
update InvDetailToNetsuite_Stage set Leadtypeid = 19,LeadtypeDescription = 'ADMIN-PTF'
where  Passthru = 0 and amount <> 0 and (leadtype = 'Gen')  and Leadtypeid is null


select * from InvDetailToNetsuite_Stage where Leadtypeid in (8,9)

print 'Update Numcase and Numleads  '
--select i1.*,
-- Case when LEADTYPEID in( 2,3,4,5,6,7,8,9) and AdjustedPriceperPackage > 0  then i2.cases else 0 end cases
--,Case when LEADTYPEID in( 2,3,4,5,6,7,8,9) and AdjustedPriceperPackage > 0  then 1 else 0 end as Leads 
 update i1 set Numcase = Case when LEADTYPEID in( 2,3,4,5,6,7,8,9) and isnull(AdjustedPriceperPackage,0) <> 0  then i2.cases else 0 end
 ,Numlead = Case when LEADTYPEID in( 2,3,4,5,6,7,8,9) and isnull(AdjustedPriceperPackage,0) <> 0   then 1 else 0 end
from InvDetailToNetsuite_Stage i1
inner join (select apno,1/cast(sum(Case when LEADTYPEID in( 2,3,4,5,6,7,8,9) and isnull(AdjustedPriceperPackage,0) <> 0   then 1 else 0 end) AS DECIMAL(10,2)) cases from InvDetailToNetsuite_Stage where InvoiceMonth = @month and InvoiceYear = @year
group by apno)  i2
on i1.apno = i2.apno
where --i1.apno = 5307379
--i1.InvoiceNumber = 9308668 
InvoiceMonth = @month and InvoiceYear = @year
--order by i1.apno,leadtypeid
print 'Adjust Package price distribution  '
 --update InvDetailToNetsuite_Stage set AdjustedPriceperPackage = 0 where type = 0 and apno = 5900307

-- Select * into #tempmvr1 from InvDetailToNetsuite_Stage where Description like '%MVR%' and type = 0
-- drop table #tempmvr1
-- Update i set AdjustedPriceperPackage =  i.amount - t.adjprice
--from InvDetailToNetsuite_Stage i inner join 
--(
--select APNO,Sum(case when Amount >0 and type = 0 then 0 else
--case when Amount >0 and type <> 0 and  isnull(AdjustedPriceperPackage,0) > 0 then  isnull(AdjustedPriceperPackage,0) - Amount else isnull(AdjustedPriceperPackage,0) end end) adjprice from [InvDetailToNetsuite_Stage] where InvoiceMonth = 7 and InvoiceYear = 2021
--group by apno) t on i.apno = t.apno
-- where --i.invoicenumber = 9308876 and 
-- type = 0 and leadtypeid is null
-- AND InvoiceMonth = 7 and InvoiceYear = 2021

update [dbo].[InvDetailToNetsuite_Stage] set AdjustedPriceperPackage = 0 where 
description like '%Line%' and description like '%Item%' and amount = 0 and AdjustedPriceperPackage <> 0 and type = 0 and InvoiceMonth = @month and InvoiceYear = @year


Update i set AdjustedPriceperPackage =  i.amount - t.adjprice
from InvDetailToNetsuite_Stage i inner join 
(
select APNO,Sum(case when Amount <>0 and type = 0 then 0 else
case when Amount <>0 and type <> 0 and  isnull(AdjustedPriceperPackage,0) <> 0 then  isnull(AdjustedPriceperPackage,0) - Amount else isnull(AdjustedPriceperPackage,0) end end) adjprice 
from [InvDetailToNetsuite_Stage] where InvoiceMonth = @month and InvoiceYear = @year
group by apno) t on i.apno = t.apno
 where --i.invoicenumber = 9308876 and 
 type = 0 and leadtypeid is null
 AND InvoiceMonth = @month and InvoiceYear = @year


 select case when i.description like 'Criminal Search:%' then SUBSTRING(i.description,17,len(i.description)- 21) else i.description end as CNTY_Desc ,
county,c.CNTY_NO,* 
--Update i set CNTY_NO = c.CNTY_NO
from [dbo].[InvDetailToNetsuite_Stage] i
inner join crim c on i.apno = c.apno 
and ltrim(rtrim(case when i.description like 'Criminal Search:%' then SUBSTRING(i.description,17,len(i.description)- 21) else i.description end)) = ltrim(rtrim(c.County))
where type = 2

Update i set CNTY_NO = c.CNTY_NO
from [dbo].[InvDetailToNetsuite_Stage] i
inner join crim c on i.apno = c.apno 
and ltrim(rtrim(case when i.description like 'Criminal Search:%' then SUBSTRING(i.description,17,len(i.description)- 21) else i.description end)) = ltrim(rtrim(c.County))
where type = 2
 end
 else
  print 'No need to Fill the data from Invoice Deatil tables'
 end

 update [dbo].[InvDetailToNetsuite_Stage] set Passthru = 0.00 where Passthru is null
  update [dbo].[InvDetailToNetsuite_Stage] set AdjustedPriceperPackage = 0.00 where AdjustedPriceperPackage is null
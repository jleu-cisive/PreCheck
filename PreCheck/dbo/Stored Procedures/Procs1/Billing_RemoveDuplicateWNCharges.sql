-- =============================================
-- Author:		kiran miryala
-- Create date: 05/02/2022
-- Description:	Billing- to remove duplicate Work number pass thru charges from SJV , actually to add negitive amount to invdetail table.
-- =============================================
CREATE PROCEDURE [dbo].[Billing_RemoveDuplicateWNCharges]
	
AS
BEGIN
-- 
--step 1 get all WN charges which are not billed yet
DROP TABLE IF EXISTS #tempWN;
select * into #tempWN from invdetail where InvoiceNumber is null  --in (select InvoiceNumber from #tempInvmaster)
and billed = 0
and description = 'Employment:The Work Number'
--like '%Work Number%' 

select * from #tempWN order by apno

--setp 2  -- remove Negitive charges
delete invdetail where invdetID in (select invdetID from #tempWN  where Amount < 0)
delete  #tempWN  where Amount < 0

-- step 3  get all Positive pass thru charges
DROP TABLE IF EXISTS #tempWorknumber;
Select * into #tempWorknumber from (
select * from #tempWN where amount > 0
--union all
--select *  from invdetail where InvoiceNumber in (select InvoiceNumber from #tempInvmaster) and amount = 39.14
--and invdetid not in (select invdetid from #tempWN where amount = 39.14)
) t


select * from #tempWorknumber --where amount < 0
order  by APNO

-- step 4  get all duplicate APNO's where there is Positive pass thru charges
DROP TABLE IF EXISTS #tempDupWNCharges;
select Apno into #tempDupWNCharges from #tempWorknumber where Amount > 0
group by apno
having count(apno) > 1 


-- step 5  get all Detail id  where Passthru needs to be present
DROP TABLE IF EXISTS #TempStayWNcharges;
select Apno,min(Invdetid) as Invdetid  into #TempStayWNcharges from #tempWorknumber
 where apno in (select apno from #tempDupWNCharges) and Amount > 0 
 group by apno

select * from #tempWorknumber
where apno in (select apno from #tempDupWNCharges) and Amount > 0 
and Invdetid not in (select Invdetid from #TempStayWNcharges)

select * from #tempWorknumber where amount < 0
--delete invdetail where InvDetID in (Select InvDetID from #tempWorknumber where amount < 0)
--select * from #tempWorknumber where amount < 0 order by apno 

-- step 6  Insert Negitive charge so the duplicate charge will be nagated
INSERT INTO [dbo].[InvDetail]
           ([APNO]           ,[Type]           ,[Subkey]           ,[SubKeyChar]           ,[Billed]           ,[InvoiceNumber]
           ,[CreateDate]           ,[Description]           ,[Amount])
		   select [APNO]           ,[Type]           ,[Subkey]           ,[SubKeyChar]           ,[Billed]           ,[InvoiceNumber]
           ,[CreateDate]           ,[Description]           ,-[Amount]
		   from #tempWorknumber
where apno in (select apno from #tempDupWNCharges) and Amount > 0 
and Invdetid not in (select Invdetid from #TempStayWNcharges)

end
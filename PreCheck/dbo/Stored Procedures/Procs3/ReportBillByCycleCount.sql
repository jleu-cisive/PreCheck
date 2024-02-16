

CREATE PROCEDURE [dbo].[ReportBillByCycleCount]
@FirstOfMonth datetime = null,
@BillCycleID int

 AS

Declare @StartDate datetime
Declare @EndDate datetime

Set @StartDate =  DATEADD(day, 15, @FirstOfMonth)
Set @EndDate =  DATEADD(day, 45, @FirstOfMonth)

if(@BillCycleID=0)--select All for cycle
begin
Select CLNO,Name,sum(acount) acount,sum(ecount) ecount, sum(edcount) edcount, sum(ccount) ccount, sum(rcount) rcount from
(
SELECT     im.CLNO, c.Name,   count(distinct ivd.Apno) acount,0 ecount, 0 edcount, 0 ccount, 0 rcount
FROM         InvMaster im
		INNER JOIN InvDetail ivd ON im.InvoiceNumber = ivd.InvoiceNumber 
		INNER JOIN Client c ON im.CLNO = c.CLNO		
WHERE     (ivd.Billed = 1) AND (im.InvDate > @StartDate) 
		AND (im.InvDate < @EndDate)
group by im.clno, c.name
union all
--=================get count from empl.tb
SELECT     im.CLNO, c.Name, 0 acount,   count(distinct ivd.Apno) ecount, 0 edcount, 0 ccount, 0 rcount
FROM         InvMaster im
		INNER JOIN InvDetail ivd ON im.InvoiceNumber = ivd.InvoiceNumber 
		INNER JOIN Client c ON im.CLNO = c.CLNO
		INNER JOIN empl e ON ivd.APNO = e.Apno	
WHERE     (ivd.Billed = 1) AND (im.InvDate > @StartDate) 
		AND (im.InvDate < @EndDate) AND e.IsHidden = 0 AND e.IsOnReport = 1
group by im.clno, c.name

--=================get count from educat.tb
union all
SELECT     im.CLNO, c.Name, 0 acount,  0 ecount, count(distinct ivd.Apno) edcount, 0 ccount, 0 rcount
FROM         InvMaster im
		INNER JOIN InvDetail ivd ON im.InvoiceNumber = ivd.InvoiceNumber 
		INNER JOIN Client c ON im.CLNO = c.CLNO
		INNER JOIN educat e ON ivd.APNO = e.Apno	
WHERE     (ivd.Billed = 1) AND (im.InvDate > @StartDate) 
		AND (im.InvDate < @EndDate) AND e.IsHidden = 0 AND e.IsOnReport = 1
group by im.clno, c.name
--==================get count from crim.tb

union all
SELECT     im.CLNO, c.Name, 0 acount,  0 ecount, 0 edcount, count(distinct ivd.Apno) ccount, 0 rcount
FROM         InvMaster im
		INNER JOIN InvDetail ivd ON im.InvoiceNumber = ivd.InvoiceNumber 
		INNER JOIN Client c ON im.CLNO = c.CLNO
		INNER JOIN crim e ON ivd.APNO = e.Apno	
WHERE     (ivd.Billed = 1) AND (im.InvDate > @StartDate) 
		AND (im.InvDate < @EndDate) AND e.IsHidden = 0 
group by im.clno, c.name
--==================get count from proflic.tb

union all
SELECT     im.CLNO, c.Name, 0 acount,  0 ecount, 0 edcount, 0 ccount, count(distinct ivd.Apno) rcount
FROM         InvMaster im
		INNER JOIN InvDetail ivd ON im.InvoiceNumber = ivd.InvoiceNumber 
		INNER JOIN Client c ON im.CLNO = c.CLNO
		INNER JOIN proflic e ON ivd.APNO = e.Apno	
WHERE     (ivd.Billed = 1) AND (im.InvDate > @StartDate) 
		AND (im.InvDate < @EndDate) AND e.IsHidden = 0 AND e.IsOnReport = 1
group by im.clno, c.name
--==========================
) SubQry
group by CLNO,Name
order by clno
end
else
begin
Select CLNO,Name,sum(acount) acount,sum(ecount) ecount, sum(edcount) edcount, sum(ccount) ccount, sum(rcount) rcount from
(
SELECT     im.CLNO, c.Name,   count(distinct ivd.Apno) acount,0 ecount, 0 edcount, 0 ccount, 0 rcount
FROM         InvMaster im
		INNER JOIN InvDetail ivd ON im.InvoiceNumber = ivd.InvoiceNumber 
		INNER JOIN Client c ON im.CLNO = c.CLNO		
WHERE     (ivd.Billed = 1) AND (im.InvDate > @StartDate) 
		AND (im.InvDate < @EndDate) AND (c.BillingCycleID = @BillCycleID)
group by im.clno, c.name
union all
--=================get count from empl.tb
SELECT     im.CLNO, c.Name, 0 acount,   count(distinct ivd.Apno) ecount, 0 edcount, 0 ccount, 0 rcount
FROM         InvMaster im
		INNER JOIN InvDetail ivd ON im.InvoiceNumber = ivd.InvoiceNumber 
		INNER JOIN Client c ON im.CLNO = c.CLNO
		INNER JOIN empl e ON ivd.APNO = e.Apno	
WHERE     (ivd.Billed = 1) AND (im.InvDate > @StartDate) 
		AND (im.InvDate < @EndDate) AND (c.BillingCycleID = @BillCycleID) AND e.IsHidden = 0 AND e.IsOnReport = 1
group by im.clno, c.name

--=================get count from educat.tb
union all
SELECT     im.CLNO, c.Name, 0 acount,  0 ecount, count(distinct ivd.Apno) educount, 0 ccount, 0 rcount
FROM         InvMaster im
		INNER JOIN InvDetail ivd ON im.InvoiceNumber = ivd.InvoiceNumber 
		INNER JOIN Client c ON im.CLNO = c.CLNO
		INNER JOIN educat e ON ivd.APNO = e.Apno	
WHERE     (ivd.Billed = 1) AND (im.InvDate > @StartDate) 
		AND (im.InvDate < @EndDate) AND (c.BillingCycleID = @BillCycleID) AND e.IsHidden = 0 AND e.IsOnReport = 1
group by im.clno, c.name
--==================get count from crim.tb

union all
SELECT     im.CLNO, c.Name, 0 acount,  0 ecount, 0 edcount, count(distinct ivd.Apno) ccount, 0 rcount
FROM         InvMaster im
		INNER JOIN InvDetail ivd ON im.InvoiceNumber = ivd.InvoiceNumber 
		INNER JOIN Client c ON im.CLNO = c.CLNO
		INNER JOIN crim e ON ivd.APNO = e.Apno	
WHERE     (ivd.Billed = 1) AND (im.InvDate > @StartDate) 
		AND (im.InvDate < @EndDate) AND (c.BillingCycleID = @BillCycleID) AND e.IsHidden = 0
group by im.clno, c.name
--==================get count from proflic.tb

union all
SELECT     im.CLNO, c.Name, 0 acount,  0 ecount, 0 edcount, 0 ccount, count(distinct ivd.Apno) rcount
FROM         InvMaster im
		INNER JOIN InvDetail ivd ON im.InvoiceNumber = ivd.InvoiceNumber 
		INNER JOIN Client c ON im.CLNO = c.CLNO
		INNER JOIN proflic e ON ivd.APNO = e.Apno	
WHERE     (ivd.Billed = 1) AND (im.InvDate > @StartDate) 
		AND (im.InvDate < @EndDate) AND (c.BillingCycleID = @BillCycleID) AND e.IsHidden = 0 AND e.IsOnReport = 1
group by im.clno, c.name
--==========================
) SubQry
group by CLNO,Name
order by clno
end



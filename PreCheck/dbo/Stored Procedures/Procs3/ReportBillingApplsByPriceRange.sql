
-- finds appls from a particular billing month with prices in some range
--  provide the first day of the billing period
-- JS 12/29/2005  updated below to include first,last and ssn of applicant
CREATE PROCEDURE dbo.ReportBillingApplsByPriceRange 
@FirstOfMonth datetime = null,
@LowerLimit money,
@UpperLimit money
AS

Declare @StartDate datetime
Declare @EndDate datetime

Set @StartDate =  DATEADD(day, 15, @FirstOfMonth)
Set @EndDate =  DATEADD(day, 45, @FirstOfMonth)


   if (@FirstOfMonth is not null)
   BEGIN 
    select appl.CLNO, tblPriceRangeSum.Name, Appl.APNO, Appl.[First], Appl.[Last], Appl.SSN,Total
    from appl
    inner join
    (
        SELECT   client.clno,client.name,dbo.Appl.APNO,sum(invdetail.amount) as Total
         FROM      Appl INNER JOIN
         InvDetail ON Appl.APNO = InvDetail.APNO INNER JOIN
         Client ON Appl.CLNO = Client.CLNO
         WHERE (InvDetail.CreateDate >= @Startdate  AND InvDetail.CreateDate <= @EndDate)
         GROUP BY Client.CLNO,client.name,Appl.APNO
        )as tblPriceRangeSum
         on appl.apno = tblPriceRangeSum.apno
         where (tblPriceRangeSum.Total >= @LowerLimit and tblPriceRangeSum.Total <= @UpperLimit)
   order by Total
   END
   ELSE
   Begin
       SELECT appl.CLNO, tblPriceRangeSum.Name, Appl.APNO, Appl.[First], Appl.[Last], Appl.SSN,Total
       from appl
       inner join
    (
       SELECT   client.clno,client.name,dbo.Appl.APNO,sum(invdetail.amount) as Total
        FROM      Appl INNER JOIN
        InvDetail ON Appl.APNO = InvDetail.APNO INNER JOIN
        Client ON Appl.CLNO = Client.CLNO
        WHERE (invdetail.invoicenumber is null and invdetail.createdate > '1/1/1998')
        GROUP BY Client.CLNO,client.name,Appl.APNO
    )as tblPriceRangeSum
       on appl.apno = tblPriceRangeSum.apno
     where (tblPriceRangeSum.Total >= @LowerLimit and tblPriceRangeSum.Total <= @UpperLimit)
      order by Total
   END





--if(@Invoiced) BEGIN --Based on Invoice Date
--SELECT a.APNO, c.clno, c.name, sum(Amount) as SumAmount FROM invdetail i
--  join Appl a ON a.APNO=i.APNO
--  join Client c ON c.clno=a.clno
--  join InvMaster m on m.InvoiceNumber = i.InvoiceNumber
-- WHERE InvDate > = @StartDate and InvDate < @EndDate
-- GROUP BY a.APNO,c.clno, c.name
-- HAVING sum(Amount) > @LowerLimit and sum(Amount) < @UpperLimit 
--ORDER BY c.name
--END
--ELSE
--BEGIN --For items that are not yet invoiced
----------------- 12/31/2005 Commented out Below  JS for update query above
--SELECT a.APNO, c.clno, c.name, sum(Amount) as SumAmount FROM invdetail i
--  join Appl a ON a.APNO=i.APNO
--  join Client c ON c.clno=a.clno
--  join InvMaster m on m.InvoiceNumber = i.InvoiceNumber
-- WHERE InvDate > = @StartDate and InvDate < @EndDate
-- WHERE InvoiceNumber is null
-- GROUP BY a.APNO,c.clno, c.name
-- HAVING sum(Amount) > @LowerLimit and sum(Amount) < @UpperLimit 
--ORDER BY c.name
--END

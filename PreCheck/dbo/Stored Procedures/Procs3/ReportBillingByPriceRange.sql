CREATE PROCEDURE dbo.ReportBillingByPriceRange 
    @year INT = 0, 
    @month INT = 0,
    @HighPrice money,
    @LowPrice money
AS 
   if (@Month <> 0 and @Year <> 0)
   BEGIN 
    select appl.CLNO, tblPriceRangeSum.Name, Appl.APNO, Appl.[First], Appl.[Last], Appl.SSN,myamount
    from appl
    inner join
    (
        SELECT   client.clno,client.name,dbo.Appl.APNO,sum(invdetail.amount) as myamount
         FROM      Appl INNER JOIN
         InvDetail ON Appl.APNO = InvDetail.APNO INNER JOIN
         Client ON Appl.CLNO = Client.CLNO
         WHERE (YEAR(dbo.InvDetail.CreateDate) = @Year) AND (MONTH(InvDetail.CreateDate) = @month)
          
         GROUP BY Client.CLNO,client.name,Appl.APNO
        )as tblPriceRangeSum
         on appl.apno = tblPriceRangeSum.apno
         where tblPriceRangeSum.myamount >= @HighPrice and tblPriceRangeSum.myamount <= @LowPrice
   order by myamount
   END
   ELSE
   Begin
       SELECT appl.CLNO, tblPriceRangeSum.Name, Appl.APNO, Appl.[First], Appl.[Last], Appl.SSN,myamount
       from appl
       inner join
    (
       SELECT   client.clno,client.name,dbo.Appl.APNO,sum(invdetail.amount) as myamount
        FROM      Appl INNER JOIN
        InvDetail ON Appl.APNO = InvDetail.APNO INNER JOIN
        Client ON Appl.CLNO = Client.CLNO
        WHERE (invdetail.invoicenumber is null and invdetail.createdate > '1/1/1998')
        GROUP BY Client.CLNO,client.name,Appl.APNO
    )as tblPriceRangeSum
       on appl.apno = tblPriceRangeSum.apno
      order by myamount
   END


/*    select appl.CLNO,client.Name,appl.apdate, dbo.Appl.APNO, dbo.Appl.[First], dbo.Appl.[Last], dbo.Appl.SSN
    from appl 
    inner join client
    on appl.clno = client.clno
    where exists
    (SELECT distinct apno from invdetail
    where appl.apno = invdetail.apno
    and invdetail.invoicenumber is null and createdate > '1/1/1998')
    order by appl.clno
   End
*/
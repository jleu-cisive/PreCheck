CREATE PROCEDURE [Bis3_OnAssignment] @BegDate varchar(12),@EndDate varchar(12)  AS
 

--@BegDate will always have a day of 15, 
--@EndDate will add 1 month and 15 to Enddate


SELECT    invdate,Last, First, a.APNO, Description, Amount,c.addr1,c.city,c.state,c.zip,c.name,m.invoicenumber,c.clno
   FROM InvDetail d
    JOIN InvMaster m ON d.InvoiceNumber = m.InvoiceNumber
    JOIN Appl a ON a.apno=d.apno
   join Client c on c.clno = a.clno
  Where (InvDate between @BegDate and @EndDate) and  (c.name like '%On Assignment%')
order by d.apno
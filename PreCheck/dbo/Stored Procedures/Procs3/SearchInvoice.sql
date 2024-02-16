CREATE procedure [dbo].[SearchInvoice]
(
@CLNO varchar(6) = '',
@clientName VARCHAR(MAX) = NULL,
@invNumber varchar(50) = '',
@invDate VARCHAR(100) = NULL
)
as
begin
select c.CLNO,c.Name,i.InvDate as InvDate,i.InvoiceNumber,i.Sale 
from InvMaster as i join Client as c on i.CLNO = c.CLNO 
where ((@CLNO is not null and c.clno = @CLNO) or (@CLNO is null or @CLNO = ''))
and ((@clientName is not null and @clientName <>'' and c.Name like '%' + @clientName +'%') or (@clientName is null or @clientName = ''))
--and ((@clientName is not null and @clientName <>'' and c.Name = @clientName) or (@clientName is null or @clientName = ''))
and ((@invDate is not null and @invDate <>'' and YEAR(i.invDate) = @invDate) or (@invDate is null or @invDate = ''))
and ((@invNumber is not null and @invNumber <>'' and i.InvoiceNumber = @invNumber) or (@invNumber is null or @invNumber = ''))

end
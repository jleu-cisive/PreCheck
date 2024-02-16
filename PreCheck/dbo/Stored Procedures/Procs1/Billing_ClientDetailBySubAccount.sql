-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Billing_ClientDetailBySubAccount]
	@CLNO int,@InvoiceNumber int
AS
BEGIN
	

SET ANSI_WARNINGS ON
SET ARITHABORT ON

--select i.apno,i.invoicenumber,ii.invdate,(select isnull(first,'') + ' ' + isnull(middle,'') + ' ' + isnull(last,'') from appl where apno = a.apno) as Name,(select apdate from appl where apno = a.apno) as ApDate,i.description,i.amount,a.xmld.value('(/ClientMeta/GL_SITE)[1]', 'varchar(20)') as siteid from invdetail i with (nolock) inner join
--applclientdata a with (nolock) on i.apno = a.apno
--inner join invmaster ii with (nolock) on i.invoicenumber = ii.invoicenumber
--where a.clno =@CLNO and i.billed = 1 and i.invoicenumber = @InvoiceNumber
--order by siteid,i.apno

select i.apno,i.invoicenumber,ii.invdate,(select isnull(last,'') + ', ' + isnull(first,'') + ' ' + isnull(middle,'') from appl where apno = a.apno) as Name,(select apdate from appl where apno = a.apno) as ApDate,i.description,i.amount,isnull(a.xmld.value('(/ClientMeta/PRACTICE_DESC)[1]', 'varchar(100)'),'Unknown') + '(' + isnull(a.xmld.value('(/ClientMeta/PRACTICE_CODE)[1]', 'varchar(50)'),'Unknown') + ')' as siteid
 from invdetail i with (nolock) inner join
applclientdata a with (nolock) on i.apno = a.apno
inner join invmaster ii with (nolock) on i.invoicenumber = ii.invoicenumber
inner join appl aa with (nolock) on a.apno = aa.apno
where 
a.xmld.value('(/ClientMeta/PRACTICE_CODE)[1]', 'varchar(20)') is not null and a.clno =@CLNO and i.billed = 1 and i.invoicenumber = @InvoiceNumber
union all
select i.apno,i.invoicenumber,ii.invdate,(select isnull(last,'') + ', ' + isnull(first,'') + ' ' + isnull(middle,'') from appl where apno = a.apno) as Name,(select apdate from appl where apno = a.apno) as ApDate,i.description,i.amount,isnull(a.xmld.value('(/ClientMeta/PRACTICE_DESC)[1]', 'varchar(100)'),'') + '(' + isnull(a.xmld.value('(/CustomClientData/ClientData3)[1]', 'varchar(50)'),'Unknown') + ')' as siteid
 from invdetail i with (nolock) inner join
applclientdata a with (nolock) on i.apno = a.apno
inner join invmaster ii with (nolock) on i.invoicenumber = ii.invoicenumber
inner join appl aa with (nolock) on a.apno = aa.apno
where 
a.xmld.value('(/CustomClientData/ClientData3)[1]', 'varchar(20)') is not null and 
a.clno =@CLNO and i.billed = 1 and i.invoicenumber = @InvoiceNumber

order by siteid--,last,first

END

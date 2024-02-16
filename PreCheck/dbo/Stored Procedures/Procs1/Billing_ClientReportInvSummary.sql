
--[Billing_ClientReportInvSummary]  6977,1,'7/1/2014'
--
--[Billing_ClientReportInvSummary]  6977,2,'7/1/2014'
--<CustomClientData><ClientData1>219796</ClientData1><ClientData2>HR047</ClientData2><ClientData3>NY33</ClientData3><ClientData4 /></CustomClientData>

-- =============================================
-- Author:		<schapyala>
-- Create date: <07/01/2014>
-- Description:	<USON Billing Data Files>
-- =============================================
CREATE PROCEDURE [dbo].[Billing_ClientReportInvSummary] 
	-- Add the parameters for the stored procedure here
	@CLNO int,@SPMODE int,@DATEREF datetime
AS
BEGIN

SET ANSI_WARNINGS ON
SET ARITHABORT ON

DECLARE @invoicenumber int;

set @invoicenumber = (select invoicenumber from invmaster
 where invdate = (select max(invdate) from invmaster where clno = @CLNO) and clno = @clno);

--set @invoicenumber = 9133017
--select @invoicenumber

IF(@SPMODE = 1) -- Summary
BEGIN

select distinct i.apno as requestid,
ClientPackageCode as packagecode,
isnull(first,'') + ' ' + isnull(last,'') as ApplicantName,
a.xmld.value('(/CustomClientData/ClientData1)[1]', 'varchar(50)') as RequestorID,
a.xmld.value('(/CustomClientData/ClientData2)[1]', 'varchar(30)') as PositionID,
a.xmld.value('(/CustomClientData/ClientData3)[1]', 'varchar(20)') as LocationCode,
(select sum(amount) from invdetail where apno = a.apno and billed = 1 and invoicenumber = @invoicenumber) as Total,
Round(((select sum(amount) from invdetail where apno = a.apno and billed = 1 and invoicenumber = @invoicenumber) * cast(.0825 as smallmoney)),2) As Tax
--,i.apno,i.invoicenumber,ii.invdate,i.description,i.amount
 from dbo.invdetail i with (nolock) inner join
dbo.applclientdata a with (nolock) on i.apno = a.apno 
inner join dbo.invmaster ii with (nolock) on i.invoicenumber = ii.invoicenumber
inner join dbo.appl (nolock) on i.apno = appl.Apno
inner join dbo.ClientPackages cp (nolock) on cp.PackageID = appl.PackageID  
where 
a.clno = @CLNO  and 
i.billed = 1 and ii.invoicenumber = @invoicenumber
--and a.CreatedDate > '5/18/2014'
and ClientPackageCode is not null
order by LocationCode,requestid
END

IF(@SPMODE = 2) -- Detail
BEGIN


select i.apno as requestid,
ClientPackageCode as packagecode,
isnull(first,'') + ' ' + isnull(last,'') as ApplicantName,
a.xmld.value('(/CustomClientData/ClientData1)[1]', 'varchar(50)') as RequestorID,
a.xmld.value('(/CustomClientData/ClientData2)[1]', 'varchar(30)') as PositionID,
a.xmld.value('(/CustomClientData/ClientData3)[1]', 'varchar(20)') as LocationCode,
case when (i.description like 'Education%')and i.type = 1 then '1a'
when (i.description like 'Employment%' or i.description like 'work%') and i.type = 1 then '1b'
when i.description like 'License%' and i.type = 1 then '1c'
when i.description like '%service charge%' and i.type = 2 then '2b'
when i.type = 2 then '2a'
else cast(i.type as varchar(5)) end as type,i.description,
case when i.type = 1 then '1' when i.description like '%service charge%' and i.type = 2 then '1' else 0 end As AddOnFee,
i.amount
 from dbo.invdetail i with (nolock) inner join
dbo.applclientdata a with (nolock) on i.apno = a.apno
inner join dbo.invmaster ii with (nolock) on i.invoicenumber = ii.invoicenumber
inner join dbo.appl (nolock) on i.apno = appl.Apno
inner join dbo.ClientPackages cp (nolock) on cp.PackageID = appl.PackageID  
where 
a.clno = @CLNO and 
i.billed = 1 and ii.invoicenumber = @invoicenumber
--and a.CreatedDate > '5/18/2014'
and ClientPackageCode is not null
UNION ALL
--TAX ITEMS
select 
distinct i.apno as requestid,
ClientPackageCode as packagecode,
isnull(first,'') + ' ' + isnull(last,'') as ApplicantName,
a.xmld.value('(/CustomClientData/ClientData1)[1]', 'varchar(50)') as RequestorID,
a.xmld.value('(/CustomClientData/ClientData2)[1]', 'varchar(30)') as PositionID,
a.xmld.value('(/CustomClientData/ClientData3)[1]', 'varchar(20)') as LocationCode,
'99' as type,'Tax Amount',
0 As AddOnFee,
Round(((select sum(amount) from invdetail where apno = a.apno and billed = 1 and invoicenumber = @invoicenumber) * cast(.0825 as smallmoney)),2) As Tax

 from dbo.invdetail i with (nolock) inner join
dbo.applclientdata a with (nolock) on i.apno = a.apno
inner join dbo.invmaster ii with (nolock) on i.invoicenumber = ii.invoicenumber
inner join dbo.appl (nolock) on i.apno = appl.Apno
inner join dbo.ClientPackages cp (nolock) on cp.PackageID = appl.PackageID  
where 
a.clno = @CLNO  and 
i.billed = 1 and ii.invoicenumber = @invoicenumber
--and a.CreatedDate > '5/18/2014'
and ClientPackageCode is not null
order by LocationCode,requestid

END

END












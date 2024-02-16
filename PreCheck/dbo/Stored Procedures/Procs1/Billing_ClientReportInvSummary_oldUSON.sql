


---Sunitha Sukumaran

--[Billing_ClientReportInvSummary]  6977,1,'11/1/2013'
--
--[Billing_ClientReportInvSummary]  6977,2,'11/1/2013'
--<CustomClientData><ClientData1>219796</ClientData1><ClientData2>HR047</ClientData2><ClientData3>NY33</ClientData3><ClientData4 /></CustomClientData>

--<ClientMeta><Package_Code>PKPGS1</Package_Code><RowHeader>10</RowHeader><REQUEST_ID>119852</REQUEST_ID><APPLICANT_ID>117801</APPLICANT_ID><BGC_OWNER> (TUCKL)</BGC_OWNER><PRACTICE_OWNER>Martin,Ian G(207769)</PRACTICE_OWNER>
--<PRACTICE_OWNER_PHONE>281/863-4761</PRACTICE_OWNER_PHONE><PRACTICE_OWNER_EMAIL>Ian.Martin@USONCOLOGY.COM</PRACTICE_OWNER_EMAIL><PRACTICE_CODE>HR065</PRACTICE_CODE><PRACTICE_DESC>TX-US Oncology Inc</PRACTICE_DESC>
--<LOCATION_CODE>CORP</LOCATION_CODE><LOCATION_DESC>TX01</LOCATION_DESC><LOCATION_CITY>US Oncology Headquarters</LOCATION_CITY><LOCATION_STATE>The Woodlands</LOCATION_STATE><GL_BUSINESS_UNIT>TX</GL_BUSINESS_UNIT>
--<GL_SITE>90003</GL_SITE><a15>0001</a15></ClientMeta>



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Billing_ClientReportInvSummary_oldUSON] 
	-- Add the parameters for the stored procedure here
	@CLNO int,@SPMODE int,@DATEREF datetime
AS
BEGIN

SET ANSI_WARNINGS ON
SET ARITHABORT ON

DECLARE @invoicenumber int;

set @invoicenumber = (select invoicenumber from invmaster
 where invdate = (select max(invdate) from invmaster where clno = @CLNO) and clno = @clno);

--set @invoicenumber = 9114466
--select @invoicenumber

IF(@SPMODE = 1)
BEGIN

select distinct a.xmld.value('(/ClientMeta/REQUEST_ID)[1]', 'varchar(20)') as requestid,
(select top 1 packagecode from applclientdatahistory with (nolock) where apno = a.apno) as packagecode,
(select isnull(first,'') + ' ' + isnull(last,'') from appl with (nolock) where apno = a.apno) as ApplicantName,
--(select REPLACE(ssn,'-','') from appl with (nolock) where apno = a.apno) as ApplicantSSN,
--a.xmld.value('(/ClientMeta/APPLICANT_ID)[1]', 'varchar(20)') as ApplicantID,
a.xmld.value('(/ClientMeta/PRACTICE_OWNER)[1]', 'varchar(50)') as RequestorID,
a.xmld.value('(/ClientMeta/GL_SITE)[1]', 'varchar(30)') as BusinessUnit,
a.xmld.value('(/ClientMeta/a15)[1]', 'varchar(20)') as siteid,
(select sum(amount) from invdetail where apno = a.apno and billed = 1 and invoicenumber = @invoicenumber) as Total,
Round(((select sum(amount) from invdetail where apno = a.apno and billed = 1 and invoicenumber = @invoicenumber) * cast(.0825 as smallmoney)),2) As Tax
--,i.apno,i.invoicenumber,ii.invdate,i.description,i.amount
 from invdetail i with (nolock) inner join
applclientdata a with (nolock) on i.apno = a.apno
inner join invmaster ii with (nolock) on i.invoicenumber = ii.invoicenumber
where --a.requestid is not null and 
a.xmld.value('(/ClientMeta/REQUEST_ID)[1]', 'varchar(20)') is not null and 
a.clno = @CLNO and ii.clno = @CLNO and 
i.billed = 1 and ii.invoicenumber = @invoicenumber
--and a.CreatedDate < '5/18/2014'

--[Billing_ClientReportInvSummary]  6977,2,'6/1/2014'

union all
select --distinct a.xmld.value('(/CustomClientData/ClientData1)[1]', 'varchar(20)') as requestid,
distinct i.apno as requestid,
--(select top 1 packagecode from applclientdatahistory with (nolock) where apno = a.apno) as packagecode,
(SELECT    ClientPackageCode FROM            dbo.ClientPackages cp inner join Appl A on cp.PackageID = a.PackageID  
    where apno = i.apno  and ClientPackageCode is not null ) as packagecode,
(select isnull(first,'') + ' ' + isnull(last,'') from appl with (nolock) where apno = a.apno) as ApplicantName,
--(select REPLACE(ssn,'-','') from appl with (nolock) where apno = a.apno) as ApplicantSSN,
--a.xmld.value('(/ClientMeta/APPLICANT_ID)[1]', 'varchar(20)') as ApplicantID,
a.xmld.value('(/CustomClientData/ClientData1)[1]', 'varchar(50)') as RequestorID,
a.xmld.value('(/CustomClientData/ClientData2)[1]', 'varchar(30)') as BusinessUnit,
a.xmld.value('(/CustomClientData/ClientData3)[1]', 'varchar(20)') as siteid,
(select sum(amount) from invdetail where apno = a.apno and billed = 1 and invoicenumber = @invoicenumber) as Total,
Round(((select sum(amount) from invdetail where apno = a.apno and billed = 1 and invoicenumber = @invoicenumber) * cast(.0825 as smallmoney)),2) As Tax
--,i.apno,i.invoicenumber,ii.invdate,i.description,i.amount
 from invdetail i with (nolock) inner join
applclientdata a with (nolock) on i.apno = a.apno 
inner join invmaster ii with (nolock) on i.invoicenumber = ii.invoicenumber
where --a.requestid is not null and 
a.xmld.value('(/CustomClientData/ClientData1)[1]', 'varchar(20)') is not null and 
a.clno = @CLNO and ii.clno = @CLNO and 
i.billed = 1 and ii.invoicenumber = @invoicenumber
--and a.CreatedDate < '5/18/2014'

order by siteid,requestid
END

IF(@SPMODE = 2)
BEGIN

--select  a.xmld.value('(/ClientMeta/REQUEST_ID)[1]', 'varchar(20)') as requestid,
--(select top 1 packagecode from applclientdatahistory with (nolock) where apno = a.apno) as packagecode,
--(select isnull(first,'') + ' ' + isnull(last,'') from appl with (nolock) where apno = a.apno) as ApplicantName,
----(select REPLACE(ssn,'-','') from appl with (nolock) where apno = a.apno) as ApplicantSSN,
----a.xmld.value('(/ClientMeta/APPLICANT_ID)[1]', 'varchar(20)') as ApplicantID,
--a.xmld.value('(/ClientMeta/PRACTICE_OWNER)[1]', 'varchar(50)') as RequestorID,
--a.xmld.value('(/ClientMeta/GL_SITE)[1]', 'varchar(30)') as BusinessUnit,
--a.xmld.value('(/ClientMeta/a15)[1]', 'varchar(20)') as siteid,
--case when (i.description like 'Education%')and i.type = 1 then '1a'
--when (i.description like 'Employment%' or i.description like 'work%') and i.type = 1 then '1b'
--when i.description like 'License%' and i.type = 1 then '1c'
--when i.description like '%service charge%' and i.type = 2 then '2b'
--when i.type = 2 then '2a'
--else cast(i.type as varchar(5)) end as type,i.description,
--case when i.type = 1 then '1' when i.description like '%service charge%' and i.type = 2 then '1' else 0 end As AddOnFee,
--i.amount
-- from invdetail i with (nolock) inner join
--applclientdata a with (nolock) on i.apno = a.apno
--inner join invmaster ii with (nolock) on i.invoicenumber = ii.invoicenumber
--where 
--a.xmld.value('(/ClientMeta/REQUEST_ID)[1]', 'varchar(20)') is not null and 
--a.clno = @CLNO and ii.clno = @CLNO and 
--i.billed = 1 and ii.invoicenumber = @invoicenumber
--UNION ALL
----TAX ITEMS
--select 
--distinct a.xmld.value('(/ClientMeta/REQUEST_ID)[1]', 'varchar(20)') as requestid,
--(select top 1 packagecode from applclientdatahistory with (nolock) where apno = a.apno) as packagecode,
--(select isnull(first,'') + ' ' + isnull(last,'') from appl with (nolock) where apno = a.apno) as ApplicantName,
--a.xmld.value('(/ClientMeta/APPLICANT_ID)[1]', 'varchar(20)') as ApplicantID,
--a.xmld.value('(/ClientMeta/PRACTICE_OWNER)[1]', 'varchar(50)') as RequestorID,
--a.xmld.value('(/ClientMeta/GL_SITE)[1]', 'varchar(30)') as BusinessUnit,
--a.xmld.value('(/ClientMeta/a15)[1]', 'varchar(20)') as siteid,
--'99' as type,'Tax Amount',
--0 As AddOnFee,
--Round(((select sum(amount) from invdetail where apno = a.apno and billed = 1 and invoicenumber = @invoicenumber) * cast(.0825 as smallmoney)),2) As Tax

-- from invdetail i with (nolock) inner join
--applclientdata a with (nolock) on i.apno = a.apno
--inner join invmaster ii with (nolock) on i.invoicenumber = ii.invoicenumber
--where
--a.xmld.value('(/ClientMeta/REQUEST_ID)[1]', 'varchar(20)') is not null and 
-- a.clno = @CLNO and ii.clno = @CLNO and 
--i.billed = 1 and ii.invoicenumber = @invoicenumber

--Union All
--[Billing_ClientReportInvSummary]  6977,2,'4/1/2013'


select 
i.apno as requestid,
 --a.xmld.value('(/CustomClientData/ClientData1)[1]', 'varchar(20)') as requestid,
--(select top 1 packagecode from applclientdatahistory with (nolock) where apno = a.apno) as packagecode,
(SELECT    ClientPackageCode FROM            dbo.ClientPackages cp inner join Appl A on cp.PackageID = a.PackageID  
    where apno = i.apno  and ClientPackageCode is not null ) as packagecode,
(select isnull(first,'') + ' ' + isnull(last,'') from appl with (nolock) where apno = a.apno) as ApplicantName,
--(select REPLACE(ssn,'-','') from appl with (nolock) where apno = a.apno) as ApplicantSSN,
--a.xmld.value('(/ClientMeta/APPLICANT_ID)[1]', 'varchar(20)') as ApplicantID,
a.xmld.value('(/CustomClientData/ClientData1)[1]', 'varchar(50)') as RequestorID,
a.xmld.value('(/CustomClientData/ClientData2)[1]', 'varchar(30)') as BusinessUnit,
a.xmld.value('(/CustomClientData/ClientData3)[1]', 'varchar(20)') as siteid,
case when (i.description like 'Education%')and i.type = 1 then '1a'
when (i.description like 'Employment%' or i.description like 'work%') and i.type = 1 then '1b'
when i.description like 'License%' and i.type = 1 then '1c'
when i.description like '%service charge%' and i.type = 2 then '2b'
when i.type = 2 then '2a'
else cast(i.type as varchar(5)) end as type,i.description,
case when i.type = 1 then '1' when i.description like '%service charge%' and i.type = 2 then '1' else 0 end As AddOnFee,
i.amount
 from invdetail i with (nolock) inner join
applclientdata a with (nolock) on i.apno = a.apno
inner join invmaster ii with (nolock) on i.invoicenumber = ii.invoicenumber
where 
a.xmld.value('(/CustomClientData/ClientData1)[1]', 'varchar(20)') is not null and 
a.clno = @CLNO and ii.clno = @CLNO and 
i.billed = 1 and ii.invoicenumber = @invoicenumber
--and a.CreatedDate < '5/18/2014'
UNION ALL
--TAX ITEMS
select 
distinct i.apno as requestid,
--a.xmld.value('(/CustomClientData/ClientData1)[1]', 'varchar(20)') as requestid,
--(select top 1 packagecode from applclientdatahistory with (nolock) where apno = a.apno) as packagecode,
(SELECT    ClientPackageCode FROM   dbo.ClientPackages cp inner join Appl A on cp.PackageID = a.PackageID  
    where apno = i.apno  and ClientPackageCode is not null ) as packagecode,
(select isnull(first,'') + ' ' + isnull(last,'') from appl with (nolock) where apno = a.apno) as ApplicantName,
--a.xmld.value('(/ClientMeta/APPLICANT_ID)[1]', 'varchar(20)') as ApplicantID,
a.xmld.value('(/CustomClientData/ClientData1)[1]', 'varchar(50)') as RequestorID,
a.xmld.value('(/CustomClientData/ClientData2)[1]', 'varchar(30)') as BusinessUnit,
a.xmld.value('(/CustomClientData/ClientData3)[1]', 'varchar(20)') as siteid,
'99' as type,'Tax Amount',
0 As AddOnFee,
Round(((select sum(amount) from invdetail where apno = a.apno and billed = 1 and invoicenumber = @invoicenumber) * cast(.0825 as smallmoney)),2) As Tax

 from invdetail i with (nolock) inner join
applclientdata a with (nolock) on i.apno = a.apno
inner join invmaster ii with (nolock) on i.invoicenumber = ii.invoicenumber
where 
a.xmld.value('(/CustomClientData/ClientData1)[1]', 'varchar(20)') is not null and 
a.clno = @CLNO and ii.clno = @CLNO and 
i.billed = 1 and ii.invoicenumber = @invoicenumber
--and a.CreatedDate < '5/18/2014'





order by siteid,requestid

END

END












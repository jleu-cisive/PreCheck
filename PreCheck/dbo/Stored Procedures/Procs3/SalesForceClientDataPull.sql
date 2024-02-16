



CREATE PROCEDURE [dbo].[SalesForceClientDataPull]  
  as 


DECLARE @PREVYEAR datetime,@CURRYEAR datetime,@NEXTYEAR datetime;
set @CURRYEAR = '1/1/' + cast(year(Current_TimeStamp) as varchar)
SET @PREVYEAR = DATEADD(yy,-1,@CURRYEAR);
SET @NEXTYEAR = DATEADD(yy,1,@CURRYEAR);
select 
[name] as 'Client Name',
clno as 'Client Number',
cam as 'CAM',
--(SELECT TOP 1 ISNULL(firstname,'') + ' ' + ISNULL(lastname,'') from clientcontacts where clno = c.clno and primarycontact = 1)as 'Client Primary Contact',
-- ISNULL(Addr1,'') + ' ' + ISNULL(Addr2,'') + ' ' + ISNULL(Addr3,'') AS 'Client Address',
-- city,state,zip,Contact,Email,
--ISNULL(BillingAddress1,'') + ' ' + ISNULL(BillingAddress2,'') AS 'Billing Address',BillingCity as 'Billing City',
--BillingState As 'Billing State/Province',
--BillingZip as 'Billing Zip',
--phone as 'Client Phone Number',
 case when isinactive = 1 then 'InActive' when isoncredithold  = 1 then 'Is On Credit Hold'
when nonclient = 1 then 'NonClient'
when ((select count(*) from appl (nolock) where clno = c.clno and precheckchallenge = 1) > 0 AND 
(select count(*) from appl (nolock) where clno = c.clno and precheckchallenge = 0) = 0) then 'PrecheckChallenge'
when ((select count(*) from appl (nolock) where clno = c.clno and precheckchallenge = 0) > 0) then 'Active'
else 'NoActivity' end As 'Client Status',
null as 'Revenue Type',
 rc.clienttype as 'Client Type',
--(SELECT count(*) from appl (nolock) where clno = c.clno and apdate >= @CURRYEAR and apdate < @NEXTYEAR and isnull(precheckchallenge,0) = 0)  as 'Total Applications for Current Year YTD',
--(SELECT count(*) from appl (nolock) where clno = c.clno and apdate >= @PREVYEAR and apdate < @CURRYEAR and isnull(precheckchallenge,0) = 0)  as 'Total Applications for Previous Year',
convert(varchar,(select min(apdate) from appl (nolock) where clno = c.clno and isnull(precheckchallenge,0) = 0),101) as 'First Application Date',
convert(varchar,(select max(apdate) from appl (nolock) where clno = c.clno and isnull(precheckchallenge,0) = 0),101) as 'Last Application Date',
billcycle as 'Current Billing Cycle',
convert(varchar,(select max(invdate) from invmaster (nolock) where clno = c.clno),101) as 'Last Invoice Date',
--(select SUM(sale)/(select count(*) from invmaster (nolock) where clno = c.clno  and invdate >= DATEADD(m,1,@PREVYEAR)) from invmaster (nolock) where clno = c.clno and invdate >= DATEADD(m,1,@PREVYEAR)) as 'Average Monthly Invoice Amount',


--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= DATEADD(d,1,@PREVYEAR) and invdate <= DATEADD(m,1,@PREVYEAR)) as 'Revenue JAN Previous Year',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate > DATEADD(m,1,@PREVYEAR) and invdate < DATEADD(m,2,@PREVYEAR)) as 'Revenue FEB Previous Year',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= @PREVYEAR and invdate < DATEADD(m,1,@PREVYEAR)) as 'Revenue JAN Previous Year',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= DATEADD(m,1,@PREVYEAR) and invdate < DATEADD(m,2,@PREVYEAR)) as 'Revenue FEB Previous Year',

--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= DATEADD(m,2,@PREVYEAR) and invdate < DATEADD(m,3,@PREVYEAR)) as 'Revenue MAR Previous Year',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= DATEADD(m,3,@PREVYEAR) and invdate < DATEADD(m,4,@PREVYEAR)) as 'Revenue APR Previous Year',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= DATEADD(m,4,@PREVYEAR) and invdate < DATEADD(m,5,@PREVYEAR)) as 'Revenue MAY Previous Year',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= DATEADD(m,5,@PREVYEAR) and invdate < DATEADD(m,6,@PREVYEAR)) as 'Revenue JUN Previous Year',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= DATEADD(m,6,@PREVYEAR) and invdate < DATEADD(m,7,@PREVYEAR)) as 'Revenue JUL Previous Year',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= DATEADD(m,7,@PREVYEAR) and invdate < DATEADD(m,8,@PREVYEAR)) as 'Revenue AUG Previous Year',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= DATEADD(m,8,@PREVYEAR) and invdate < DATEADD(m,9,@PREVYEAR)) as 'Revenue SEP Previous Year',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= DATEADD(m,9,@PREVYEAR) and invdate < DATEADD(m,10,@PREVYEAR)) as 'Revenue OCT Previous Year',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= DATEADD(m,10,@PREVYEAR) and invdate < DATEADD(m,11,@PREVYEAR)) as 'Revenue NOV Previous Year',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= DATEADD(m,11,@PREVYEAR) and invdate < DATEADD(m,12,@PREVYEAR)) as 'Revenue DEC Previous Year',

--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= @CURRYEAR and invdate < DATEADD(d,-2,(DATEADD(m,2,@CURRYEAR)))) as 'Revenue JAN Current Year',
(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= DATEADD(m,1,@CURRYEAR) and invdate < DATEADD(m,2,@CURRYEAR)) as 'Revenue FEB Current Year'
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= DATEADD(m,2,@CURRYEAR) and invdate < DATEADD(m,3,@CURRYEAR)) as 'Revenue MAR Current Year',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= DATEADD(m,3,@CURRYEAR) and invdate < DATEADD(m,4,@CURRYEAR)) as 'Revenue APR Current Year',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= DATEADD(m,4,@CURRYEAR) and invdate < DATEADD(m,5,@CURRYEAR)) as 'Revenue MAY Current Year',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= DATEADD(m,5,@CURRYEAR) and invdate < DATEADD(m,6,@CURRYEAR)) as 'Revenue JUN Current Year',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= DATEADD(m,6,@CURRYEAR) and invdate < DATEADD(m,7,@CURRYEAR)) as 'Revenue JUL Current Year',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= DATEADD(m,7,@CURRYEAR) and invdate < DATEADD(m,8,@CURRYEAR)) as 'Revenue AUG Current Year',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= DATEADD(m,8,@CURRYEAR) and invdate < DATEADD(m,9,@CURRYEAR)) as 'Revenue SEP Current Year',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= DATEADD(m,9,@CURRYEAR) and invdate < DATEADD(m,10,@CURRYEAR)) as 'Revenue OCT Current Year',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= DATEADD(m,10,@CURRYEAR) and invdate < DATEADD(m,11,@CURRYEAR)) as 'Revenue NOV Current Year',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= DATEADD(m,11,@CURRYEAR) and invdate < DATEADD(m,12,@CURRYEAR)) as 'Revenue DEC Current Year',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= '2/1/2005' and invdate < '2/1/2006') as 'Revenue 2005',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= '2/1/2006' and invdate < '2/1/2007') as 'Revenue 2006',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= '2/1/2007' and invdate < '2/1/2008') as 'Revenue 2007',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= '2/1/2008' and invdate < '2/1/2009') as 'Revenue 2008',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= '2/1/2009' and invdate < '2/1/2010') as 'Revenue 2009',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= '2/1/2010' and invdate < '2/1/2011') as 'Revenue 2010',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= '2/1/2011' and invdate < '1/1/2012') as 'Revenue 2011',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= '1/2/2012' and invdate < '1/1/2013') as 'Revenue 2012',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= '1/2/2013' and invdate < '1/1/2014') as 'Revenue 2013',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= '1/2/2014' and invdate < '1/1/2015') as 'Revenue 2014',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= '1/2/2015' and invdate < '1/1/2016') as 'Revenue 2015',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= '1/2/2016' and invdate < '1/1/2017') as 'Revenue 2016',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= '1/2/2017' and invdate < '1/1/2018') as 'Revenue 2017',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= '1/2/2018' and invdate < '1/1/2019') as 'Revenue 2018',
--(select sum(sale) from invmaster (nolock) where clno = c.clno and invdate >= '1/2/2019' and invdate < '1/1/2020') as 'Revenue 2019',
--salespersonuserid as 'Sales Team',
--convert(varchar,useragreementdate,101) as 'User Agreement Signed Date',
--createddate as 'Client: Created Date',
--convert(varchar,(select max(changedate) from changelogcm (nolock) where id = c.clno and tablename like 'client.%'),101) as 'Client: Last Modified Date',
--ra.affiliate as 'Affiliate'
from client c (nolock) left join refclienttype rc (nolock) on c.clienttypeid = rc.clienttypeid
left join refaffiliate ra on c.affiliateid = ra.affiliateid
order by c.name








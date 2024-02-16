-- =============================================
-- Author:		Tanay Dubey
-- Create date:	10-19-2023
-- Description:	This will give all the details of the reports which have missing or incorrect AttentionTo field after completion of report.
-- Modified by:	Tanay Dubey HDT 39600/ Jira Story CXHE-117
-- =============================================
CREATE PROCEDURE [dbo].[AllReports_MissingAttentionTo_5PM]
AS
BEGIN
SET NOCOUNT ON;

drop table if exists #ValidAttnTo
drop table if exists #ExcludeStudentCheckAccounts

--------------------------------------------------------
select 
	distinct c.clno, cc.GetsReport, c.CAM, cc.IsActive
into #ExcludeStudentCheckAccounts
from 
	client c
	inner join ClientContacts cc on c.CLNO = cc.CLNO 
group by c.clno, cc.GetsReport, c.CAM, cc.IsActive
having
	c.Cam = 'Student'
	and cc.IsActive = 1
	and cc.GetsReport = 1
order by c.CLNO

--select * from #ExcludeStudentCheckAccounts
----------------------------------------------------------
SELECT
	   a.APNO
into #ValidAttnTo
FROM appl a
       left join users u  on u.userid=a.userid
	   inner join client c on a.clno=c.clno
	   inner JOIN ClientContacts cc WITH (NOLOCK) ON a.CLNO = cc.CLNO and (isnull(a.attn,'') = '' OR ((replace((rtrim(ltrim(a.attn))),', ',',')) = Isnull(cc.Lastname,'') +','+ Isnull(cc.Firstname,''))) 
	   left join refdeliverymethod r on c.deliverymethodid=r.deliverymethodid

 

where
a.compdate  between DATEADD(HH, 7, CONVERT(DATETIME, CONVERT(date, GETDATE()))) and DATEADD(HH, 17, CONVERT(DATETIME, CONVERT(date, GETDATE())))
and a.apstatus='F' and a.clno not in (3468,2135,3668,17480)
and r.deliverymethod not in ('Confax' ,'ConNoNotification')
and cc.IsActive = 1

 

--select * from #ValidAttnTo
select
		a.userid as 'CAM UserId'
       ,u.emailaddress as 'CAM EmailAddress'
       ,FORMAT (a.apdate, 'MM-dd-yyyy hh:mm:ss') as 'Report Start Date'
       ,FORMAT (a.compdate, 'MM-dd-yyyy hh:mm:ss') as 'Report Completion Date'
	   ,a.clno as 'Client Number'
       ,REPLACE(c.name,',',' ') as 'Client Name'
       ,REPLACE(a.attn,',',' ') as 'AttentionTo'
       ,a.apno as 'Report Number'
       ,a.apstatus as 'Report Status'
	from
		Appl a
		left join #ValidAttnTo v on a.APNO = v.APNO
		left join users u  on u.userid=a.userid
        inner join client c on a.clno=c.clno
		left join #ExcludeStudentCheckAccounts sca on a.CLNO = sca.CLNO
	    left join refdeliverymethod r on c.deliverymethodid=r.deliverymethodid
	where
    a.compdate  between DATEADD(HH, 7, CONVERT(DATETIME, CONVERT(date, GETDATE()))) and DATEADD(HH, 17, CONVERT(DATETIME, CONVERT(date, GETDATE())))
	and a.apstatus='F' and a.clno not in (3468,2135,3668, 17480)
	and r.deliverymethod not in ('Confax' ,'ConNoNotification')
	and v.APNO is null
	and sca.CLNO is null
order by a.CompDate desc
END

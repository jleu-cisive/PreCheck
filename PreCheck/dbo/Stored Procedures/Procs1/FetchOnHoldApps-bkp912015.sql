

-- =============================================
-- Author:		<Najma Begum>
-- Create date: <07/02/2011,>
-- Description:	<Get list of On Hold applications and send email notifications based on 
--				refNotificationTypeID = 9 for all client numbers.>
--
-- Modified date: <08/16/2013>
-- Modified By Schapyala 
-- To include all clients under the parent hierarchy
--using the hierarchy setup 
-- =============================================
Create PROCEDURE [dbo].[FetchOnHoldApps-bkp912015] 
	-- Add the parameters for the stored procedure here
	AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON;
SET  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

 Create Table #tmpOnHoldNotification (ID INT NOT NULL identity(1,1)  PRIMARY KEY CLUSTERED,CLNO INT,ChildCLNO INT,Email varchar(1500))

 --Load Data from PreCheck_Staging DB - NotificationConfig table for OnHold notification
 INSERT into #tmpOnHoldNotification
 SELECT distinct nc.CLNO,CH.clno ChildCLNO, nc.Email
 from [Precheck_Staging].[dbo].NotificationConfig nc left join DBO.ClientHierarchyByService CH ON nc.CLNO = CH.ParentCLNO
 WHERE nc.refNotificationTypeID = 9
 --and nc.Email is not null

 Create Table #tmpemails (ID INT NOT NULL identity(1,1)  PRIMARY KEY CLUSTERED,CLNO INT,APNO INT,Email varchar(1500),CAMEmail varchar(200),ApplicantName varchar(200),ApDate DateTime,ClientApplicantNO varchar(100),ClientAPNO varchar(100))

 --Load all OnHold applications (general population without onhold notification configuration). If AttnTo is already an email, then send there else pull client contact email.
 --certain clients have a notification offset - do not send an onhold notification until the Offset expires
 --using April 2014 as the cutofff date
 Insert into #tmpemails
 SELECT a.clno,a.apno,case when charindex('@',a.ATTN,1)>0  then a.ATTN else cc.email end Email,EmailAddress,(a.last + ', ' +  a.first) as ApplicantName,a.apdate,ClientApplicantNO,ClientAPNO
 from dbo.appl a  inner join client c on a.clno = c.clno
 left join users u on c.cam = u.userid
 left join ClientContacts CC on a.attn = (cc.LastName + ', ' + cc.FirstName) and a.clno = cc.clno
 left join (Select CLNO, cast(Value as int) Notification_OnHold_Offset_Hrs From DBO.ClientConfiguration Where ConfigurationKey = 'Notification_OnHold_Offset_Hrs') Config on a.clno = Config.clno
 WHERE  a.apstatus = 'M' and a.apdate > '04/01/2014' and (case when charindex('@',a.ATTN,1)>0  then a.ATTN else cc.email end) is not null
 --Will not send notifications until the configured offset in hours have passed (since we received the app) - 7898 (PHS) requirement
 AND current_timestamp > (case when Notification_OnHold_Offset_Hrs is null then a.apdate else DateAdd(hour,Notification_OnHold_Offset_Hrs,a.apdate)   end)
 AND a.CLNO not in (Select Isnull(ChildCLNO,CLNO) FROM #tmpOnHoldNotification)
 
 --select * from #tmpOnHoldNotification
 --select * from #tmpemails where  email is not null order by email

Create Table #tmpemailsWithCAM (ID INT NOT NULL identity(1,1)  PRIMARY KEY CLUSTERED,CLNO INT,APNO INT,Email varchar(1500),CAMEmail varchar(200),ApplicantName varchar(200),ApDate DateTime,ClientApplicantNO varchar(100),ClientAPNO varchar(100))

--get the distinct list of attn emails (concatinated) and the cam address by clno
INSERT into #tmpemailsWithCAM
SELECT DISTINCT clno,apno, 
Email = STUFF((SELECT distinct ',' + Email  FROM #tmpemails WHERE clno = t.clno FOR XML PATH('')), 1, 1, '') ,
CAMEmail,ApplicantName,ApDate,ClientApplicantNO,ClientAPNO
FROM #tmpemails AS t

 DROP TABLE #tmpemails

--select * from #tmpemailsWithCAM 
--This recordset has a list of qualified emails per client - that has reports OnHold.
 SELECT Distinct Email,clno
 From
 (
 SELECT nc.Email,nc.clno
 from #tmpOnHoldNotification nc inner join dbo.appl a on a.clno = nc.ChildCLNO
 WHERE  a.apstatus = 'M' 
 UNION ALL
 SELECT nc.Email,nc.clno
 from #tmpOnHoldNotification nc inner join dbo.appl a on a.clno = nc.CLNO
 WHERE  a.apstatus = 'M' 
 UNION ALL --Added by santosh to add the emails of onhold apps without notification email configured 
 SELECT ((case when isnull(CAMEmail,'') is null then Email else Email + ',' + CAMEmail end) + ',LoriMcGowan@precheck.com') email,clno 
 FROM  #tmpemailsWithCAM 
 ) Qry 
 Where Email is not null 
 and clno not in (3468,2135) --exclude bad apps and test accounts
 order by clno

 --This recordset has a list of Reports per client that has reports onHold
 SELECT Distinct APNO,Name,apdate,clno,clientapno
 From
 (
 SELECT a.APNO,(a.last + ', ' +  a.first) as Name,a.apdate, nc.clno, (case when (a.ClientApplicantNO like '090000000000000000000%' or isnull(a.ClientApplicantNO,'')='') then  (case when a.clientapno like '090000000000000000000%' then '' else a.clientapno end) else  a.ClientApplicantNO end) clientapno
 from #tmpOnHoldNotification nc inner join dbo.appl a on a.clno = nc.ChildCLNO
 WHERE  a.apstatus = 'M' 
 UNION ALL
 SELECT a.APNO,(a.last + ', ' +  a.first) as Name,a.apdate, nc.clno,  (case when (a.ClientApplicantNO like '090000000000000000000%'  or isnull(a.ClientApplicantNO,'')='') then  (case when a.clientapno like '090000000000000000000%' then '' else a.clientapno end) else  a.ClientApplicantNO end) clientapno
 from #tmpOnHoldNotification nc inner join dbo.appl a on a.clno = nc.CLNO
 WHERE  a.apstatus = 'M' 
 UNION ALL --Added by santosh to add the emails of onhold apps without notification email configured 
 SELECT APNO,ApplicantName Name,apdate, clno,  (case when (ClientApplicantNO like '090000000000000000000%'  or isnull(ClientApplicantNO,'')='') then  (case when clientapno like '090000000000000000000%' then '' else clientapno end) else  ClientApplicantNO end) clientapno
 FROM  #tmpemailsWithCAM
  ) Qry Where  clno not in (3468,2135) --exclude bad apps and test accounts

 DROP TABLE #tmpemailsWithCAM
 DROP TABLE #tmpOnHoldNotification

 SET NOCOUNT OFF;
SET TRANSACTION ISOLATION  LEVEL READ COMMITTED;
 END


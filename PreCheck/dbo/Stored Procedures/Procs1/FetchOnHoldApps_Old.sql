

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
CREATE PROCEDURE [dbo].[FetchOnHoldApps_Old] 
	-- Add the parameters for the stored procedure here
	AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON;

 SELECT distinct nc.Email,CH.clno ChildCLNO,nc.CLNO into #tmpOnHoldNotification
 from [Precheck_Staging].[dbo].NotificationConfig nc left join DBO.ClientHierarchyByService CH ON nc.CLNO = CH.ParentCLNO
 WHERE nc.refNotificationTypeID = 9
 --and nc.Email is not null
 
 --Added by schapyala - 03/08/14 -- Query to get the attn to email for apps onHold where the notification config email does not exist
 Select distinct email,clno,EmailAddress into #tmpemails  From
 (
 SELECT case when charindex('@',a.ATTN,1)>0  then a.ATTN else cc.email end Email,nc.clno,EmailAddress
 from #tmpOnHoldNotification nc inner join dbo.appl a on a.clno = nc.ChildCLNO
 inner join client c on a.clno = c.clno
 left join users u on c.cam = u.userid
 left join ClientContacts CC on a.attn = (cc.LastName + ', ' + cc.FirstName)
 WHERE  a.apstatus = 'M'   AND nc.Email IS NULL 
 UNION ALL
 SELECT case when charindex('@',a.ATTN,1)>0  then a.ATTN else cc.email end Email,nc.clno,EmailAddress
 from #tmpOnHoldNotification nc inner join dbo.appl a on a.clno = nc.CLNO
  inner join client c on a.clno = c.clno
 left join users u on c.cam = u.userid
  left join ClientContacts CC on a.attn = (cc.LastName + ', ' + cc.FirstName)
 WHERE  a.apstatus = 'M'  AND nc.Email IS NULL ) SubQry
 Where SubQry.Email is not null  

--get the distinct list of attn emails (concatinated) and the cam address by clno
SELECT DISTINCT clno,emailaddress, Email = STUFF((SELECT ',' + Email  
FROM #tmpemails WHERE clno = t.clno 
FOR XML PATH('')), 1, 1, '') into #tmpemailsWithCAM
FROM
#tmpemails AS t

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
 SELECT ((case when isnull(emailaddress,'') is null then Email else Email + ',' + emailaddress end) + ',santoshchapyala@precheck.com') email,clno 
 FROM  #tmpemailsWithCAM 
 ) Qry 
 Where Email is not null

 DROP TABLE #tmpemailsWithCAM
 DROP TABLE #tmpemails

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
  ) Qry


 DROP TABLE #tmpOnHoldNotification


 END


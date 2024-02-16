--Modified by DJones and SChapyala to include additional columns and also the issuing detail on 01/05/2023
--[dbo].[GetVelocityOptinReport] @AffiliateID =294
CREATE PROCEDURE [dbo].[GetVelocityOptinReport](@startDate DATETIME = '11/01/2022 11:00',@EndDate DATETIME = NULL,@AffiliateID INT = 294)      
AS 

BEGIN
SET NOCOUNT ON; 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

IF @enddate IS NULL
BEGIN
SET @enddate = CURRENT_TIMESTAMP
END

	SELECT DISTINCT a.CLNO, Name, A.APNO,A.APDate, A.First,A.Last, a.ApStatus, a.CompDate INTO #tblMain
	FROM Precheck.dbo.Appl a 
	JOIN Precheck.dbo.client c  ON c.CLNO = a.CLNO
	LEFT JOIN Precheck.dbo.[ClientReportDateRanges] r ON r.CLNO = a.CLNO
	WHERE @startdate < a.ApDate AND a.ApDate < @enddate
	AND (r.StartDate IS NULL OR  r.StartDate < a.ApDate) AND (r.EndDate IS NULL OR a.ApDate < r.EndDate)
	AND (r.IsActive = 1 OR r.IsActive IS NULL)
	AND a.CLNO NOT IN (3468,3079,11340, 17870 )
	AND (C.AffiliateID = @AffiliateID OR @AffiliateID IS NULL)


	SELECT DISTINCT a.CLNO, Name, A.APNO,A.APDate, A.First,A.Last,IsProcessed,sal.IsActive,DASubscriptionActionTypeID, a.ApStatus, a.CompDate INTO #tblMainStage
	FROM #tblMain a
	JOIN Enterprise.Staging.ApplicantStage s ON s.ApplicantNumber = a.APNO
	JOIN (SELECT DISTINCT ApplicantId, DASubscriptionActionTypeID,IsProcessed,IsActive FROM [Enterprise].[Subscription].[AssociateSubscriptionActionLog]) sal ON sal.ApplicantId = s.StagingApplicantId


SELECT 'Summary' FileType,@startdate AS FromDate, 
@enddate AS ToDate, 
c.AffiliateID,
c.Name AS 'Site Name',
c.City AS 'Site City', 
c.State AS 'Site State', 
t.CasesCount AS 'Total Applications Submitted ( opt in + opt out )', 
ISNULL(oi.optinCount,0) AS 'Total Opt-In', 
t.CasesCount - ISNULL(oi.optinCount,0) AS 'Total Opt-Out', 
(CAST(ISNULL(oi.optinCount,0) AS FLOAT)/CAST(t.CasesCount AS FLOAT))*100 AS 'Opt-In Rate (Opt In / Total Applications Submitted)',
ISNULL(b.backgroundCount,0) AS 'Number of opted in candidates in background',
--ISNULL(h.holdCount,0) AS 'Number of opted in candidates in 10 day hold',

ISNULL(s.sentCount,0) AS 'Total number of Notification Emails sent',
(CAST(ISNULL(s.sentCount,0) AS FLOAT)/CAST(oi.optinCount AS FLOAT))*100 AS 'Emails Sent Rate (Emails Sent / Opted In)',

ISNULL(n.noCredCount,0) AS 'Applications with no Credentials to send',
ISNULL(m.noMatchCount,0) AS 'No Match Credentials',
(CAST(ISNULL(m.noMatchCount,0) AS FLOAT)/CAST(s.sentCount AS FLOAT))*100 AS 'No Match Credentials Rate (No Match / Emails Sent)',
ISNULL(edu.eduCredCount,0) AS 'Total Education Credentials Imported',
ISNULL(emp.empCredCount,0) AS 'Total Employment Credentials Imported',
ISNULL(emp.empCredCount,0) + ISNULL(edu.eduCredCount,0) AS 'Total Credentials Imported',
Isnull(Ac.Totalcandidatescount,0) as 'Total candidates who claimed their credentials',
Isnull(TC.Totalcredentialscount,0) as 'Total credentials claimed',
ISNULL(VL.VisitedlandingPageCount,0)as 'Total Visited landing Page',
ISNULL(CLM.ClickedMobilebuttonCount,0) as 'Total Clicked the mobile button',
ISNULL(CLA.Clickedapplinkcount,0) as 'Total Clicked on app link',
ISNULL(CLF.ClickedFAQCount,0) as 'Total Clicked FAQ'
FROM dbo.Client c 
LEFT JOIN (
	SELECT a.CLNO, COUNT(1) AS optinCount
	FROM #tblMainStage a
	WHERE  a.DASubscriptionActionTypeID = 8778
	GROUP BY a.CLNO
) oi ON oi.CLNO = c.CLNO
JOIN (
	SELECT c.CLNO, COUNT(1) AS CasesCount
	FROM #tblMain c
	GROUP BY c.CLNO
) t ON t.CLNO = c.CLNO
LEFT JOIN (
	SELECT a.CLNO, COUNT(1) AS sentCount
	FROM #tblMainStage a
	Where IsProcessed = 1 AND a.DASubscriptionActionTypeID = 8778
	GROUP BY a.CLNO
) s ON s.CLNO = c.CLNO
LEFT JOIN (
	SELECT a.CLNO, COUNT(1) AS noCredCount
	FROM #tblMainStage a
	Where IsActive = 0
	GROUP BY a.CLNO
) n ON n.CLNO = c.CLNO
LEFT JOIN (
	SELECT c.CLNO, COUNT(1) AS backgroundCount
	FROM #tblMainStage c
	WHERE c.CompDate IS NULL OR c.ApStatus <> 'F'
	GROUP BY c.CLNO
) b ON b.CLNO = c.CLNO
LEFT JOIN (
	SELECT c.CLNO, COUNT(1) AS holdCount
	FROM #tblMain c
	WHERE c.CompDate IS NOT NULL AND c.ApStatus = 'F' AND c.CompDate > DATEADD(d,-10,CURRENT_TIMESTAMP)
	GROUP BY c.CLNO
) h ON h.CLNO = c.CLNO
LEFT JOIN (
	SELECT a.CLNO, COUNT(1) AS noMatchCount
	FROM #tblMainStage a
	Where IsProcessed = 1 AND a.DASubscriptionActionTypeID = 8779
	GROUP BY a.CLNO
) m ON m.CLNO = c.CLNO
LEFT JOIN (
	SELECT a.CLNO, COUNT(1) AS eduCredCount
	FROM dbo.EducationCredentials e
	JOIN Enterprise.[Staging].[ApplicantStage] s ON s.StagingApplicantId = e.StagingApplicantId
	JOIN dbo.Appl a ON a.APNO = s.ApplicantNumber
	GROUP BY a.CLNO
) edu ON edu.CLNO = c.CLNO
LEFT JOIN (
	SELECT a.CLNO, COUNT(1) AS empCredCount
	FROM dbo.EmploymentCredentials e
	JOIN Enterprise.[Staging].[ApplicantStage] s ON s.StagingApplicantId = e.StagingApplicantId
	JOIN dbo.Appl a ON a.APNO = s.ApplicantNumber
	GROUP BY a.CLNO
) emp ON emp.CLNO = c.CLNO
LEFT JOIN (
     select COUNT (DISTINCT VC.APNO ) AS Totalcandidatescount , A.CLNO 
	 from Precheck.Velocity.ClaimedCredentialsLog VC 
	 Join Precheck.dbo.Appl A on A.Apno= VC.APNO
	 GROUP BY A.CLNO
) AC ON AC.CLNO = C.CLNO
LEFT JOIN (
     select COUNT (VC.APNO ) AS Totalcredentialscount , A.CLNO 
	 from Precheck.Velocity.ClaimedCredentialsLog VC 
	 Join Precheck.dbo.Appl A on A.Apno= VC.APNO
	 GROUP BY A.CLNO
) TC ON TC.CLNO = C.CLNO

LEFT JOIN (
	SELECT a.CLNO, COUNT(1) AS VisitedlandingPageCount
	FROM #tblMainStage a
	WHERE  a.DASubscriptionActionTypeID = 9017 -- Visited landing page
	GROUP BY a.CLNO
) VL ON VL.CLNO = c.CLNO
LEFT JOIN (
	SELECT a.CLNO, COUNT(1) AS ClickedMobilebuttonCount
	FROM #tblMainStage a
	WHERE  a.DASubscriptionActionTypeID = 9018  -- Clicked Mobile button
	GROUP BY a.CLNO
) CLM ON CLM.CLNO = c.CLNO
LEFT JOIN (
	SELECT a.CLNO, COUNT(1) AS Clickedapplinkcount
	FROM #tblMainStage a 
	WHERE  a.DASubscriptionActionTypeID = 9019  -- Clicked app link
	GROUP BY a.CLNO
) CLA ON CLA.CLNO = c.CLNO
LEFT JOIN (
	SELECT a.CLNO, COUNT(1) AS ClickedFAQCount
	FROM #tblMainStage a
	WHERE  a.DASubscriptionActionTypeID = 9020  -- Clicked FAQ
	GROUP BY a.CLNO
)CLF ON CLF.CLNO = c.CLNO

UNION ALL

SELECT 'Summary' FileType,@startdate AS FromDate, 
@enddate AS ToDate, 
'',
'cumulative', 
'',
'', 
SUM(t.CasesCount) AS 'Total Applications Submitted ( opt in + opt out )', 
SUM(oi.optinCount) as 'Total Opt-In', 
SUM(t.CasesCount) - SUM(oi.optinCount) AS 'Total Opt-Out', 
(CAST(SUM(oi.optinCount) AS FLOAT)/CAST(SUM(t.CasesCount) AS FLOAT))*100 AS 'Opt-In Rate (Opt In / Total Applications Submitted)',
ISNULL(SUM(b.backgroundCount),0) AS 'Number of opted in candidates in background',
--ISNULL(SUM(h.holdCount),0) AS 'Number of opted in candidates in 10 day hold',

ISNULL(SUM(s.sentCount),0) AS 'Total number of Notification Emails sent',
(CAST(SUM(s.sentCount) AS FLOAT)/CAST(SUM(oi.optinCount) AS FLOAT))*100 AS 'Emails Sent Rate (Emails Sent / Opted In)',
ISNULL(SUM(n.noCredCount),0) AS 'Applications with no Credentials to send',
ISNULL(SUM(m.noMatchCount),0) AS 'No Match Credentials',
(CAST(SUM(m.noMatchCount) AS FLOAT)/CAST(SUM(s.sentCount) AS FLOAT))*100 AS 'No Match Credentials Rate (No Match / Emails Sent)',
ISNULL(SUM(edu.eduCredCount),0) AS 'Total Education Credentials Imported',
ISNULL(SUM(emp.empCredCount),0) AS 'Total Employment Credentials Imported',
ISNULL(SUM(emp.empCredCount),0) + ISNULL(SUM(edu.eduCredCount),0) AS 'Total Credentials Imported',
Isnull(SUM(Ac.Totalcandidatescount),0) as 'Total candidates who claimed their credentials',
Isnull(SUM(TC.Totalcredentialscount),0) as 'Total credentials claimed',
ISNULL(SUM(VL.VisitedlandingPageCount),0)as 'Total Visited landing Page',
ISNULL(Sum(CLM.ClickedMobilebuttonCount),0) as 'Total Clicked the mobile button',
ISNULL(Sum(CLA.Clickedapplinkcount),0) as 'Total Clicked on app link',
ISNULL(Sum(CLF.ClickedFAQCount),0) as 'Total Clicked FAQ'
FROM  dbo.Client c 
LEFT JOIN (
	SELECT a.CLNO, COUNT(1) AS optinCount
	FROM #tblMainStage a
	WHERE  a.DASubscriptionActionTypeID = 8778
	GROUP BY a.CLNO
) oi ON oi.CLNO = c.CLNO
JOIN (
	SELECT c.CLNO, COUNT(1) AS CasesCount
	FROM #tblMain c
	GROUP BY c.CLNO
) t ON t.CLNO = c.CLNO
LEFT JOIN (
	SELECT a.CLNO, COUNT(1) AS sentCount
	FROM #tblMainStage a
	Where IsProcessed = 1  AND a.DASubscriptionActionTypeID = 8778
	GROUP BY a.CLNO
) s ON s.CLNO = c.CLNO
LEFT JOIN (
	SELECT a.CLNO, COUNT(1) AS noCredCount
	FROM #tblMainStage a
	Where IsActive = 0
	GROUP BY a.CLNO
) n ON n.CLNO = c.CLNO
LEFT JOIN (
	SELECT c.CLNO, COUNT(1) AS backgroundCount
	FROM #tblMainStage c
	WHERE c.CompDate IS NULL OR c.ApStatus <> 'F'
	GROUP BY c.CLNO
) b ON b.CLNO = c.CLNO
LEFT JOIN (
	SELECT c.CLNO, COUNT(1) AS holdCount
	FROM #tblMain c
	WHERE c.CompDate IS NOT NULL AND c.ApStatus = 'F' AND c.CompDate > DATEADD(d,-10,CURRENT_TIMESTAMP)
	GROUP BY c.CLNO
) h ON h.CLNO = c.CLNO
LEFT JOIN (
	SELECT a.CLNO, COUNT(1) AS noMatchCount
	FROM #tblMainStage a
	Where IsProcessed = 1 AND a.DASubscriptionActionTypeID = 8779
	GROUP BY a.CLNO
) m ON m.CLNO = c.CLNO
LEFT JOIN (
	SELECT a.CLNO, COUNT(1) AS eduCredCount
	FROM dbo.EducationCredentials e
	JOIN Enterprise.[Staging].[ApplicantStage] s ON s.StagingApplicantId = e.StagingApplicantId
	JOIN dbo.Appl a ON a.APNO = s.ApplicantNumber
	GROUP BY a.CLNO
) edu ON edu.CLNO = c.CLNO
LEFT JOIN (
	SELECT a.CLNO, COUNT(1) AS empCredCount
	FROM dbo.EmploymentCredentials e
	JOIN Enterprise.[Staging].[ApplicantStage] s ON s.StagingApplicantId = e.StagingApplicantId
	JOIN dbo.Appl a ON a.APNO = s.ApplicantNumber
	GROUP BY a.CLNO
) emp ON emp.CLNO = c.CLNO
LEFT JOIN (
     select COUNT (DISTINCT VC.APNO ) AS Totalcandidatescount , A.CLNO 
	 from Precheck.Velocity.ClaimedCredentialsLog VC 
	 Join Precheck.dbo.Appl A on A.Apno= VC.APNO
	 GROUP BY A.CLNO
) AC ON AC.CLNO = C.CLNO
LEFT JOIN (
     select COUNT (VC.APNO ) AS Totalcredentialscount , A.CLNO 
	 from Precheck.Velocity.ClaimedCredentialsLog VC 
	 Join Precheck.dbo.Appl A on A.Apno= VC.APNO
	 GROUP BY A.CLNO
) TC ON TC.CLNO = C.CLNO
LEFT JOIN (
	SELECT a.CLNO, COUNT(1) AS VisitedlandingPageCount
	FROM #tblMainStage a
	WHERE  a.DASubscriptionActionTypeID = 9017 -- Visited landing page
	GROUP BY a.CLNO
) VL ON VL.CLNO = c.CLNO
LEFT JOIN (
	SELECT a.CLNO, COUNT(1) AS ClickedMobilebuttonCount
	FROM #tblMainStage a
	WHERE  a.DASubscriptionActionTypeID = 9018  -- Clicked Mobile button
	GROUP BY a.CLNO
) CLM ON CLM.CLNO = c.CLNO
LEFT JOIN (
	SELECT a.CLNO, COUNT(1) AS Clickedapplinkcount
	FROM #tblMainStage a 
	WHERE  a.DASubscriptionActionTypeID = 9019  -- Clicked app link
	GROUP BY a.CLNO
) CLA ON CLA.CLNO = c.CLNO
LEFT JOIN (
	SELECT a.CLNO, COUNT(1) AS ClickedFAQCount
	FROM #tblMainStage a
	WHERE  a.DASubscriptionActionTypeID = 9020  -- Clicked FAQ
	GROUP BY a.CLNO
)CLF ON CLF.CLNO = c.CLNO




--select 'OptIn-Detail' FileType,CLNO, Name, APNO,APDate, First [First Name],Last [Last Name] from #tblmainstage

--select 'Total-Cases' FileType,* from #tblmain

--select 'Notification-Detail' FileType,CLNO, Name, APNO,APDate, First [First Name],Last [Last Name] 
--from #tblmainstage
--Where IsProcessed = 1

--select 'NoCred-Detail' FileType,CLNO, Name, APNO,APDate, First [First Name],Last [Last Name] 
--from #tblmainstage
--Where IsActive = 0

select  FileType,
		APNO,
		ApplicantId,
		ItemName,
		CLNO,
		[Email Date],
		[Email Open Date],
		[Hours Until Opened] from  
 (
 SELECT DISTINCT
	'Initial Email Open' FileType,
	 a.APNO,
	 sal.ApplicantId,
	 da.ItemName,
	 a.CLNO,
	 sal3.ModifyDate AS 'Email Date',
	 sal2.CreateDate AS 'Email Open Date',
	 DATEDIFF(second, sal3.ModifyDate, sal2.CreateDate) / 3600.0 AS 'Hours Until Opened'
FROM Enterprise.SUBSCRIPTION.AssociateSubscriptionActionLog sal
JOIN Enterprise.Staging.ApplicantStage s ON s.StagingApplicantId = sal.ApplicantId
cross APPLY (SELECT TOP 1 * FROM Enterprise.Subscription.AssociateSubscriptionActionLog WHERE ApplicantId = sal.ApplicantId  AND  DASubscriptionActionTypeID = 8951 ORDER BY CreateDate asc ) sal2 -- Initial Email open
cross APPLY (SELECT TOP 1 * FROM Enterprise.Subscription.AssociateSubscriptionActionLog WHERE ApplicantId = sal.ApplicantId  AND  DASubscriptionActionTypeID = 8778 AND IsProcessed = 1 AND IsActive = 1 ORDER BY CreateDate asc ) sal3 -- notification email 
JOIN Enterprise.dbo.DynamicAttribute da ON sal.DASubscriptionActionTypeID = da.DynamicAttributeId
JOIN Precheck.dbo.Appl a ON a.APNO = s.ApplicantNumber
JOIN Precheck.dbo.Client c ON c.CLNO = a.CLNO
WHERE    a.CLNO NOT IN (3468,3079,11340, 17870 ) and sal.DASubscriptionActionTypeID=8951    --Initial Email Open
union all 
SELECT DISTINCT
    'Reminder Email 1 Open' FileType,
	 a.APNO,
	 sal.ApplicantId,
	 da.ItemName,
	 a.CLNO,
     sal5.ModifyDate AS 'Email Date',
	 sal4.CreateDate AS 'Email Open Date',
	 DATEDIFF(second, sal5.ModifyDate, sal4.CreateDate) / 3600.0 AS 'Hours Until Opened'
FROM Enterprise.SUBSCRIPTION.AssociateSubscriptionActionLog sal
JOIN Enterprise.Staging.ApplicantStage s ON s.StagingApplicantId = sal.ApplicantId
cross APPLY (SELECT TOP 1 * FROM Enterprise.Subscription.AssociateSubscriptionActionLog WHERE ApplicantId = sal.ApplicantId  AND  DASubscriptionActionTypeID = 9023 ORDER BY CreateDate asc ) sal4 -- reminder Email1 open
cross APPLY (SELECT TOP 1 * FROM Enterprise.Subscription.AssociateSubscriptionActionLog WHERE ApplicantId = sal.ApplicantId  AND  DASubscriptionActionTypeID = 9021 AND IsProcessed = 1 AND IsActive = 1 ORDER BY CreateDate asc ) sal5 -- Velocity reminder email 1
JOIN Enterprise.dbo.DynamicAttribute da ON sal.DASubscriptionActionTypeID = da.DynamicAttributeId
JOIN Precheck.dbo.Appl a ON a.APNO = s.ApplicantNumber
JOIN Precheck.dbo.Client c ON c.CLNO = a.CLNO
WHERE  a.CLNO NOT IN (3468,3079,11340, 17870 ) and  sal.DASubscriptionActionTypeID=9023  --Reminder email 1 open	
union all
SELECT DISTINCT
    'Reminder Email 2 Open' FileType,
	 a.APNO,
	 sal.ApplicantId,
	 da.ItemName,
	 a.CLNO,
     sal7.ModifyDate AS 'Email Date',
	 sal6.CreateDate AS 'Email Open Date',
	 DATEDIFF(second, sal7.ModifyDate, sal6.CreateDate) / 3600.0 AS 'Hours Until Opened'
FROM Enterprise.SUBSCRIPTION.AssociateSubscriptionActionLog sal
JOIN Enterprise.Staging.ApplicantStage s ON s.StagingApplicantId = sal.ApplicantId
cross APPLY (SELECT TOP 1 * FROM Enterprise.Subscription.AssociateSubscriptionActionLog WHERE ApplicantId = sal.ApplicantId  AND  DASubscriptionActionTypeID = 9024 ORDER BY CreateDate asc ) sal6 -- reminder Email1 open
cross APPLY (SELECT TOP 1 * FROM Enterprise.Subscription.AssociateSubscriptionActionLog WHERE ApplicantId = sal.ApplicantId  AND  DASubscriptionActionTypeID = 9022 AND IsProcessed = 1 AND IsActive = 1 ORDER BY CreateDate asc ) sal7 -- Velocity reminder email 2



JOIN Enterprise.dbo.DynamicAttribute da ON sal.DASubscriptionActionTypeID = da.DynamicAttributeId
JOIN Precheck.dbo.Appl a ON a.APNO = s.ApplicantNumber
JOIN Precheck.dbo.Client c ON c.CLNO = a.CLNO
WHERE  a.CLNO NOT IN (3468,3079,11340, 17870 ) and  sal.DASubscriptionActionTypeID=9024  ) x order by x.[FileType],[Email Date] desc  	 --Reminder email 2 open



select 'Issuing Opt In Detail' FileType, 
m.APNO,
c.AffiliateID,
c.Name AS 'Site Name',
c.City AS 'Site City',
c.State AS 'Site State',
m.ApDate AS 'Application Submitted Date',
CASE WHEN n.APNO IS NOT NULL THEN 'Yes' ELSE 'No' END AS 'Opt in (yes/no)',
CASE WHEN n.APNO IS NOT NULL THEN 'No' ELSE 'Yes' END AS 'Opt out (yes/no)',
Case WHEN vc.APNO Is NOT NULL THEN 'Yes'ELSE 'No' END As 'Claimed credentials (yes/no)',
CASE WHEN m.CompDate IS NULL OR m.ApStatus <> 'F' THEN 'Yes' ELSE 'No' END AS 'Background in process',
m.CompDate AS 'Background complete date',
m.CompDate AS 'Start 10 day hold date',
s.ModifyDate AS 'Notification Email Sent Date',
ms.ModifyDate AS 'No Match Email Sent Date',
CASE WHEN nm.APNO IS NOT NULL THEN 'Yes' ELSE 'No' END AS 'No Credentials to Send',
ISNULL(edu.eduCredCount,0) AS 'Total Education Credentials Imported',
ISNULL(emp.empCredCount,0) AS 'Total Employment Credentials Imported',
ISNULL(edu.eduCredCount,0) + ISNULL(emp.empCredCount,0) AS 'Total Credentials Imported',
ISNULL(cc.claimedCredCount,0)  AS ' Total credentials claimed'
FROM #tblMain m 
JOIN dbo.Client c ON c.CLNO = m.CLNO
OUTER APPLY (
	SELECT TOP 1 a.APNO
	FROM #tblMainStage a
	Where  a.DASubscriptionActionTypeID = 8778 --notification email
	AND  a.APNO = m.APNO
) n
OUTER APPLY (
	SELECT TOP 1 a.APNO
	FROM #tblMainStage a
	Where  a.DASubscriptionActionTypeID = 8779 -- no match email
	AND a.APNO = m.APNO
) ma
OUTER APPLY	 (
	SELECT TOP 1 a.OrderNumber, a.ModifyDate
	FROM [Enterprise].[Subscription].[AssociateSubscriptionActionLog] a
	WHERE a.IsProcessed = 1 AND  a.DASubscriptionActionTypeID = 8778 --notification email
	AND a.OrderNumber = m.APNO
) s 
OUTER APPLY (
	SELECT TOP 1 a.OrderNumber, a.ModifyDate
	FROM [Enterprise].[Subscription].[AssociateSubscriptionActionLog] a
	WHERE a.IsProcessed = 1 AND a.DASubscriptionActionTypeID = 8779 --notification email
	AND a.OrderNumber = m.APNO
) ms 
OUTER APPLY	 (
	SELECT TOP 1 a.APNO
	FROM #tblMainStage a
	Where a.IsActive = 0 AND a.DASubscriptionActionTypeID = 8778 --notification email
	AND  a.APNO = m.APNO
) nm
OUTER APPLY (
	SELECT COUNT(1) AS eduCredCount
	FROM dbo.EducationCredentials e
	JOIN Enterprise.[Staging].[ApplicantStage] s ON s.StagingApplicantId = e.StagingApplicantId
	WHERE m.APNO = s.ApplicantNumber
) edu
OUTER APPLY (
	SELECT COUNT(1) AS empCredCount
	FROM dbo.EmploymentCredentials e
	JOIN Enterprise.[Staging].[ApplicantStage] s ON s.StagingApplicantId = e.StagingApplicantId
	WHERE m.APNO = s.ApplicantNumber
) emp 
OUTER APPLY (
	SELECT COUNT(1) AS claimedCredCount
	FROM Precheck.Velocity.ClaimedCredentialsLog c
	WHERE m.APNO = c.APNO
) cc 
OUTER APPLY (
	SELECT top 1 APNO 
	FROM Precheck.Velocity.ClaimedCredentialsLog c
	WHERE m.APNO = c.APNO
)vc 


DROP TABLE #tblMainStage
DROP TABLE #tblMain

SET TRANSACTION ISOLATION LEVEL READ COMMITTED   
SET NOCOUNT OFF
END 
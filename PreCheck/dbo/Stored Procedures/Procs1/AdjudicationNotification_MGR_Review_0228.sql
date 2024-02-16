
-- =============================================
-- Author:		<Veena Ayyagari>
-- Create date: <Nov 17 2008>
-- Description:	<List of all apno which have their ClientAdjudicationStatus to be reviewed>
-- Modify BY: Joshua Ates
-- Modify Date: 2/24/2021
-- Description:	Moved subqueries in the where and select statments to joins.  Formatted code to be easier to read.  Added With(NoLock) to avoid some of the locking issues. 
-- Changed from unions to inserts for better performance.  Changed text lookups to int ID lookups to use indexes.  
-- EXEC [AdjudicationNotification_MGR_Review]
-- =============================================
CREATE PROCEDURE [dbo].[AdjudicationNotification_MGR_Review_0228]
	
AS
BEGIN
Create table #temptable
(
	Apno int,
	email varchar(50),
	Module varchar(30),
	Sectionid int,
	ClientAdjudicationStatus bit
)

BEGIN --This is the Criminal Section
	Insert into #temptable (Apno,Email,Module,Sectionid,Clientadjudicationstatus)
	SELECT 
 		 applAdjudicationAuditTrail.apno as Apno
		,MGR_Email AS Email
		,'Crim' as Module
		,sectionid
		,MAXclientadjudicationstatus AS ClientAdjudicationStatus
	FROM 
		applAdjudicationAuditTrail WITH(NOLOCK)
	INNER JOIN 
		APPL a WITH(NOLOCK)
		on applAdjudicationAuditTrail.apno = a.apno
	INNER JOIN 
		crim WITH(NOLOCK)
		ON applAdjudicationAuditTrail.sectionid=crim.crimid
	LEFT JOIN
		applsections WITH(NOLOCK)
		ON applsections.ApplSectionID = applAdjudicationAuditTrail.ApplSectionID
	LEFT JOIN
		(
			SELECT 
				APNO,
				max(clientadjudicationstatus) AS MAXclientadjudicationstatus 
			FROM crim WITH(NOLOCK)
			GROUP BY apno
		) as ClientAdjudicationStatus
		ON a.APNO = ClientAdjudicationStatus.APNO
	INNER JOIN
		(	
			SELECT apno, count(*) AS CrimCount
			FROM crim WITH(NOLOCK)
			WHERE isnull(ClientAdjudicationStatus,0) IN (3,4)
			GROUP BY
				APNO
			HAVING count(*)  > 0
		) CrimCount
		ON CrimCount.APNO = a.APNO 
	INNER JOIN
		(
			SELECT count(*) AuditTrailCount, APNO
			FROM applAdjudicationAuditTrail WITH(NOLOCK)
			WHERE 
				applsectionid = 5
			and NotifiedDate_MGR IS NOT NULL
			GROUP BY
				APNO
			HAVING count(*) = 0
		) AuditTrailCount
		ON AuditTrailCount.APNO = a.APNO
	INNER JOIN --schapyala on 5/11/2018 added P (more info needed) to be treated as a conclusive status for manager review
		(
			SELECT APNO, count(*) crimClearCount
			FROM crim WITH(NOLOCK)
			WHERE 
				isnull(clear,'0') NOT IN ('T','F','P')
			GROUP BY APNO
			HAVING count(*) = 0
		) crimClearCount
		ON  crimClearCount.apno = a.apno 
	WHERE 
		applsections.applsectionid= 5 
	AND a.inuse IS NULL 
	AND a.apstatus = 'P' 
	
END
BEGIN --This is the Sanction Check/MedInteg section
	Insert into #temptable (Apno,Email,Module,Sectionid,Clientadjudicationstatus) 
	SELECT 
		applAdjudicationAuditTrail.apno as Apno
		, MGR_Email AS Email
		,'MedInteg' as Module
		,sectionid
		,MedInteg.ClientAdjudicationStatus
	FROM 
		applAdjudicationAuditTrail WITH(NOLOCK) 
	INNER JOIN
		(
			SELECT apno FROM applAdjudicationAuditTrail WITH(NOLOCK) EXCEPT
			SELECT apno FROM applAdjudicationAuditTrail WITH(NOLOCK) WHERE reviewDate_CAM IS NULL and applsectionid=(SELECT applSectionid FROM applsections where applsections.applsectionid= 7 )
		)k ON k.apno=applAdjudicationAuditTrail.apno
	INNER JOIN 
		APPL a WITH(NOLOCK)
		ON k.apno = a.apno
	INNER JOIN 
		MedInteg WITH(NOLOCK)
		ON applAdjudicationAuditTrail.sectionid=MedInteg.apno
	LEFT JOIN
		applsections WITH(NOLOCK)
		ON applsections.ApplSectionID = applAdjudicationAuditTrail.ApplSectionID
	WHERE 
		applsections.applsectionid= 7
	AND ClientAdjudicationStatus IN (3,4) 
	AND  NotifiedDate_MGR IS NULL
	AND a.inuse is null AND a.apstatus = 'P'
END

BEGIN--This is the Employee Section
	Insert into #temptable (Apno,Email,Module,Sectionid,Clientadjudicationstatus) 
	SELECT 
		 applAdjudicationAuditTrail.apno as Apno
		,users.emailaddress  as Email
		,'Empl' as Module
		,sectionid
		,empl.ClientAdjudicationStatus
	FROM 
		applAdjudicationAuditTrail WITH(NOLOCK)
	INNER JOIN
		(
			SELECT apno FROM applAdjudicationAuditTrail WITH(NOLOCK) EXCEPT
			SELECT apno FROM applAdjudicationAuditTrail WITH(NOLOCK) WHERE reviewDate_CAM is null 
		)k 
		ON k.apno=applAdjudicationAuditTrail.apno
	INNER JOIN 
		empl WITH(NOLOCK) 
		ON applAdjudicationAuditTrail.sectionid=empl.emplid
	INNER JOIN 
		users WITH(NOLOCK) 
		ON users.userid=applAdjudicationAuditTrail.userid_MGR
	WHERE 
		applsectionid=1 
	AND ClientAdjudicationStatus IN (3,4) 
	AND  NotifiedDate_MGR IS NULL
END

BEGIN --This is the Education Section
	Insert into #temptable (Apno,Email,Module,Sectionid,Clientadjudicationstatus) 
	SELECT 
		 applAdjudicationAuditTrail.apno as Apno
		,users.emailaddress AS Email
		,'Educat' as Module
		,sectionid
		,educat.ClientAdjudicationStatus
	FROM 
		applAdjudicationAuditTrail
	INNER JOIN
		(
			SELECT apno FROM applAdjudicationAuditTrail WITH(NOLOCK) EXCEPT
			SELECT apno FROM applAdjudicationAuditTrail WITH(NOLOCK) WHERE reviewDate_CAM is null
		) AS k 
		ON k.apno	=	applAdjudicationAuditTrail.apno
	INNER JOIN 
		educat WITH(NOLOCK)
		ON applAdjudicationAuditTrail.sectionid=educat.educatid
	INNER JOIN 
		users WITH(NOLOCK)
		ON users.userid=applAdjudicationAuditTrail.userid_MGR
	WHERE 
		applsectionid=2 
	AND ClientAdjudicationStatus IN (3,4) 
	AND  NotifiedDate_MGR IS NULL
END

BEGIN --This is the Personal Reference Section
	Insert into #temptable (Apno,Email,Module,Sectionid,Clientadjudicationstatus) 
	SELECT applAdjudicationAuditTrail.apno as Apno,users.emailaddress AS Email,'PersRef' as Module,sectionid,PersRef.ClientAdjudicationStatus
	FROM applAdjudicationAuditTrail WITH(NOLOCK)
	INNER JOIN
		(
			SELECT apno FROM applAdjudicationAuditTrail EXCEPT
			SELECT apno FROM applAdjudicationAuditTrail WHERE reviewDate_CAM IS NULL
		) AS k 
		ON k.apno=applAdjudicationAuditTrail.apno
	INNER JOIN 
		PersRef WITH(NOLOCK)
		ON applAdjudicationAuditTrail.sectionid=PersRef.PersRefid
	INNER JOIN 
		users WITH(NOLOCK)
		ON users.userid=applAdjudicationAuditTrail.userid_MGR
	WHERE 
		applsectionid=3 
	AND ClientAdjudicationStatus IN (3,4) 
	AND NotifiedDate_MGR IS NULL
END

BEGIN--This is the Professional License Section
	Insert into #temptable (Apno,Email,Module,Sectionid,Clientadjudicationstatus) 
	SELECT 
		 applAdjudicationAuditTrail.apno as Apno
		,users.emailaddress AS Email
		,'ProfLic' as Module
		,sectionid
		,ProfLic.ClientAdjudicationStatus
	FROM 
		applAdjudicationAuditTrail WITH(NOLOCK)
	INNER JOIN
		(
			SELECT apno FROM applAdjudicationAuditTrail WITH(NOLOCK) EXCEPT
			SELECT apno FROM applAdjudicationAuditTrail WITH(NOLOCK) WHERE reviewDate_CAM is null
		)k 
		ON k.apno=applAdjudicationAuditTrail.apno
	INNER JOIN 
		ProfLic WITH(NOLOCK)
		ON applAdjudicationAuditTrail.sectionid=ProfLic.ProfLicid
	INNER JOIN 
		users WITH(NOLOCK)
		ON users.userid=applAdjudicationAuditTrail.userid_MGR
	WHERE 
		applsectionid=4 
	AND ClientAdjudicationStatus IN (3,4) 
	AND NotifiedDate_MGR IS NULL
END

BEGIN --This is the Motor Vehicle Report/DL section
	Insert into #temptable (Apno,Email,Module,Sectionid,Clientadjudicationstatus) 
	SELECT 
		 applAdjudicationAuditTrail.apno as Apno
		,users.emailaddress AS Email
		,'DL' as Module,sectionid
		,DL.ClientAdjudicationStatus
	 FROM 
		applAdjudicationAuditTrail  WITH(NOLOCK)
	INNER JOIN
		(
			SELECT apno FROM applAdjudicationAuditTrail WITH(NOLOCK) EXCEPT
			SELECT apno FROM applAdjudicationAuditTrail WITH(NOLOCK) WHERE reviewDate_CAM IS NULL
		) k 
		ON k.apno=applAdjudicationAuditTrail.apno
	INNER JOIN 
		DL WITH(NOLOCK)
		ON applAdjudicationAuditTrail.sectionid=DL.apno
	INNER JOIN 
		users WITH(NOLOCK)
		ON users.userid=applAdjudicationAuditTrail.userid_MGR
	WHERE 
		applsectionid=6 
	AND ClientAdjudicationStatus IN (3,4) 
	AND NotifiedDate_MGR is NULL
END

BEGIN -- This is the Credit Section
	Insert into #temptable (Apno,Email,Module,Sectionid,Clientadjudicationstatus) 
	SELECT 
		 applAdjudicationAuditTrail.apno as Apno
		,users.emailaddress AS Email
		,'Credit' AS Module
		,sectionid
		,Credit.ClientAdjudicationStatus
	 FROM 
		applAdjudicationAuditTrail WITH(NOLOCK)
	INNER JOIN
		(
			SELECT apno FROM applAdjudicationAuditTrail WITH(NOLOCK) EXCEPT
			SELECT apno FROM applAdjudicationAuditTrail WITH(NOLOCK) WHERE reviewDate_CAM IS NULL
		) k 
		ON k.apno=applAdjudicationAuditTrail.apno
	INNER JOIN 
		Credit WITH(NOLOCK)
		ON applAdjudicationAuditTrail.sectionid=Credit.apno
	INNER JOIN 
		users WITH(NOLOCK)
		ON users.userid=applAdjudicationAuditTrail.userid_MGR
	WHERE 
		applsectionid=8 
	AND ClientAdjudicationStatus IN (3,4) 
	AND  NotifiedDate_MGR IS NULL
END


BEGIN -- This is the PositiveID/SSN Search Section
	Insert into #temptable (Apno,Email,Module,Sectionid,Clientadjudicationstatus) 
	SELECT 
		 applAdjudicationAuditTrail.apno as Apno
		,users.emailaddress AS Email
		,'PositiveID' as Module
		,sectionid
		,Credit.ClientAdjudicationStatus
	 FROM 
		applAdjudicationAuditTrail WITH(NOLOCK)
	INNER JOIN
		(
			SELECT apno FROM applAdjudicationAuditTrail WITH(NOLOCK) EXCEPT
			SELECT apno FROM applAdjudicationAuditTrail WITH(NOLOCK) WHERE reviewDate_CAM is null
		) k 
		ON k.apno=applAdjudicationAuditTrail.apno
	INNER JOIN 
		Credit WITH(NOLOCK)
		ON applAdjudicationAuditTrail.sectionid=Credit.apno
	INNER JOIN 
		users WITH(NOLOCK)
		ON users.userid=applAdjudicationAuditTrail.userid_MGR
	WHERE 
		applsectionid=9 
	AND ClientAdjudicationStatus IN (3,4) 
	AND Credit.RepType='S' 
	AND NotifiedDate_MGR IS NULL
END

SELECT DISTINCT
	 Apno
	,email
	,Module
	,Sectionid
	,ClientAdjudicationStatus
FROM #temptable 
ORDER BY 
	 Email
	,Apno
	,Module
	,Sectionid

DROP TABLE #temptable
END
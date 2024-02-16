
-- =============================================
-- Author:		<Veena Ayyagari>
-- Create date: <Nov 17 2008>
-- Description:	<List of all apno which have their ClientAdjudicationStatus to be reviewed>
-- =============================================
CREATE PROCEDURE [dbo].[AdjudicationNotification_MGR_Review]
	
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

Insert into #temptable (Apno,Email,Module,Sectionid,Clientadjudicationstatus)
(
--This is the Criminal Section

SELECT applAdjudicationAuditTrail.apno as Apno,(SELECT MGR_Email FROM applsections where Section='Crim') AS Email,'Crim' as Module,sectionid,(select max(clientadjudicationstatus) from crim where apno = a.apno) as ClientAdjudicationStatus
 FROM applAdjudicationAuditTrail
--CAM Review does not exist on the criminal records so bypass criteria -cchaupin
--	INNER JOIN
--	(
--	SELECT apno FROM applAdjudicationAuditTrail EXCEPT
--	SELECT apno FROM applAdjudicationAuditTrail WHERE reviewDate_CAM IS NULL and applsectionid=(SELECT applSectionid FROM applsections where Section='Crim')
--	)k ON k.apno=applAdjudicationAuditTrail.apno
INNER JOIN APPL a on applAdjudicationAuditTrail.apno = a.apno
INNER JOIN crim ON applAdjudicationAuditTrail.sectionid=crim.crimid
WHERE applsectionid=(SELECT applSectionid FROM applsections where Section='Crim') AND (select count(*) from crim where apno = a.apno and isnull(ClientAdjudicationStatus,0) IN (3,4)) > 0
 AND  (select count(*) from applAdjudicationAuditTrail where apno = a.apno and applsectionid = (SELECT applSectionid FROM applsections where Section='Crim') and NotifiedDate_MGR is not NULL) = 0 
AND a.inuse is null AND a.apstatus = 'P' and (select count(*) from crim where apno = a.apno 
and isnull(clear,'0') not in ('T','F','P')) = 0 --schapyala on 5/11/2018 added P (more info needed) to be treated as a conclusive status for manager review
--This is the Sanction Check/MedInteg section
UNION
(
SELECT applAdjudicationAuditTrail.apno as Apno,(SELECT MGR_Email FROM applsections where Section='MedInteg') AS Email,'MedInteg' as Module,sectionid,MedInteg.ClientAdjudicationStatus
 FROM applAdjudicationAuditTrail 
	INNER JOIN
	(
	SELECT apno FROM applAdjudicationAuditTrail EXCEPT
	SELECT apno FROM applAdjudicationAuditTrail WHERE reviewDate_CAM IS NULL and applsectionid=(SELECT applSectionid FROM applsections where Section='MedInteg')
	)k ON k.apno=applAdjudicationAuditTrail.apno
INNER JOIN APPL a on k.apno = a.apno
INNER JOIN MedInteg ON applAdjudicationAuditTrail.sectionid=MedInteg.apno
WHERE applsectionid=(SELECT applSectionid FROM applsections where Section='MedInteg') AND ClientAdjudicationStatus IN (3,4) AND  NotifiedDate_MGR IS NULL
AND a.inuse is null AND a.apstatus = 'P'
)

--This is the Employee Section
UNION
(
SELECT applAdjudicationAuditTrail.apno as Apno,users.emailaddress  as Email,'Empl' as Module,sectionid,empl.ClientAdjudicationStatus
 FROM applAdjudicationAuditTrail 
INNER JOIN
	(
	SELECT apno FROM applAdjudicationAuditTrail EXCEPT
	SELECT apno FROM applAdjudicationAuditTrail WHERE reviewDate_CAM is null )k ON k.apno=applAdjudicationAuditTrail.apno
INNER JOIN empl ON applAdjudicationAuditTrail.sectionid=empl.emplid
INNER JOIN users ON users.userid=applAdjudicationAuditTrail.userid_MGR
WHERE applsectionid=1 AND ClientAdjudicationStatus IN (3,4) AND  NotifiedDate_MGR IS NULL
)
--This is the Education Section
UNION
(
SELECT applAdjudicationAuditTrail.apno as Apno,users.emailaddress AS Email,'Educat' as Module,sectionid,educat.ClientAdjudicationStatus
 FROM applAdjudicationAuditTrail
	INNER JOIN
	(
	SELECT apno FROM applAdjudicationAuditTrail EXCEPT
	SELECT apno FROM applAdjudicationAuditTrail WHERE reviewDate_CAM is null)k ON k.apno=applAdjudicationAuditTrail.apno
INNER JOIN educat ON applAdjudicationAuditTrail.sectionid=educat.educatid
INNER JOIN users ON users.userid=applAdjudicationAuditTrail.userid_MGR
WHERE applsectionid=2 AND ClientAdjudicationStatus IN (3,4) AND  NotifiedDate_MGR is NULL
) 
--This is the Personal Reference Section
UNION
(
SELECT applAdjudicationAuditTrail.apno as Apno,users.emailaddress AS Email,'PersRef' as Module,sectionid,PersRef.ClientAdjudicationStatus
 FROM applAdjudicationAuditTrail
	INNER JOIN
	(
	SELECT apno FROM applAdjudicationAuditTrail EXCEPT
	SELECT apno FROM applAdjudicationAuditTrail WHERE reviewDate_CAM IS NULL)k ON k.apno=applAdjudicationAuditTrail.apno
INNER JOIN PersRef ON applAdjudicationAuditTrail.sectionid=PersRef.PersRefid
INNER JOIN users ON users.userid=applAdjudicationAuditTrail.userid_MGR
WHERE applsectionid=3 AND ClientAdjudicationStatus IN (3,4) AND  NotifiedDate_MGR IS NULL
)
--This is the Professional License Section
UNION
(
SELECT applAdjudicationAuditTrail.apno as Apno,users.emailaddress AS Email,'ProfLic' as Module,sectionid,ProfLic.ClientAdjudicationStatus
 FROM applAdjudicationAuditTrail
	INNER JOIN
	(
	SELECT apno FROM applAdjudicationAuditTrail EXCEPT
	SELECT apno FROM applAdjudicationAuditTrail WHERE reviewDate_CAM is null)k ON k.apno=applAdjudicationAuditTrail.apno
INNER JOIN ProfLic ON applAdjudicationAuditTrail.sectionid=ProfLic.ProfLicid
INNER JOIN users ON users.userid=applAdjudicationAuditTrail.userid_MGR
WHERE applsectionid=4 AND ClientAdjudicationStatus IN (3,4) AND  NotifiedDate_MGR IS NULL
)

--This is the Motor Vehicle Report/DL section
UNION
(
SELECT applAdjudicationAuditTrail.apno as Apno,users.emailaddress AS Email,'DL' as Module,sectionid,DL.ClientAdjudicationStatus
 FROM applAdjudicationAuditTrail 
	INNER JOIN
	(
	SELECT apno FROM applAdjudicationAuditTrail EXCEPT
	SELECT apno FROM applAdjudicationAuditTrail WHERE reviewDate_CAM IS NULL)k ON k.apno=applAdjudicationAuditTrail.apno
INNER JOIN DL ON applAdjudicationAuditTrail.sectionid=DL.apno
INNER JOIN users ON users.userid=applAdjudicationAuditTrail.userid_MGR
WHERE applsectionid=6 AND ClientAdjudicationStatus IN (3,4) AND  NotifiedDate_MGR is NULL
)

-- This is the Credit Section
UNION
(
SELECT applAdjudicationAuditTrail.apno as Apno,users.emailaddress AS Email,'Credit' AS Module,sectionid,Credit.ClientAdjudicationStatus
 FROM applAdjudicationAuditTrail
	 INNER JOIN
	(
	SELECT apno FROM applAdjudicationAuditTrail EXCEPT
	SELECT apno FROM applAdjudicationAuditTrail WHERE reviewDate_CAM IS NULL)k ON k.apno=applAdjudicationAuditTrail.apno
INNER JOIN Credit ON applAdjudicationAuditTrail.sectionid=Credit.apno
INNER JOIN users ON users.userid=applAdjudicationAuditTrail.userid_MGR
WHERE applsectionid=8 AND ClientAdjudicationStatus IN (3,4) AND  NotifiedDate_MGR is NULL
)

-- This is the PositiveID/SSN Search Section
UNION
(
SELECT applAdjudicationAuditTrail.apno as Apno,users.emailaddress AS Email
,'PositiveID' as Module,sectionid,Credit.ClientAdjudicationStatus
 FROM applAdjudicationAuditTrail 
	INNER JOIN
	(
	SELECT apno FROM applAdjudicationAuditTrail EXCEPT
	SELECT apno FROM applAdjudicationAuditTrail WHERE reviewDate_CAM is null)k ON k.apno=applAdjudicationAuditTrail.apno
INNER JOIN Credit ON applAdjudicationAuditTrail.sectionid=Credit.apno
INNER JOIN users ON users.userid=applAdjudicationAuditTrail.userid_MGR
WHERE applsectionid=9 AND ClientAdjudicationStatus IN (3,4) AND Credit.RepType='S' AND NotifiedDate_MGR is NULL
)


)



--UPDATE ApplAdjudicationAuditTrail set NotifiedDate_MGR='1/1/1900' 
--FROM #temptable t INNER JOIN 
--ApplAdjudicationAuditTrail a ON t.apno=a.apno AND a.Sectionid=t.Sectionid


SELECT * FROM #temptable order by Email,Apno,Module,Sectionid

DROP TABLE #temptable
END
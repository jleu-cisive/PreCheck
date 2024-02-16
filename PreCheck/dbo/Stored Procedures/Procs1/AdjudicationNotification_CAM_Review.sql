


-- =============================================
-- Author:		<veena Ayyagari>
-- Create date: <Nov 12 2008>
-- Description:	<List of all applications whose modules are final>
-- =============================================
CREATE PROCEDURE [dbo].[AdjudicationNotification_CAM_Review] 
AS
SET NOCOUNT ON;

DECLARE @applSectionid  INT

CREATE TABLE #ModuleTbl  (Apno int NOT NULL ,
Module  Varchar(50) NOT NULL,
email   Varchar(50) NULL,
Stat Varchar(3) NULL)

CREATE TABLE #Crim
(Apno		int NOT NULL,
ApplSectionID int NOT NULL,
Sectionid int NULL,
Email varchar(50) NULL)

CREATE TABLE #Educat
(Apno		int NOT NULL,
ApplSectionID int NOT NULL,
Sectionid int NULL,
Email varchar(50) NULL)

CREATE TABLE #Employee
(Apno		int NOT NULL,
ApplSectionID int NOT NULL,
Sectionid int NULL,
Email varchar(50) NULL)

CREATE TABLE #License
(Apno		int NOT NULL,
ApplSectionID int NOT NULL,
Sectionid int NULL,
Email varchar(50) NULL)

CREATE TABLE #Reference
(Apno		int NOT NULL,
ApplSectionID int NOT NULL,
Sectionid int NULL,
Email varchar(50) NULL)

CREATE TABLE #Credit
(Apno		int NOT NULL,
ApplSectionID int NOT NULL,
Sectionid int NULL,
Email varchar(50) NULL)

CREATE TABLE #Motor
(Apno		int NOT NULL,
ApplSectionID int NOT NULL,
Sectionid int NULL,
Email varchar(50) NULL)

CREATE TABLE #SSN
(Apno		int NOT NULL,
ApplSectionID int NOT NULL,
Sectionid int NULL,
Email varchar(50) NULL)

CREATE TABLE #MedInteg
(Apno		int NOT NULL,
ApplSectionID int NOT NULL,
Sectionid int NULL,
Email varchar(50) NULL)

CREATE TABLE #TempTable
(Apno int,
ApplSectionID int,
sectionid int,
email varchar(50))

CREATE CLUSTERED INDEX IX_TempTable_1 ON #TempTable(ApplSectionID,Apno)

-- CRIM Section

SELECT @applSectionid = applSectionid from applsections where Section='Crim'

INSERT INTO #ModuleTbl  
SELECT appl.apno,'Crim' AS Module,users.emailaddress, [clear] FROM appl
INNER JOIN clientconfiguration ON clientconfiguration.clno=appl.clno
INNER JOIN crim ON crim.apno=appl.apno
inner join Client on appl.clno = Client.clno
INNER JOIN users ON Client.CAM=users.userid
LEFT OUTER JOIN applAdjudicationAuditTrail AAAT 
ON appl.apno  = AAAT.apno AND AAAT.applsectionid = @applSectionid
--ON Cast(appl.apno AS varchar)+cast('5' as varchar) = Cast(AAAT.apno AS varchar)+cast(AAAT.applsectionid as varchar)
WHERE AAAT.ApplAdjudicationAuditTrailID IS NULL AND clientconfiguration.ConfigurationKey='AdjudicationProcess' AND clientconfiguration.value='True' 
AND appl.inuse IS NULL AND appl.apstatus='P'


INSERT INTO #Crim(Apno,ApplSectionID,sectionID,Email)
SELECT p.apno,@applSectionid AS ApplSectionID, crim.crimid as SectionID,p.emailaddress as Email 
from crim 
INNER JOIN 
(SELECT apno,Module,email as emailaddress FROM #ModuleTbl EXCEPT 
SELECT apno,Module,email  FROM #ModuleTbl WHERE ISNULL(Stat,'R') NOT IN ('T','F')) P
ON p.apno=crim.apno where crim.ishidden=0

UNION 
----This is for Crim Section With Hits (MD Anderson)
SELECT p.apno,@applSectionid AS ApplSectionID, crim.crimid as SectionID,p.emailaddress as Email 
from crim 
INNER JOIN 
(SELECT appl.apno,'Crim' AS Module,users.emailaddress FROM appl
INNER JOIN clientconfiguration ON clientconfiguration.clno=appl.clno
INNER JOIN crim ON crim.apno=appl.apno
inner join Client on appl.clno = Client.clno
INNER JOIN users ON Client.CAM=users.userid
--INNER JOIN users ON appl.userid=users.userid
LEFT OUTER JOIN applAdjudicationAuditTrail AAAT 
--ON Cast(appl.apno AS varchar)+cast(@applsectionid as varchar) = Cast(AAAT.apno AS varchar)+cast(AAAT.applsectionid as varchar)
ON appl.apno  = AAAT.apno AND AAAT.applsectionid = @applSectionid
WHERE AAAT.ApplAdjudicationAuditTrailID IS NULL AND clientconfiguration.ConfigurationKey='Notify_CrimSectionComplete_WithHits' AND clientconfiguration.value='True' 
AND appl.inuse IS NULL AND appl.apstatus='P'
AND ISNULL(clear,'R') IN ('P','F') 
)P on p.apno=crim.apno 
WHERE crim.ishidden=0


--This is for Education Section
TRUNCATE TABLE #ModuleTbl
SELECT @applSectionid = applSectionid from applsections where Section='Educat'

INSERT INTO #ModuleTbl 
SELECT appl.apno,'Educat' AS Module,users.emailaddress, sectstat FROM appl
INNER JOIN clientconfiguration ON clientconfiguration.clno=appl.clno
INNER JOIN educat ON educat.apno=appl.apno
inner join Client on appl.clno = Client.clno
INNER JOIN users ON Client.CAM=users.userid
--INNER JOIN users ON appl.userid=users.userid
LEFT OUTER JOIN applAdjudicationAuditTrail AAAT 
--ON Cast(appl.apno AS varchar)+cast(@applsectionid as varchar) = Cast(AAAT.apno AS varchar)+cast(AAAT.applsectionid as varchar)
ON appl.apno  = AAAT.apno AND AAAT.applsectionid = @applSectionid
WHERE AAAT.ApplAdjudicationAuditTrailID IS NULL AND clientconfiguration.ConfigurationKey='AdjudicationProcess' AND clientconfiguration.value='True' 
AND appl.inuse IS NULL AND appl.apstatus='P'

INSERT INTO #Educat(Apno,ApplSectionID,sectionID,Email)
SELECT p.apno,@applSectionid AS ApplSectionID, educat.educatid as SectionID,p.emailaddress as Email 
FROM dbo.educat 
INNER JOIN 
(SELECT apno,Module,email as emailaddress FROM #ModuleTbl EXCEPT 
SELECT apno,Module,email  FROM #ModuleTbl WHERE ISNULL(Stat,'0') IN ('0','1','2','3','4','5','8','9','A','B')) P
ON p.apno=educat.apno 
WHERE educat.ishidden=0 AND educat.isOnReport=1

--The Employee Section
TRUNCATE TABLE #ModuleTbl
SELECT @applSectionid = applSectionid from applsections where Section='Empl'

INSERT INTO #ModuleTbl 
SELECT appl.apno,'Empl' AS Module,users.emailaddress, sectstat FROM appl
INNER JOIN clientconfiguration ON clientconfiguration.clno=appl.clno
INNER JOIN Empl ON Empl.apno=appl.apno
inner join Client on appl.clno = Client.clno
INNER JOIN users ON Client.CAM=users.userid
--INNER JOIN users ON appl.userid=users.userid
LEFT OUTER JOIN applAdjudicationAuditTrail AAAT 
--ON Cast(appl.apno AS varchar)+cast(@applsectionid as varchar) = Cast(AAAT.apno AS varchar)+cast(AAAT.applsectionid as varchar)
ON appl.apno  = AAAT.apno AND AAAT.applsectionid = @applSectionid
WHERE AAAT.ApplAdjudicationAuditTrailID IS NULL AND clientconfiguration.ConfigurationKey='AdjudicationProcess' AND clientconfiguration.value='True' 
AND appl.inuse IS NULL AND appl.apstatus='P'

INSERT INTO #Employee(Apno,ApplSectionID,sectionID,Email)
SELECT p.apno,@applSectionid AS ApplSectionID, Empl.emplid as SectionID,p.emailaddress as Email 
from Empl 
INNER JOIN 
(SELECT apno,Module,email as emailaddress FROM #ModuleTbl EXCEPT 
SELECT apno,Module,email  FROM #ModuleTbl WHERE ISNULL(Stat,'0') IN ('0','1','2','3','4','5','8','9','A','B')) P
ON p.apno=Empl.apno 
WHERE Empl.ishidden=0 AND Empl.isOnReport=1

-- THIS IS LICENSE SECTION
TRUNCATE TABLE #ModuleTbl
SELECT @applSectionid = applSectionid from applsections where Section='Proflic'

INSERT INTO #ModuleTbl 
SELECT appl.apno,'Proflic' AS Module,users.emailaddress, sectstat FROM appl
INNER JOIN clientconfiguration ON clientconfiguration.clno=appl.clno
INNER JOIN Proflic ON Proflic.apno=appl.apno
inner join Client on appl.clno = Client.clno
INNER JOIN users ON Client.CAM=users.userid
--INNER JOIN users ON appl.userid=users.userid
LEFT OUTER JOIN applAdjudicationAuditTrail AAAT 
--ON Cast(appl.apno AS varchar)+cast(@applsectionid as varchar) = Cast(AAAT.apno AS varchar)+cast(AAAT.applsectionid as varchar)
ON appl.apno  = AAAT.apno AND AAAT.applsectionid = @applSectionid
WHERE AAAT.ApplAdjudicationAuditTrailID IS NULL AND clientconfiguration.ConfigurationKey='AdjudicationProcess' AND clientconfiguration.value='True' 
AND appl.inuse IS NULL AND appl.apstatus='P'

INSERT INTO #License(Apno,ApplSectionID,sectionID,Email)
SELECT p.apno,@applSectionid AS ApplSectionID, Proflic.ProfLicID as SectionID,p.emailaddress as Email 
from Proflic 
INNER JOIN 
(SELECT apno,Module,email as emailaddress FROM #ModuleTbl EXCEPT 
SELECT apno,Module,email  FROM #ModuleTbl WHERE ISNULL(Stat,'0') IN ('0','1','2','3','4','5','8','9','A','7')) P
ON p.apno=Proflic.apno 
WHERE Proflic.ishidden=0 AND Proflic.isOnReport=1

--THIS IS THE REFERENCE SECTION
TRUNCATE TABLE #ModuleTbl
SELECT @applSectionid = applSectionid from applsections where Section='PersRef'

INSERT INTO #ModuleTbl 
SELECT appl.apno,'PersRef' AS Module,users.emailaddress, sectstat FROM appl
INNER JOIN clientconfiguration ON clientconfiguration.clno=appl.clno
INNER JOIN Persref ON Persref.apno=appl.apno
inner join Client on appl.clno = Client.clno
INNER JOIN users ON Client.CAM=users.userid
--INNER JOIN users ON appl.userid=users.userid
LEFT OUTER JOIN applAdjudicationAuditTrail AAAT 
--ON Cast(appl.apno AS varchar)+cast(@applsectionid as varchar) = Cast(AAAT.apno AS varchar)+cast(AAAT.applsectionid as varchar)
ON appl.apno  = AAAT.apno AND AAAT.applsectionid = @applSectionid
WHERE AAAT.ApplAdjudicationAuditTrailID IS NULL AND clientconfiguration.ConfigurationKey='AdjudicationProcess' AND clientconfiguration.value='True' 
AND appl.inuse IS NULL AND appl.apstatus='P'

INSERT INTO #Reference(Apno,ApplSectionID,sectionID,Email)
SELECT p.apno,@applSectionid AS ApplSectionID, Persref.Persrefid as SectionID,p.emailaddress as Email 
from Persref 
INNER JOIN 
(SELECT apno,Module,email as emailaddress FROM #ModuleTbl EXCEPT 
SELECT apno,Module,email  FROM #ModuleTbl WHERE ISNULL(Stat,'0') IN ('0','1','2','3','4','5','7','8','9','A','B')) P
ON p.apno=Persref.apno 
WHERE Persref.ishidden=0 AND Persref.isOnReport=1

-- THIS IS THE CREDIT SECTION
TRUNCATE TABLE #ModuleTbl
SELECT @applSectionid = applSectionid from applsections where Section='Credit'

INSERT INTO #ModuleTbl 
SELECT appl.apno,'Credit' AS Module,users.emailaddress, sectstat FROM appl
INNER JOIN clientconfiguration ON clientconfiguration.clno=appl.clno
INNER JOIN Credit ON Credit.apno=appl.apno
inner join Client on appl.clno = Client.clno
INNER JOIN users ON Client.CAM=users.userid
--INNER JOIN users ON appl.userid=users.userid
LEFT OUTER JOIN applAdjudicationAuditTrail AAAT 
--ON Cast(appl.apno AS varchar)+cast(@applsectionid as varchar) = Cast(AAAT.apno AS varchar)+cast(AAAT.applsectionid as varchar)
ON appl.apno  = AAAT.apno AND AAAT.applsectionid = @applSectionid
WHERE AAAT.ApplAdjudicationAuditTrailID IS NULL AND clientconfiguration.ConfigurationKey='AdjudicationProcess' AND clientconfiguration.value='True' 
AND appl.inuse IS NULL AND appl.apstatus='P'

INSERT INTO #Credit(Apno,ApplSectionID,sectionID,Email)
SELECT p.apno,@applSectionid AS ApplSectionID, p.apno as SectionID,p.emailaddress as Email 
from Credit 
INNER JOIN 
(SELECT apno,Module,email as emailaddress FROM #ModuleTbl EXCEPT 
SELECT apno,Module,email  FROM #ModuleTbl WHERE ISNULL(Stat,'0') IN ('0','1','2','3','4','5','7','8','9','A','B')) P
ON p.apno=Credit.apno 
WHERE Credit.ishidden=0 AND Credit.RepType='C'

--THIS IS Motor Vehicle Report SECTION
TRUNCATE TABLE #ModuleTbl
SELECT @applSectionid = applSectionid from applsections where Section='DL'

INSERT INTO #ModuleTbl 
SELECT appl.apno,'DL' AS Module,users.emailaddress, sectstat FROM appl
INNER JOIN clientconfiguration ON clientconfiguration.clno=appl.clno
INNER JOIN DL ON DL.apno=appl.apno
inner join Client on appl.clno = Client.clno
INNER JOIN users ON Client.CAM=users.userid
--INNER JOIN users ON appl.userid=users.userid
LEFT OUTER JOIN applAdjudicationAuditTrail AAAT 
--ON Cast(appl.apno AS varchar)+cast(@applsectionid as varchar) = Cast(AAAT.apno AS varchar)+cast(AAAT.applsectionid as varchar)
ON appl.apno  = AAAT.apno AND AAAT.applsectionid = @applSectionid
WHERE AAAT.ApplAdjudicationAuditTrailID IS NULL AND clientconfiguration.ConfigurationKey='AdjudicationProcess' AND clientconfiguration.value='True' 
AND appl.inuse IS NULL AND appl.apstatus='P'

INSERT INTO #Motor(Apno,ApplSectionID,sectionID,Email)
SELECT p.apno,@applSectionid AS ApplSectionID, p.apno as SectionID,p.emailaddress as Email 
from DL 
INNER JOIN 
(SELECT apno,Module,email as emailaddress FROM #ModuleTbl EXCEPT 
SELECT apno,Module,email  FROM #ModuleTbl WHERE ISNULL(Stat,'0') IN ('0','1','2','3','4','5','7','8','9','A','B')) P
ON p.apno=DL.apno 
WHERE DL.ishidden=0 

--THIS IS THE SSN SEARCH/POSITIVEID SECTION
TRUNCATE TABLE #ModuleTbl
SELECT @applSectionid = applSectionid from applsections where Section='PositiveID'

INSERT INTO #ModuleTbl 
SELECT appl.apno,'Credit' AS Module,users.emailaddress, sectstat FROM appl
INNER JOIN clientconfiguration ON clientconfiguration.clno=appl.clno
INNER JOIN Credit ON Credit.apno=appl.apno
inner join Client on appl.clno = Client.clno
INNER JOIN users ON Client.CAM=users.userid
--INNER JOIN users ON appl.userid=users.userid
LEFT OUTER JOIN applAdjudicationAuditTrail AAAT 
--ON Cast(appl.apno AS varchar)+cast(@applsectionid as varchar) = Cast(AAAT.apno AS varchar)+cast(AAAT.applsectionid as varchar)
ON appl.apno  = AAAT.apno AND AAAT.applsectionid = @applSectionid
WHERE AAAT.ApplAdjudicationAuditTrailID IS NULL AND clientconfiguration.ConfigurationKey='AdjudicationProcess' AND clientconfiguration.value='True' 
AND appl.inuse IS NULL AND appl.apstatus='P'

INSERT INTO #SSN(Apno,ApplSectionID,sectionID,Email)
SELECT p.apno,@applSectionid AS ApplSectionID, p.apno as SectionID,p.emailaddress as Email 
from Credit 
INNER JOIN 
(SELECT apno,Module,email as emailaddress FROM #ModuleTbl EXCEPT 
SELECT apno,Module,email  FROM #ModuleTbl WHERE ISNULL(Stat,'0') IN ('0','1','2','3','4','5','7','8','9','A','B')) P
ON p.apno=Credit.apno 
WHERE Credit.ishidden=0 AND Credit.RepType='S'

--THIS IS THE SANCTION CHECK SECTION
TRUNCATE TABLE #ModuleTbl
SELECT @applSectionid = applSectionid from applsections where Section='MedInteg'

INSERT INTO #ModuleTbl 
SELECT appl.apno,'MedInteg' AS Module,users.emailaddress, sectstat FROM appl
INNER JOIN clientconfiguration ON clientconfiguration.clno=appl.clno
INNER JOIN MedInteg ON MedInteg.apno=appl.apno
inner join Client on appl.clno = Client.clno
INNER JOIN users ON Client.CAM=users.userid
--INNER JOIN users ON appl.userid=users.userid
LEFT OUTER JOIN applAdjudicationAuditTrail AAAT 
ON appl.apno  = AAAT.apno AND AAAT.applsectionid = @applSectionid
--ON Cast(appl.apno AS varchar)+cast(@applsectionid as varchar) = Cast(AAAT.apno AS varchar)+cast(AAAT.applsectionid as varchar)
WHERE AAAT.ApplAdjudicationAuditTrailID IS NULL AND clientconfiguration.ConfigurationKey='AdjudicationProcess' AND clientconfiguration.value='True' 
AND appl.inuse IS NULL AND appl.apstatus='P'

INSERT INTO #MedInteg(Apno,ApplSectionID,sectionID,Email)
SELECT p.apno,@applSectionid AS ApplSectionID, p.apno as SectionID,p.emailaddress as Email 
from MedInteg 
INNER JOIN 
(SELECT apno,Module,email as emailaddress FROM #ModuleTbl EXCEPT 
SELECT apno,Module,email  FROM #ModuleTbl WHERE ISNULL(Stat,'0') IN ('0','1','2','3','4','5','6','8','9','A','B')) P
ON p.apno=MedInteg.apno 
WHERE MedInteg.ishidden=0 

DROP TABLE #ModuleTbl

INSERT INTO #TempTable
SELECT * FROM #Crim
UNION
SELECT * FROM #Educat
UNION
SELECT * FROM #Employee
UNION
SELECT * FROM #License
UNION
SELECT * FROM #Reference
UNION
SELECT * FROM #Credit
UNION
SELECT * FROM #Motor
UNION
SELECT * FROM #SSN
UNION
SELECT * FROM #MedInteg

----Inserting into ApplAdjudicationTrail
INSERT INTO ApplAdjudicationAuditTrail(apno,applsectionid,sectionid,UserID_MGR,UserID_Cam)
(
SELECT t.apno,t.Applsectionid,SectionID,a.userid_mgr,appl.userid 
FROM #Temptable t
INNER JOIN applsections a ON a.applsectionid=t.applsectionid
INNER JOIN Appl ON t.apno=appl.apno
)

--Selecting the values to send Email including the ones that failed previously
SELECT apno,t.section AS Module,sectionid,email FROM #temptable 
INNER JOIN applsections t ON #temptable.applsectionid=t.applsectionid 
--PREVIOUSLY FAILED RECORDS
UNION
(
SELECT ApplAdjudicationAuditTrail.Apno,p.section as Module,SectionId,u.emailaddress as Email from ApplAdjudicationAuditTrail
 INNER JOIN users u on ApplAdjudicationAuditTrail.userid_cam=u.userid
 INNER JOIN ApplSections p on p.ApplSectionid=appladjudicationAuditTrail.ApplSectionid 
 inner join appl a on a.apno = ApplAdjudicationAuditTrail.apno 
WHERE NotifiedDate_Cam IS NULL and a.inuse is null
)
order by email,apno,module,sectionid

--Deleting the temptable
DROP TABLE #temptable





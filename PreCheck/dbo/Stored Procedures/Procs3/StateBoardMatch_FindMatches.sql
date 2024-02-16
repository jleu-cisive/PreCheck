


















CREATE PROCEDURE [dbo].[StateBoardMatch_FindMatches]
(
	--InputID can only takes a set of EmailReferenceIDs or StateBoardMatchIDs
	@InputID uniqueidentifier='00000000-0000-0000-0000-0000000000000000',

	--the following three parameters only used when an email is to be generated.
	@CurrentStage VARCHAR(200),
	@DateFrom DATETIME=null,
	@DateTo DATETIME=null

	/*
	@LicenseNumber VARCHAR(200)=null,
	@LicenseType VARCHAR(200)=null,
	@LicenseState VARCHAR(100)=null,
	@LicenseIsFromCredentCheck BIT=null,
	@LicenseIsFromBIS BIT=null,
	@LicenseActionDateFrom DATETIME=null,
	@LicenseActionDateTo DATETIME=NULL,

	@LastName VARCHAR(200)=null,
	@FirstName VARCHAR(200)=null,
	@SSN VARCHAR(200)=null,
	@ClientID INT=null,
	@FacilityID INT=null,

	DECLARE @CurrentStage VARCHAR(200)
	SET @CurrentStage='NoneSent'
	*/
)
AS

--==============================Tester=================================
/*
DECLARE @InputID uniqueidentifier
DECLARE @CurrentStage VARCHAR(200)
DECLARE @DateFrom DATETIME
DECLARE @DateTo DATETIME

SET @InputID='00000000-0000-0000-0000-0000000000000000'
SET @CurrentStage='NoneSent'
SET @DateFrom='2007-2-2'
SET @DateTo=NULL

EXEC [StateBoardMatch_FindMatches] @InputID, @CurrentStage, @DateFrom, @DateTo
*/
--=====================================================================

--======================Pre-Treatment of Parameters====================
SET @CurrentStage=LTRIM(RTRIM(@CurrentStage))
IF (@CurrentStage='' OR @CurrentStage IS NULL) SET @CurrentStage='All'
IF UPPER(@CurrentStage)='ALL'	SET @CurrentStage='All'
ELSE IF UPPER(@CurrentStage)='NONESENT'	SET @CurrentStage='NoneSent'
ELSE IF UPPER(@CurrentStage)='INITIALSENT'	SET @CurrentStage='InitialSent'
ELSE IF UPPER(@CurrentStage)='CREDENTIALED'	SET @CurrentStage='Credentialed'
ELSE IF UPPER(@CurrentStage)='FOLLOWUPSENT'	SET @CurrentStage='FollowUpSent'
ELSE RETURN

IF @DateFrom IS NULL SET @DateFrom= CAST('1900-1-1' AS DATETIME)
IF @DateTo IS NULL SET @DateTo= CAST('3000-1-1' AS DATETIME)
--=====================================================================

--======================Create @LicenseToBeSent====================
DECLARE @LicenseToBeSent TABLE 
(
	StateBoardMatchID INT NOT NULL,
	StateBoardDataID INT NOT NULL,
	TargetApplication VARCHAR(200) NOT NULL,
	TargetTableName VARCHAR(200) NOT NULL,
	TargetTableID INT NOT NULL,
	IndividualID INT NOT NULL, 
	IndividualSSN VARCHAR(100) NULL, 
	ClientID INT NOT NULL,
	ClientName VARCHAR(400) NULL,
	FacilityID INT NULL,
	FacilityName VARCHAR(400) NULL,
	DepartmentID INT NULL,
	DepartmentName VARCHAR(400) NULL,

	BoardSource VARCHAR(200) NULL,
	BoardSourceID INT NULL,
	BoardActionDate DATETIME NULL,
	BoardActionDescription VARCHAR(8000) NULL,

	BoardLastName VARCHAR(200) NULL,
	BoardFirstName VARCHAR(200) NULL,
	BoardLicenseNumber VARCHAR(200) NULL,
	BoardLicenseType VARCHAR(200) NULL,
	BoardLicenseState VARCHAR(100) NULL,
	SystemLastName VARCHAR(200) NULL,
	SystemFirstName VARCHAR(200) NULL,
	SystemLicenseNumber VARCHAR(200) NULL,
	SystemLicenseType VARCHAR(200) NULL, 
	SystemLicenseState VARCHAR(100) NULL,

	IsToBeSent BIT NOT NULL,
	IsCredentialed BIT NOT NULL,
	EmailReferenceID VARCHAR(200) NOT NULL,
	MatchingInsertedDateTime DATETIME NULL,
	InitialEmailSentDateTime DATETIME NULL,
	InitialEmailComment VARCHAR(4000) NULL,
	InitialEmailFailedReason VARCHAR(4000) NULL,
	FollowUpEmailSentDateTime DATETIME NULL,
	FollowUpEmailComment VARCHAR(4000) NULL,
	FollowUpEmailFailedReason VARCHAR(4000) NULL,
	ToResolveSetDateTime DATETIME NULL,
	ResolvedDateTime DATETIME NULL,
	LastSentStatus VARCHAR(100) NOT NULL,
	LastSentStage VARCHAR(100) NOT NULL
)
--SELECT * FROM @LicenseToBeSent
--=====================================================================

--====================Get Matches =====================
DECLARE @PassedInStateBoardMatchIDs TABLE
(	
	StateBoardMatchID int NOT NULL,
	EmailReferenceID VARCHAR(200) NOT NULL
)

IF @InputID='00000000-0000-0000-0000-0000000000000000'
	INSERT INTO @PassedInStateBoardMatchIDs
	SELECT 
		SBM.StateBoardMatchID,
		'000000000000'
	FROM dbo.StateBoardMatch AS SBM 
	WHERE (SBM.MatchingIsAMatch=1)
ELSE
BEGIN
	DECLARE @IsPassedInEmailReferenceIDs BIT 
	SELECT @IsPassedInEmailReferenceIDs=(CASE WHEN SBMIT.EmailReferenceID IS NULL THEN 0 ELSE 1 END) FROM dbo.StateBoardMatchIntermediateTable SBMIT WHERE SBMIT.InputID=@InputID

	IF @IsPassedInEmailReferenceIDs=1 
		INSERT INTO @PassedInStateBoardMatchIDs
		SELECT 
			SBEB.StateBoardMatchID, 
			SBMIT.EmailReferenceID 
		FROM dbo.StateBoardEmailBatch AS SBEB 
		INNER JOIN dbo.StateBoardEmailActivities AS SBEA ON SBEB.StateBoardEmailBatchID = SBEA.EmailBatchID
		INNER JOIN dbo.StateBoardMatchIntermediateTable SBMIT ON SBEA.EmailReferenceID = SBMIT.EmailReferenceID
		WHERE SBMIT.InputID=@InputID
	ELSE 
		INSERT INTO @PassedInStateBoardMatchIDs
		SELECT 
			SBMIT.StateBoardMatchID, 
			'000000000000'
		FROM dbo.StateBoardMatchIntermediateTable SBMIT
		WHERE SBMIT.InputID=@InputID
END 

SELECT DISTINCT SBM.*, PSBM.EmailReferenceID
INTO #FilteredStateBoardMatch
FROM dbo.StateBoardMatch AS SBM 
INNER JOIN @PassedInStateBoardMatchIDs PSBM ON SBM.StateBoardMatchID=PSBM.StateBoardMatchID 
WHERE (SBM.MatchingIsAMatch=1)
--==========================================

--==========================find the email for a license and an email type that latest success and latest fail if none success=====
SELECT SBEB.StateBoardMatchID, SBEA.EmailType, MAX(SBEA.EmailDateTime) AS MaxEmailDateTime
INTO #LatestSucessEmails
FROM dbo.StateBoardEmailActivities SBEA 
	INNER JOIN dbo.StateBoardEmailBatch SBEB ON SBEA.EmailBatchID=SBEB.StateBoardEmailBatchID
WHERE (SBEA.SendStatus='Sent' OR SBEA.SendStatus='DuplictateSent')
GROUP BY SBEB.StateBoardMatchID, SBEA.EmailType

SELECT SBEB.StateBoardMatchID, SBEA.EmailType, MAX(SBEA.EmailDateTime) AS MaxEmailDateTime
INTO #LatestUnsucessEmails
FROM dbo.StateBoardEmailActivities SBEA 
	INNER JOIN dbo.StateBoardEmailBatch SBEB ON SBEA.EmailBatchID=SBEB.StateBoardEmailBatchID
WHERE (SBEA.SendStatus='Failed' OR SBEA.SendStatus='Unknown')
GROUP BY SBEB.StateBoardMatchID, SBEA.EmailType

SELECT SBEA.*, LatestEmailActivites.Success, LatestEmailActivites.StateBoardMatchID
INTO #LatestEmailActivites
FROM dbo.StateBoardEmailActivities SBEA 
INNER JOIN
(
	SELECT *, 1 AS Success FROM #LatestSucessEmails
	UNION 
	SELECT *, 0 AS Success FROM #LatestUnsucessEmails 
	WHERE #LatestUnsucessEmails.StateBoardMatchID 
		NOT IN (SELECT #LatestSucessEmails.StateBoardMatchID FROM #LatestSucessEmails)
) LatestEmailActivites ON SBEA.EmailDateTime=LatestEmailActivites.MaxEmailDateTime AND SBEA.EmailType=LatestEmailActivites.EmailType
--==========================================================================

--=======================Get Licenses with extra information =====================
--MOST OF THING IS IDENTICAL TO THAT OF StateBoardMatch_Email, ESPECIALLY THE WHERE CLAUSE WHICH IS IDENTICAL OTHER THAN '--LEFT OUTER JOIN #ClientEmails'
INSERT INTO @LicenseToBeSent
SELECT 
	DISTINCT 
	SBM.StateBoardMatchID,
	SBM.StateBoardDataID,
	'CredentCheck',
	SBM.TargetTableName,
	SBM.TargetTableID,
	ER.EmployeeRecordID, 
	ER.SSN, 
	CL.CLNO,
	CL.Name,
	ER.FacilityID,
	FA.FacilityName,
	DA.DepartmentID,
	DA.DepartmentName,

	LA.SourceName,
	LA.StateBoardSourceID,
	SBFD.ActionDate,
	SBFD.Description,

	SBFD.LastName,
	SBFD.FirstName,
	SBFD.LicenseNumber,
	SBFD.LicenseType,
	SBFD.State,
	ER.Last,
	ER.First,
	LS.Number,
	LS.Type, 
	LS.IssuingState,

	1,
	(CASE WHEN SBM.MatchResolvedDateTime IS NULL THEN 0 ELSE 1 END),
	SBM.EmailReferenceID,
	SBM.MatchingInsertedDateTime,
	SBEAInitial.EmailDateTime,
	SBEAInitial.EmailComment,
	SBEAInitial.FailedReason,
	SBEAFollowUp.EmailDateTime,
	SBEAFollowUp.EmailComment,
	SBEAFollowUp.FailedReason,
	SBM.MatchToResolveSetDateTime,
	SBM.MatchResolvedDateTime,
	(CASE 
		WHEN SBEAInitial.EmailDateTime IS NOT NULL AND SBEAFollowUp.EmailDateTime IS NOT NULL AND SBM.MatchResolvedDateTime IS NOT NULL AND SBEAFollowUp.Success=1 THEN 'FollowUpSent'
		WHEN SBEAInitial.EmailDateTime IS NOT NULL AND SBEAFollowUp.EmailDateTime IS NOT NULL AND SBM.MatchResolvedDateTime IS NOT NULL AND SBEAFollowUp.Success=0 THEN 'FollowUpFailed'
		WHEN SBEAInitial.EmailDateTime IS NOT NULL AND SBEAFollowUp.EmailDateTime IS NULL AND SBEAInitial.Success=1 THEN 'InitialSent'
		WHEN SBEAInitial.EmailDateTime IS NOT NULL AND SBEAFollowUp.EmailDateTime IS NULL AND SBEAInitial.Success=0 THEN 'InitialFailed'
		WHEN SBEAInitial.EmailDateTime IS NULL AND SBEAFollowUp.EmailDateTime IS NULL THEN 'NoneSent'
		ELSE 'NoneSent'
	END),
	(CASE 
		WHEN SBEAInitial.EmailDateTime IS NOT NULL AND SBEAFollowUp.EmailDateTime IS NOT NULL AND SBM.MatchResolvedDateTime IS NOT NULL AND SBEAFollowUp.Success=1 THEN 'FollowUpSent'
		WHEN SBEAInitial.EmailDateTime IS NOT NULL AND SBEAFollowUp.EmailDateTime IS NOT NULL AND SBM.MatchResolvedDateTime IS NOT NULL AND SBEAFollowUp.Success=0 THEN 'Credentialed'
		WHEN SBEAInitial.EmailDateTime IS NOT NULL AND SBEAFollowUp.EmailDateTime IS NULL AND SBM.MatchResolvedDateTime IS NOT NULL THEN 'Credentialed'
		WHEN SBEAInitial.EmailDateTime IS NOT NULL AND SBEAFollowUp.EmailDateTime IS NULL AND SBM.MatchResolvedDateTime IS NULL AND SBEAInitial.Success=1 THEN 'InitialSent'
		WHEN SBEAInitial.EmailDateTime IS NOT NULL AND SBEAFollowUp.EmailDateTime IS NULL AND SBM.MatchResolvedDateTime IS NULL AND SBEAInitial.Success=0 THEN 'NoneSent'
		WHEN SBEAInitial.EmailDateTime IS NULL AND SBEAFollowUp.EmailDateTime IS NULL THEN 'NoneSent'
		ELSE 'NoneSent'
	END)
FROM #FilteredStateBoardMatch SBM
LEFT OUTER JOIN #LatestEmailActivites AS SBEAInitial ON SBM.StateBoardMatchID=SBEAInitial.StateBoardMatchID AND SBEAInitial.EmailType='Initial'
LEFT OUTER JOIN #LatestEmailActivites AS SBEAFollowUp ON SBM.StateBoardMatchID=SBEAFollowUp.StateBoardMatchID AND SBEAFollowUp.EmailType='FollowUp'
INNER JOIN StateBoardFinalData SBFD ON SBM.StateBoardDataID=SBFD.StateBoardFinalDataID
INNER JOIN VWLicenseAuthority LA ON SBFD.StateBoardSourceID=LA.StateBoardSourceID
INNER JOIN Rabbit.Hevn.dbo.License LS ON SBM.TargetTableID=LS.LicenseID
INNER JOIN Rabbit.Hevn.dbo.EmployeeRecord ER ON LS.EmployeeRecordID=ER.EmployeeRecordID
INNER JOIN Rabbit.Hevn.dbo.Client CL ON ER.EmployerID=CL.CLNO
LEFT OUTER JOIN Rabbit.Hevn.dbo.Facility FA ON FA.FacilityID=ER.FacilityID
LEFT OUTER JOIN Rabbit.Hevn.dbo.Department DA ON ER.DepartmentID=DA.DepartmentID
WHERE SBM.TargetTableName='License'  

INSERT INTO @LicenseToBeSent
SELECT 
	DISTINCT 
	SBM.StateBoardMatchID,
	SBM.StateBoardDataID,
	'BIS',
	SBM.TargetTableName,
	SBM.TargetTableID,
	AP.APNO, 
	AP.SSN, 
	CL.CLNO,
	CL.Name,
	NULL,
	NULL,
	NULL,
	NULL,

	LA.SourceName,
	LA.StateBoardSourceID,
	SBFD.ActionDate,
	SBFD.Description,

	SBFD.LastName,
	SBFD.FirstName,
	SBFD.LicenseNumber,
	SBFD.LicenseType,
	SBFD.State,
	AP.Last,
	AP.First,
	PL.Lic_No,
	PL.Lic_Type, 
	PL.State,

	1,
	(CASE WHEN SBM.MatchResolvedDateTime IS NULL THEN 0 ELSE 1 END),
	SBM.EmailReferenceID,
	SBM.MatchingInsertedDateTime,
	SBEAInitial.EmailDateTime,
	SBEAInitial.EmailComment,
	SBEAInitial.FailedReason,
	SBEAFollowUp.EmailDateTime,
	SBEAFollowUp.EmailComment,
	SBEAFollowUp.FailedReason,
	SBM.MatchToResolveSetDateTime,
	SBM.MatchResolvedDateTime,
	(CASE 
		WHEN SBEAInitial.EmailDateTime IS NOT NULL AND SBEAFollowUp.EmailDateTime IS NOT NULL AND SBM.MatchResolvedDateTime IS NOT NULL AND SBEAFollowUp.Success=1 THEN 'FollowUpSent'
		WHEN SBEAInitial.EmailDateTime IS NOT NULL AND SBEAFollowUp.EmailDateTime IS NOT NULL AND SBM.MatchResolvedDateTime IS NOT NULL AND SBEAFollowUp.Success=0 THEN 'FollowUpFailed'
		WHEN SBEAInitial.EmailDateTime IS NOT NULL AND SBEAFollowUp.EmailDateTime IS NULL AND SBEAInitial.Success=1 THEN 'InitialSent'
		WHEN SBEAInitial.EmailDateTime IS NOT NULL AND SBEAFollowUp.EmailDateTime IS NULL AND SBEAInitial.Success=0 THEN 'InitialFailed'
		WHEN SBEAInitial.EmailDateTime IS NULL AND SBEAFollowUp.EmailDateTime IS NULL THEN 'NoneSent'
		ELSE 'NoneSent'
	END),
	(CASE 
		WHEN SBEAInitial.EmailDateTime IS NOT NULL AND SBEAFollowUp.EmailDateTime IS NOT NULL AND SBM.MatchResolvedDateTime IS NOT NULL AND SBEAFollowUp.Success=1 THEN 'FollowUpSent'
		WHEN SBEAInitial.EmailDateTime IS NOT NULL AND SBEAFollowUp.EmailDateTime IS NOT NULL AND SBM.MatchResolvedDateTime IS NOT NULL AND SBEAFollowUp.Success=0 THEN 'Credentialed'
		WHEN SBEAInitial.EmailDateTime IS NOT NULL AND SBEAFollowUp.EmailDateTime IS NULL AND SBM.MatchResolvedDateTime IS NOT NULL THEN 'Credentialed'
		WHEN SBEAInitial.EmailDateTime IS NOT NULL AND SBEAFollowUp.EmailDateTime IS NULL AND SBM.MatchResolvedDateTime IS NULL AND SBEAInitial.Success=1 THEN 'InitialSent'
		WHEN SBEAInitial.EmailDateTime IS NOT NULL AND SBEAFollowUp.EmailDateTime IS NULL AND SBM.MatchResolvedDateTime IS NULL AND SBEAInitial.Success=0 THEN 'NoneSent'
		WHEN SBEAInitial.EmailDateTime IS NULL AND SBEAFollowUp.EmailDateTime IS NULL THEN 'NoneSent'
		ELSE 'NoneSent'
	END)
FROM #FilteredStateBoardMatch SBM
LEFT OUTER JOIN #LatestEmailActivites AS SBEAInitial ON SBM.StateBoardMatchID=SBEAInitial.StateBoardMatchID AND SBEAInitial.EmailType='Initial'
LEFT OUTER JOIN #LatestEmailActivites AS SBEAFollowUp ON SBM.StateBoardMatchID=SBEAFollowUp.StateBoardMatchID AND SBEAFollowUp.EmailType='FollowUp'
INNER JOIN StateBoardFinalData SBFD ON SBM.StateBoardDataID=SBFD.StateBoardFinalDataID
INNER JOIN VWLicenseAuthority LA ON SBFD.StateBoardSourceID=LA.StateBoardSourceID
INNER JOIN dbo.ProfLic PL ON SBM.TargetTableID=PL.ProfLicID
INNER JOIN dbo.Appl AP ON PL.Apno = AP.APNO
INNER JOIN Rabbit.Hevn.dbo.Client CL ON AP.CLNO=CL.CLNO
WHERE AP.ApStatus='F' AND SBM.TargetTableName='ProfLic'	
	--AND CLE.FacilityID IS NULL AND CLE.DepartmentID IS NULL --don't sent to Facility-Level and Department-Level Recipients, only send to Client-Level Recipient
--========================================================

--=================== Set FacilityID and DepartmentID for Licenses from BIS based on credentCheck=========================
UPDATE @LicenseToBeSent 
SET FacilityID=ER.FacilityID, FacilityName=FA.FacilityName, DepartmentID=DA.DepartmentID, DepartmentName=DA.DepartmentName
FROM @LicenseToBeSent LTB 
INNER JOIN dbo.Appl AP ON LTB.IndividualID = AP.APNO
INNER JOIN Rabbit.Hevn.dbo.EmployeeRecord ER ON ER.SSN=AP.SSN AND ER.DOB=AP.DOB AND ER.EmployerID=AP.CLNO
LEFT OUTER JOIN Rabbit.Hevn.dbo.Facility FA ON FA.FacilityID=ER.FacilityID
LEFT OUTER JOIN Rabbit.Hevn.dbo.Department DA ON ER.DepartmentID=DA.DepartmentID
WHERE LTB.TargetTableName='ProfLic'	
--========================================================

--===========================Apply Filters ======================
SELECT * FROM @LicenseToBeSent LTS
WHERE 
( 
	CASE 
		WHEN @CurrentStage='All' THEN 1
		WHEN LTS.LastSentStage=@CurrentStage THEN 1
		ELSE 0
	END
)=1 
AND 
(
	CASE
		WHEN @CurrentStage='All' THEN 1
		WHEN @CurrentStage='NoneSent' THEN (CASE WHEN LTS.MatchingInsertedDateTime>@DateFrom AND LTS.MatchingInsertedDateTime<@DateTo THEN 1 ELSE 0 END)
		WHEN @CurrentStage='InitialSent' THEN (CASE WHEN LTS.InitialEmailSentDateTime>@DateFrom AND LTS.InitialEmailSentDateTime<@DateTo THEN 1 ELSE 0 END)
		WHEN @CurrentStage='Credentialed' THEN (CASE WHEN LTS.ResolvedDateTime>@DateFrom AND LTS.ResolvedDateTime<@DateTo THEN 1 ELSE 0 END)
		WHEN @CurrentStage='FollowUpSent' THEN (CASE WHEN LTS.FollowUpEmailSentDateTime>@DateFrom AND LTS.FollowUpEmailSentDateTime<@DateTo THEN 1 ELSE 0 END)
		ELSE 1
	END
)=1
ORDER BY LTS.LastSentStatus, LTS.TargetApplication, LTS.BoardLastName
--========================================================

DROP TABLE #FilteredStateBoardMatch
DROP TABLE #LatestSucessEmails
DROP TABLE #LatestUnsucessEmails
DROP TABLE #LatestEmailActivites

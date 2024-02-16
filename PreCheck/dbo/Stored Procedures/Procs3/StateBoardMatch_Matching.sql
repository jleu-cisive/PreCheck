



CREATE PROCEDURE [dbo].[StateBoardMatch_Matching]
(
	@IncludeCredentCheck bit=1,
	@IncludeBIS bit=1,
	@IsMatchingPerfectMatches bit=1,
	@IncludeNewMatchesOnly bit=1,
	@InputID uniqueidentifier,

	@IncludeLicenseNumberInMatch bit=1,
	@IncludeLicenseTypeInMatch bit=1,
	@IncludeLicenseStateInMatch bit=1,
	@IncludeLastNameInMatch bit=0,
	@IncludeFirstNameInMatch bit=0,

	@NoOfLicensesToBeMatched int output,
	@NoOfLicensesMatched int output
)
AS
--==================Start of Specification======================
--Perfect matches are based on LicenseNumber, LicenseType, LicenseState
--Possible matches are based on LicenseType, LicenseState, LastName, FirstName
--Though this stored procedure enables the setting for Perfect Matching by set @IncludeXXX to exclude those three fields as mentioned above, in reality, it should always set three fields to be true
--It can be configurable for Possible Matching.
--However, we should emphasize that possible matching only operates on those licenses in actions from StateBoardFinalData to have empty license numbers. 
--		That is, if a license from StateBoardFinalData contains LicenseNumber, then it only applies to PerfectMatch testing.
--		If we want to include all for the PossibleMatch, change the 'INTO #FilteredStateBoardFinalData's (CASE WHEN) condition.
--Whether possible matches includes those rows with non-empty licenses is not determined yet, by default, I don't apply this case.

--@IncldueNewMatchesOnly is by defautlt set to 1, means existing matches will not be shown up
--If @IncldueNewMatchesOnly is set to 0, all the existing matches will be in the result set, and the existing matches information will be joined to show up in the result set.
--By default, use @IncldueNewMatchesOnly=1, so that the query can be speed up.

--The stored procedure may be able to be optimized
--==================End of Specification========================

--==============================Stored Procedure Tester=================================
/*
DECLARE @IncludeCredentCheck bit
DECLARE @IncludeBIS bit
DECLARE @IsMatchingPerfectMatches bit
DECLARE @InputID uniqueidentifier
DECLARE @IncludeLicenseNumberInMatch bit
DECLARE @IncludeLicenseTypeInMatch bit
DECLARE @IncludeLicenseStateInMatch bit
DECLARE @IncludeLastNameInMatch bit
DECLARE @IncludeFirstNameInMatch bit
DECLARE @IncldueNewMatchesOnly bit
DECLARE @NoOfLicensesToBeMatched int
DECLARE @NoOfLicensesMatched int

SET @IncludeCredentCheck=1
SET @IncludeBIS=1
SET @IsMatchingPerfectMatches=0
SET @InputID='00000000-0000-0000-0000-000000000000'
SET @IncludeLicenseNumberInMatch=1
SET @IncludeLicenseTypeInMatch=1
SET @IncludeLicenseStateInMatch=1
SET @IncludeLastNameInMatch=0
SET @IncludeFirstNameInMatch=0
SET @IncldueNewMatchesOnly=1

EXEC StateBoardMatch_Matching
	@IncludeCredentCheck,
	@IncludeBIS, 
	@IsMatchingPerfectMatches, 
	@IncldueNewMatchesOnly,
	@InputID,
	@IncludeLicenseNumberInMatch,
	@IncludeLicenseTypeInMatch,
	@IncludeLicenseStateInMatch,
	@IncludeLastNameInMatch,
	@IncludeFirstNameInMatch,
	@NoOfLicensesToBeMatched,
	@NoOfLicensesMatched
*/
--==========================================================================

DECLARE @MatchingResult TABLE
(
	TargetApplication VARCHAR(100) NOT NULL,
	TargetTableName VARCHAR(100) NOT NULL,
	TargetTableID INT NOT NULL, 
	
	IsPerfectMatch BIT NOT NULL,
	MatchingIsAMatch INT NULL,
    MatchingComment VARCHAR(8000) NULL,

	StateBoardFinalDataID INT NOT NULL,
	BoardFirstName VARCHAR(200) NULL,
	BoardLastName VARCHAR(200) NULL,
	BoardLicenseNumber VARCHAR(200) NULL,
	BoardLicenseType VARCHAR(200) NULL,
	BoardLicenseState VARCHAR(100) NULL,
	BoardActionDate DATETIME NULL,
	BoardReportDate VARCHAR(200) NULL,
	BoardBatchDate DATETIME NULL,
	BoardActionDescription VARCHAR(8000) NULL,
	StateBoardDisciplinaryRunID INT NOT NULL,
	StateBoardSourceID INT NOT NULL,

	SystemLicenseNumber VARCHAR(200) NULL, 
	SystemLicenseType VARCHAR(200) NULL, 
	SystemLicenseState VARCHAR(200) NULL, 
	SystemLicenseExpiresDate DATETIME NULL, 
	IndividualID INT NULL, 
	SystemLastName VARCHAR(200) NULL, 
	SystemFirstName VARCHAR(200) NULL, 
	IndividualSSN VARCHAR(100) NULL, 
	ClientID INT NULL,
	ClientName VARCHAR(400) NULL
)
--SELECT * FROM @MatchingResult

IF @IncludeCredentCheck=0 AND @IncludeBIS=0
BEGIN 
	SELECT * FROM @MatchingResult
	RETURN 
END 

DECLARE @DefaultMatchingIsAMatch INT --0=false, 1=true, 2=unknown/undetermined 
IF @IsMatchingPerfectMatches=1 SET @DefaultMatchingIsAMatch=1
ELSE SET @DefaultMatchingIsAMatch=2--2 means unknown, 1 means true, 0 means false

DECLARE @TargetTableNameOfCredentCheck VARCHAR(100)
SET @TargetTableNameOfCredentCheck='License'
DECLARE @TargetTableNameOfBIS VARCHAR(100)
SET @TargetTableNameOfBIS='ProfLic'

DECLARE @MatchScenario VARCHAR(100)
IF @IsMatchingPerfectMatches=1 SET @MatchScenario='PerfectMatch'
ELSE SET @MatchScenario='PossibleMatch'

DECLARE @SqlMatching VARCHAR(8000)

--===================Get list of DisplinaryRunIDs===================
DECLARE @DisciplinaryRunIDs TABLE(Item INT NULL)--Should be int

IF @InputID='00000000-0000-0000-0000-000000000000'
	INSERT INTO @DisciplinaryRunIDs
	SELECT DISTINCT SBDR.StateBoardDisciplinaryRunID FROM dbo.StateBoardDisciplinaryRun SBDR
ELSE
	INSERT INTO @DisciplinaryRunIDs
	SELECT DISTINCT SBMIT.StateBoardDisciplinaryRunID FROM dbo.StateBoardMatchIntermediateTable SBMIT
	WHERE SBMIT.InputID=@InputID
--===================End of get List of DisplinaryRunIDs===================

--===================Start of Get list of StateBoardFinalData to be matched against databases===================
SELECT	
	SBFD.StateBoardFinalDataID,
	SBFD.FirstName,
	SBFD.LastName,
	SBFD.LicenseNumber,
	SBFD.LicenseType,
	SBFD.State,
	SBFD.ActionDate,
	SBFD.ReportDate,
	SBFD.BatchDate,
	SBFD.Description,
	SBFD.StateBoardDisciplinaryRunID,
	SBFD.StateBoardSourceID,
	ST.ItemValue AS StateBriefName, 
	ST.Item AS StateFullName 
INTO #FilteredStateBoardFinalData
FROM dbo.StateBoardFinalData SBFD 
INNER JOIN @DisciplinaryRunIDs DRI ON SBFD.StateBoardDisciplinaryRunID=DRI.Item
LEFT OUTER JOIN Rabbit.Hevn.dbo.State ST ON (SBFD.State=ST.ItemValue OR SBFD.State=ST.Item)
WHERE  (CASE 
		--If perfect matching and LicenseNumber is not empty, select those rows
		--If perfect matching and LicenseNumber is empty, don't select those rows
		--If possible matching and LicenseNumber is not empty, don't select those rows
		--If possible matching and LicenseNumber is empty, select those rows
		--The above two cases are changed to include all rows, problem may be: some license in action will hit in both Perfect Match and Possible Match, if want to use the above two rules, swap the comment below
		WHEN @IsMatchingPerfectMatches=1 AND (SBFD.LicenseNumber IS NOT NULL AND SBFD.LicenseNumber<>'NotAvailable' AND SBFD.LicenseNumber<>'NonExistent' AND LTRIM(RTRIM(SBFD.LicenseNumber))<>'') THEN 1
		--WHEN @IsMatchingPerfectMatches=0 AND (SBFD.LicenseNumber IS NULL OR SBFD.LicenseNumber='NotAvailable' OR SBFD.LicenseNumber='NonExistent' OR LTRIM(RTRIM(SBFD.LicenseNumber))='') THEN 1
		WHEN @IsMatchingPerfectMatches=0 THEN 1
		ELSE 0 END)=1
--===================End of Get list of StateBoardFinalData===================

SELECT * INTO #MatchingResult FROM @MatchingResult --This statement is used to bypass the error in EXEC(@SqlMatching) which complaints that @MatchResult is expected because different scope of running.
--===================Start of Perfect/Possible Matches for CredentCheck====================
IF @IncludeCredentCheck=1
BEGIN
	--===================Start of Get list of latest licenses=====================
	--This part can be improved by joining to the #FilteredStateBoardFinalData before hand
	--This improvement had been tried, which is shown below. 
	--Interestingly, and it seems to be slower than this version in Perfect Match with LicenseNumber, but faster in Possible Match without LicenseNumber
	SELECT 
		LS.LicenseID, 
		LS.Number, 
		LS.Type,
		LT.ItemValue AS lmsType, 
		LS.IssuingState, 
		LS.EmployeeRecordID,
		LS.LifeTime,
		LS.ExpiresDate,
		LS.IssuedDate,
		(SELECT MAX(DateValue) FROM   
			( SELECT EndingDate AS DateValue
              UNION ALL
			  SELECT RecordDate AS DateValue
			  UNION ALL
			  SELECT LastModifiedDate AS DateValue
              UNION ALL
			  SELECT VerifiedDate AS DateValue
			  UNION ALL
			  SELECT ReverifyDate AS DateValue
              UNION ALL
			  SELECT VerifiedDate2nd AS DateValue
              UNION ALL
			  SELECT ReviewDate AS DateValue
			  UNION ALL
			  SELECT AuditDate AS DateValue
              UNION ALL
			  SELECT PreviousExpiresDate AS DateValue
			) AS Dates
		) AS MaxDateValue--a trick to get max value of the column
	INTO #LatestLicenses
	FROM RABBIT.HEVN.dbo.License LS LEFT OUTER JOIN RABBIT.HEVN.dbo.LicenseType LT ON LS.LicenseTypeID=LT.LicenseTypeID 
		INNER JOIN 
		(
			SELECT MAX(LS1.LicenseID) AS LicenseID 
			FROM RABBIT.HEVN.dbo.License LS1 
			GROUP BY LS1.ParentLicenseID
		) AS LatestLicenseIDs ON LS.LicenseID=LatestLicenseIDs.LicenseID
	--===================End of Get list of latest licenses=======================

	--===================Start of Get join conditions=============================
	DECLARE @JoinLicense VARCHAR(1000)
	IF @IncludeLicenseNumberInMatch=1 
	SET @JoinLicense='(SBFD.LicenseNumber=LS.Number)'
	ELSE SET @JoinLicense='1=1'

	DECLARE @JoinLicenseType VARCHAR(1000)
	IF @IncludeLicenseTypeInMatch=1 SET @JoinLicenseType='(SBFD.LicenseType=LS.Type OR SBFD.LicenseType=LS.lmsType)'
	ELSE SET @JoinLicenseType='1=1'

	DECLARE @JoinLicenseState VARCHAR(1000)
	IF @IncludeLicenseStateInMatch=1 SET @JoinLicenseState='(SBFD.StateBriefName=LS.IssuingState OR SBFD.StateFullName=LS.IssuingState)'
	ELSE SET @JoinLicenseState='1=1'

	DECLARE @JoinLicenseLastName VARCHAR(1000)
	IF @IncludeLastNameInMatch=1 SET @JoinLicenseLastName='(SBFD.LastName=ER.Last)'
	ELSE SET @JoinLicenseLastName='1=1'

	DECLARE @JoinLicenseFirstName VARCHAR(1000)
	IF @IncludeFirstNameInMatch=1 SET @JoinLicenseFirstName='(SBFD.FirstName=ER.First)'
	ELSE SET @JoinLicenseFirstName='1=1'
	--===================End of Get join conditions=============================

	SET @SqlMatching=
	'INSERT INTO #MatchingResult
		SELECT DISTINCT ''CredentCheck'', '''+@TargetTableNameOfCredentCheck+''','+
		'LS.LicenseID'+','+
		CAST(@IsMatchingPerfectMatches AS VARCHAR(1))+','+
	    CAST(@DefaultMatchingIsAMatch AS VARCHAR(1))+','+
	   ''''' AS MatchingComment,'+
	   'SBFD.StateBoardFinalDataID,
		SBFD.FirstName,
		SBFD.LastName,
		SBFD.LicenseNumber,
		SBFD.LicenseType,
		SBFD.State,
		SBFD.ActionDate,
		SBFD.ReportDate,
		SBFD.BatchDate,
		SBFD.Description,
		SBFD.StateBoardDisciplinaryRunID,
		SBFD.StateBoardSourceID,

		LS.Number, 
		LS.Type, 
		LS.IssuingState, 
		LS.ExpiresDate, 
		ER.EmployeeRecordID, 
		ER.Last, 
		ER.First, 
		ER.SSN, 
		CL.CLNO,
		CL.Name
	FROM #FilteredStateBoardFinalData SBFD 
	INNER JOIN #LatestLicenses AS LS ON'+' '+@JoinLicense+' AND '+@JoinLicenseType+' AND '+@JoinLicenseState+' '
  +'INNER JOIN RABBIT.HEVN.dbo.EmployeeRecord ER ON LS.EmployeeRecordID=ER.EmployeeRecordID AND '+@JoinLicenseLastName+' AND '+@JoinLicenseFirstName+' '
  +'INNER JOIN RABBIT.HEVN.dbo.Client CL ON ER.EmployerID=CL.CLNO'+' '
  +'WHERE ( CASE 
				--260549 rows
				WHEN LS.LifeTime = 1 THEN 1
				--259810 rows
				WHEN LS.ExpiresDate <> NULL AND LS.IssuedDate <> NULL AND (SBFD.ActionDate<=LS.ExpiresDate AND SBFD.ActionDate>=LS.IssuedDate) THEN 1
				WHEN LS.ExpiresDate <> NULL AND LS.IssuedDate <> NULL AND (SBFD.ActionDate>LS.ExpiresDate OR SBFD.ActionDate<LS.IssuedDate) THEN 0
				WHEN LS.ExpiresDate <> NULL AND SBFD.ActionDate<=LS.ExpiresDate THEN 1
				WHEN LS.ExpiresDate <> NULL AND SBFD.ActionDate>LS.ExpiresDate THEN 0
				WHEN LS.IssuedDate <> NULL AND SBFD.ActionDate>=LS.IssuedDate THEN 1
				WHEN LS.IssuedDate <> NULL AND SBFD.ActionDate<LS.IssuedDate THEN 0
				--19936 rows
				WHEN LS.MaxDateValue <> NULL AND SBFD.ActionDate>=LS.MaxDateValue THEN 1
				WHEN LS.MaxDateValue <> NULL AND SBFD.ActionDate<LS.MaxDateValue THEN 0
				--0 rows
				ELSE 1
			END )=1
		'

	IF @IncludeNewMatchesOnly=1
		SET @SqlMatching=@SqlMatching+' AND LS.LicenseID NOT IN ( SELECT SBM.TargetTableID FROM StateBoardMatch SBM WHERE SBM.MatchingIsAMatch<>2 AND SBM.TargetTableName='''+@TargetTableNameOfCredentCheck+''' AND SBM.MatchScenario='''+@MatchScenario+''')'
	EXEC(@SqlMatching)
END
--===================End of Perfect/Posible Matches for CredentCheck====================

--===================Start of Perfect/Possible Matches for BIS====================
IF @IncludeBIS=1
BEGIN
	--===================Start of Get join conditions=============================
	DECLARE @JoinProfLicNumber VARCHAR(1000)
	IF @IncludeLicenseNumberInMatch=1 SET @JoinProfLicNumber='(SBFD.LicenseNumber=PL.Lic_No)'
	ELSE SET @JoinProfLicNumber='1=1'

	DECLARE @JoinProfLicType VARCHAR(1000)
	IF @IncludeLicenseTypeInMatch=1 SET @JoinProfLicType='(SBFD.LicenseType=PL.Lic_Type)'
	ELSE SET @JoinProfLicType='1=1'

	DECLARE @JoinProfLicState VARCHAR(1000)
	IF @IncludeLicenseStateInMatch=1 SET @JoinProfLicState='(SBFD.StateBriefName=PL.State OR SBFD.StateFullName=PL.State)'
	ELSE SET @JoinProfLicState='1=1'

	DECLARE @JoinProfLicLastName VARCHAR(1000)
	IF @IncludeLastNameInMatch=1 SET @JoinProfLicLastName='(SBFD.LastName=AP.Last)'
	ELSE SET @JoinProfLicLastName='1=1'

	DECLARE @JoinProfLicFirstName VARCHAR(1000)
	IF @IncludeFirstNameInMatch=1 SET @JoinProfLicFirstName='(SBFD.FirstName=AP.First)'
	ELSE SET @JoinProfLicFirstName='1=1'
	--===================End of Get join conditions=============================

	SET @SqlMatching=
	'INSERT INTO #MatchingResult
		SELECT DISTINCT ''BIS'', '''+@TargetTableNameOfBIS+''','+
		'PL.ProfLicID'+','+
		CAST(@IsMatchingPerfectMatches AS VARCHAR(1))+','+
	    CAST(@DefaultMatchingIsAMatch AS VARCHAR(1))+','+
	   ''''' AS MatchingComment,'+
	   'SBFD.StateBoardFinalDataID,
		SBFD.FirstName,
		SBFD.LastName,
		SBFD.LicenseNumber,
		SBFD.LicenseType,
		SBFD.State,
		SBFD.ActionDate,
		SBFD.ReportDate,
		SBFD.BatchDate,
		SBFD.Description,
		SBFD.StateBoardDisciplinaryRunID,
		SBFD.StateBoardSourceID,

		PL.Lic_No, 
		PL.Lic_Type, 
		PL.State, 
		PL.Expire, 
		AP.APNO, 
		AP.Last, 
		AP.First, 
		AP.SSN, 
		CL.CLNO,
		CL.Name
	FROM #FilteredStateBoardFinalData SBFD 
	INNER JOIN dbo.ProfLic PL ON '+' '+@JoinProfLicNumber+' AND '+@JoinProfLicType+' AND '+@JoinProfLicState+' '
  +'INNER JOIN dbo.Appl AP ON PL.Apno = AP.APNO AND '+@JoinProfLicLastName+' AND '+@JoinProfLicFirstName+' '
  +'INNER JOIN dbo.Client CL ON AP.CLNO=CL.CLNO'+' '
  +'WHERE AP.ApStatus=''F'''+' '
  +' AND (
		CASE 
			--288074 rows
			WHEN PL.Expire <> NULL AND SBFD.ActionDate<=PL.Expire THEN 1
			WHEN PL.Expire <> NULL AND SBFD.ActionDate>PL.Expire THEN 0
			--54181 rows
			WHEN PL.CreatedDate <> NULL AND SBFD.ActionDate>=PL.CreatedDate THEN 1
			WHEN PL.CreatedDate <> NULL AND SBFD.ActionDate<PL.CreatedDate THEN 0
			--54181 rows
			WHEN PL.Last_Worked <> NULL AND SBFD.ActionDate>=PL.Last_Worked THEN 1
			WHEN PL.Last_Worked <> NULL AND SBFD.ActionDate<PL.Last_Worked THEN 0
			ELSE 1
		END )=1'
	--LicenseType of ProfLic table are free text, more shots can be made by join to Rabbit.dbo.LicenseType LT ON (LT.Item=PL.Lic_Type OR LT.ItemValue=PL.Lic_Type)
	
	IF @IncludeNewMatchesOnly=1
		SET @SqlMatching=@SqlMatching+' AND PL.ProfLicID NOT IN ( SELECT SBM.TargetTableID FROM StateBoardMatch SBM WHERE SBM.MatchingIsAMatch<>2 AND SBM.TargetTableName='''+@TargetTableNameOfBIS+''' AND SBM.MatchScenario='''+@MatchScenario+''')'
	EXEC(@SqlMatching)
END
--===================End of Perfect/Possible Matches for BIS====================

--===========================Join to Existing MatchResults========================
SELECT 
	MR.TargetApplication,
	MR.TargetTableName,
	MR.TargetTableID,
	MR.IsPerfectMatch,
	(CASE WHEN SBM.MatchingIsAMatch IS NULL THEN @DefaultMatchingIsAMatch ELSE SBM.MatchingIsAMatch END) AS MatchingIsAMatch,
    SBM.MatchingComment,

	MR.StateBoardFinalDataID,
	MR.BoardFirstName,
	MR.BoardLastName,
	MR.BoardLicenseNumber,
	MR.BoardLicenseType,
	MR.BoardLicenseState,
	MR.BoardActionDate,
	MR.BoardReportDate,
	MR.BoardBatchDate,
	MR.BoardActionDescription,
	MR.StateBoardDisciplinaryRunID,
	MR.StateBoardSourceID,

	MR.SystemLicenseNumber, 
	MR.SystemLicenseType, 
	MR.SystemLicenseState, 
	MR.SystemLicenseExpiresDate, 
	MR.IndividualID, 
	MR.SystemLastName, 
	MR.SystemFirstName, 
	MR.IndividualSSN, 
	MR.ClientID,
	MR.ClientName
FROM #MatchingResult MR INNER JOIN 
(
	--remove duplicate using #MatchingResult MR1
	SELECT 
		MR1.TargetApplication,
		MR1.TargetTableName,
		MAX(MR1.TargetTableID) AS TargetTableID, 
		MR1.StateBoardFinalDataID,
		MR1.ClientID
	FROM #MatchingResult MR1
	GROUP BY 
		MR1.TargetApplication,
		MR1.TargetTableName,
		MR1.StateBoardFinalDataID,
		MR1.ClientID
) LatestMR ON
		MR.TargetApplication=LatestMR.TargetApplication 
		AND MR.TargetTableName=LatestMR.TargetTableName
		AND MR.TargetTableID=LatestMR.TargetTableID
		AND MR.StateBoardFinalDataID=MR.StateBoardFinalDataID
		AND MR.ClientID=LatestMR.ClientID
LEFT OUTER JOIN dbo.StateBoardMatch SBM 
ON MR.StateBoardFinalDataID=SBM.StateBoardDataID AND MR.TargetTableID=SBM.TargetTableID AND (SBM.TargetTableName=@TargetTableNameOfCredentCheck OR SBM.TargetTableName=@TargetTableNameOfBIS) AND SBM.MatchScenario=@MatchScenario
--================================================================================

SELECT @NoOfLicensesMatched=@@ROWCOUNT
SELECT @NoOfLicensesToBeMatched=COUNT(*) FROM #FilteredStateBoardFinalData

PRINT @SqlMatching
PRINT @DefaultMatchingIsAMatch
PRINT 'Matched:'+CAST(@NoOfLicensesMatched AS VARCHAR(10))
PRINT 'To be Matched:'+CAST(@NoOfLicensesToBeMatched AS VARCHAR(10))

DROP TABLE #MatchingResult
DROP TABLE #FilteredStateBoardFinalData
IF @IncludeCredentCheck=1 DROP TABLE #LatestLicenses
--IF @IncludeBIS=1 DROP TABLE #LatestProfLic















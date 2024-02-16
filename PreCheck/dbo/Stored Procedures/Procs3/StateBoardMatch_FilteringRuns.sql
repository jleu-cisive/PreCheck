



CREATE PROCEDURE [dbo].[StateBoardMatch_FilteringRuns]
(
	@InputID uniqueidentifier,
	@IncludeOnlyLatestDisciplinaryRuns bit=1
)
AS
--=======================Schema Query======================
/*
SELECT 
	  SBDR.StateBoardDisciplinaryRunID,
      SBDR.StateBoardSourceID,
      SBDR.StartedDate,
      SBDR.CompletedDate,
      SBDR.ReportDate,
      SBDR.BatchDate,
      SBDR.UserA,
      SBDR.UserB,
      SBDR.NoBoardAction,
	  LA.SourceName,
	  1 AS CountOfEntries
FROM  dbo.StateBoardDisciplinaryRun SBDR
INNER JOIN dbo.VWLicenseAuthority LA ON SBDR.StateBoardSourceID=LA.StateBoardSourceID

EXEC [StateBoardMatch_FilteringRuns] '00000000-0000-0000-0000-0000000000000000', 1
*/
--==========================================================

--===================Get list of StateBoardSourceIDs===================
DECLARE @SourceIDs TABLE(Item INT NULL)

IF @InputID='00000000-0000-0000-0000-0000000000000000'
	INSERT INTO @SourceIDs
	SELECT DISTINCT SBDR.StateBoardSourceID FROM dbo.StateBoardDisciplinaryRun SBDR
ELSE
	INSERT INTO @SourceIDs
	SELECT DISTINCT SBMIT.StateBoardSourceID FROM dbo.StateBoardMatchIntermediateTable SBMIT
	WHERE SBMIT.InputID=@InputID
--===================End of Get list of StateBoardSourceIDs===================

--===================Get list of Disciplinary RunIDs===================
--When the data gets strict, the following changes should be made
--1. #ExistingSBFD should group by SBFD.StateBoardDisciplinaryRunID, SBFD.StateBoardSourceID
--2. Uncomment the comments in 'WHERE /*SBDR.DateCompletedA <> NULL AND SBDR.DateCompletedB <> NULL AND*/ ESBFD.CountOfEntries>0'
--3. ESBFD.CountOfEntries is optional to remove all the empty runs
--4. remove 'OR SBDR_2.StateBoardDisciplinaryRunID IN (SELECT SBFD.StateBoardDisciplinaryRunID FROM #ExistingSBFD)'

--#ExistingSBFD is used to find count
SELECT SBFD.StateBoardDisciplinaryRunID, COUNT(*) AS CountOfEntries 
INTO #ExistingSBFD
FROM dbo.StateBoardFinalData SBFD
GROUP BY SBFD.StateBoardDisciplinaryRunID--, SBFD.StateBoardSourceID

IF @IncludeOnlyLatestDisciplinaryRuns=0
	SELECT 
	  SBDR.StateBoardDisciplinaryRunID,
      SBDR.StateBoardSourceID,
      SBDR.StartedDate,
      SBDR.CompletedDate,
      SBDR.ReportDate,
      SBDR.BatchDate,
      SBDR.UserA,
      SBDR.UserB,
      SBDR.NoBoardAction,
	  LA.SourceName,
	  (CASE WHEN ESBFD.CountOfEntries IS NULL THEN 0 ELSE ESBFD.CountOfEntries END) AS CountOfEntries
	FROM  dbo.StateBoardDisciplinaryRun SBDR INNER JOIN @SourceIDs SID ON SBDR.StateBoardSourceID=SID.Item
	INNER JOIN dbo.VWLicenseAuthority LA ON SBDR.StateBoardSourceID=LA.StateBoardSourceID
	LEFT OUTER JOIN #ExistingSBFD ESBFD ON ESBFD.StateBoardDisciplinaryRunID=SBDR.StateBoardDisciplinaryRunID
	WHERE /*SBDR.DateCompletedA <> NULL AND SBDR.DateCompletedB <> NULL AND*/ ESBFD.CountOfEntries>0
	ORDER BY SBDR.CompletedDate, SBDR.StartedDate
ELSE
	SELECT 
	  SBDR.StateBoardDisciplinaryRunID,
      SBDR.StateBoardSourceID,
      SBDR.StartedDate,
      SBDR.CompletedDate,
      SBDR.ReportDate,
      SBDR.BatchDate,
      SBDR.UserA,
      SBDR.UserB,
      SBDR.NoBoardAction,
	  LA.SourceName,
	  (CASE WHEN ESBFD.CountOfEntries IS NULL THEN 0 ELSE ESBFD.CountOfEntries END) AS CountOfEntries
	FROM  dbo.StateBoardDisciplinaryRun SBDR INNER JOIN @SourceIDs SID ON SBDR.StateBoardSourceID=SID.Item
	INNER JOIN dbo.VWLicenseAuthority LA ON SBDR.StateBoardSourceID=LA.StateBoardSourceID
	LEFT OUTER JOIN #ExistingSBFD ESBFD ON ESBFD.StateBoardDisciplinaryRunID=SBDR.StateBoardDisciplinaryRunID
	INNER JOIN 
	(
		SELECT SBDR_2.StateBoardSourceID AS CurrentStateBoardID, MAX(SBDR_2.StateBoardDisciplinaryRunID) AS CurrentStateBoardDisciplinaryRunID 
		FROM dbo.StateBoardDisciplinaryRun AS SBDR_2
		WHERE (SBDR_2.DateCompletedA <> NULL AND SBDR_2.DateCompletedB <> NULL) --means the run is closed
			OR 
			SBDR_2.StateBoardDisciplinaryRunID IN --means there is final data for this run
			(SELECT #ExistingSBFD.StateBoardDisciplinaryRunID FROM #ExistingSBFD)
		GROUP BY SBDR_2.StateBoardSourceID 
	) AS CurrentStateBoardDisciplinaryRun ON SBDR.StateBoardDisciplinaryRunID=CurrentStateBoardDisciplinaryRun.CurrentStateBoardDisciplinaryRunID
	--WHERE /*SBDR.DateCompletedA <> NULL AND SBDR.DateCompletedB <> NULL AND*/ ESBFD.CountOfEntries>0
	ORDER BY SBDR.CompletedDate, SBDR.StartedDate

DROP TABLE #ExistingSBFD
--==============================================================================================================


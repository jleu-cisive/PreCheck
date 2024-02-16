
/*
Procedure Name : [dbo].[Employment_Verification_Stats]
Requested By: Valerie K. Salazar
Developer: Deepak Vodethela
Execution : 1.) EXEC [dbo].[Employment_Verification_Stats] '10/14/2015', '10/14/2015', 'bwintlen:DWood:Gmalone:ngriffit:SStewart'
			2.) EXEC [dbo].[Employment_Verification_Stats] '10/14/2015', '10/14/2015'
*/

CREATE Procedure [dbo].[Employment_Verification_Stats]
(
	@StartDate DateTime, 
	@EndDate DateTime,
	@Investigator VARCHAR(MAX) = NULL
) 
 AS 

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

-- Assign the Investigator to NULL
IF LEN(@Investigator) = 0 
	BEGIN 
		SET @Investigator = NULL 
	END

-- Get all Employment Users from users table
	SELECT DISTINCT UserID 
		   INTO #tempUsers 
	FROM Users(NOLOCK)
	WHERE Empl = 1
	  AND Disabled = 0
	ORDER BY UserID

	-- SELECT '#tempUsers' TempTable, * FROM #tempUsers

--Get all the occurrence of 'Empl' from ChangeLog
	SELECT TableName, oldvalue, Newvalue, REPLACE(USERID, '-empl','') userid, id , ChangeDate
		   INTO #EmplTempChangeLog
	FROM dbo.ChangeLog WITH (NOLOCK)
	WHERE (TableName Like  'Empl.%')  
	  AND ChangeDate BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(d,1,@EndDate))
	ORDER BY UserID

	--SELECT '#EmplTempChangeLog' TempTable, * FROM #EmplTempChangeLog where userid = @Investigator

/* -- Start : Empl Efforts -- */

	-- Capture all the valid inputs from users when an attempt is made on a employment record
	SELECT TableName, oldvalue, Newvalue, userid, id 
			INTO #EmplTempEfforts
	FROM #EmpltempChangeLog
	Where (TableName = 'Empl.SectStat')  OR (TableName = 'Empl.web_status') OR (TableName = 'Empl.priv_notes') OR (TableName = 'Empl.Pub_Notes')

	--SELECT '#EmplTempEfforts' TempTable, * FROM #EmplTempEfforts  where userid = @Investigator

	-- Get Unique ID's of all the inputs from User
	SELECT	DISTINCT id, userid 
			INTO #EmplTempFinalEfforts 
	FROM #EmplTempEfforts

	--SELECT '#EmplTempFinalEfforts' TempTable, * FROM #EmplTempFinalEfforts where userid = @Investigator

/* -- End : Empl Efforts -- */

/* -- Start : First Attempt Closed -- */

	-- Get the 'Modified FROM' values--> ["NEEDS REVIEW" & "PENDING"] when the Modified To is ["VERIFIED/SEE ATTACHED"] FROM 'Empl.SectStat' 
	SELECT id, oldvalue, MIN(changedate) AS changedate, userid 
		   INTO #EmplTempGetModifiedValuesForClosedAttempts
	FROM #EmpltempChangeLog
	GROUP BY id, tablename, oldvalue,NewValue, userid
	HAVING tablename = 'Empl.SectStat' 
	   AND oldvalue IN ('9', '0') 
	   AND NewValue = '5'
	ORDER BY id

	-- SELECT '#EmplTempGetModifiedValuesForClosedAttempts' TempTable, * FROM #EmplTempGetModifiedValuesForClosedAttempts

	-- Get all the occurances of the EmplID from the web_status_history table.
	SELECT e.id, e.userid AS UserID
		   INTO #EmplTempGetAllOccurancesFromWebHistory
	FROM #EmplTempGetModifiedValuesForClosedAttempts e 
	LEFT JOIN web_status_history w WITH (NOLOCK) ON e.id = w.emplid 
	
	--SELECT * FROM #EmplTempGetAllOccurancesFromWebHistory ORDER BY 1

	-- Remove dupilcate Employment Id's
	DELETE FROM #EmplTempGetAllOccurancesFromWebHistory 
	WHERE id IN (SELECT id 
				 FROM #EmplTempGetAllOccurancesFromWebHistory 
				 GROUP BY id 
				 HAVING COUNT(id)>1)


	-- SELECT '#EmplTempGetAllOccurancesFromWebHistory' TempTable, * FROM #EmplTempGetAllOccurancesFromWebHistory

/* -- End : First Attempt Closed -- */

/* -- Start :  First Attempt efforts -- */
		
		-- Capture all the work done except 'Choose'
		-- Consider efforts only when Web_Status and Section_Status is changed and also when an entry is made in the Private notes and Public Notes section.
		-- And also capture all the Closed Occurances from Web_History
		SELECT ID, UserID INTO #EmplFirstAttemptEfforts FROM #EmplTempEfforts WHERE tablename = 'Empl.web_status' AND oldvalue = '0'
		UNION ALL
		SELECT ID, UserID  FROM #EmplTempGetAllOccurancesFromWebHistory

		--SELECT '#EmplFirstAttemptEfforts' TempTable, * FROM #EmplFirstAttemptEfforts

		-- Get unique ID's from above
		SELECT  DISTINCT ID,userid 
				INTO #EmplFirstAttemptEffortsFinal 
		FROM #EmplFirstAttemptEfforts

		--SELECT '#EmplFirstAttemptEffortsFinal' TempTable, * FROM #EmplFirstAttemptEffortsFinal

/* -- End :  First Attempt efforts -- */

/* -- Start : Combine Prod Details and First Attempts -- */

	CREATE TABLE #EmploymentVerificationStats
	(
		Investigator varchar(8),
		EmplEfforts int,
		VerifiedSeeAttached int,
		UnVerifiedSeeAttached int,
		FirstAttemptEfforts int,
		FirstAttemptClosed int
	)

	INSERT INTO #EmploymentVerificationStats (Investigator, EmplEfforts, VerifiedSeeAttached,UnVerifiedSeeAttached, FirstAttemptEfforts, FirstAttemptClosed)
	SELECT T.UserID  INVESTIGATOR, 
		(SELECT COUNT(id) FROM #EmplTempFinalEfforts AS A WHERE  A.UserID = T.UserID) [EMPL EFFORTS],
		(SELECT COUNT(id) FROM #EmplTempEfforts B (NOLOCK) WHERE Newvalue = '5' AND TableName = 'Empl.SectStat' AND ISNULL(B.UserID,'') = ISNULL(T.UserID,'')) [VERIFIED/SEE ATTACHED],
		(SELECT COUNT(id) FROM #EmplTempEfforts C (NOLOCK) WHERE Newvalue = '6' AND TableName = 'Empl.SectStat' AND ISNULL(C.UserID,'') = ISNULL(T.UserID,'')) [UNVERIFIED/SEE ATTACHED],
		(SELECT COUNT(id) FROM #EmplFirstAttemptEffortsFinal D (NOLOCK) WHERE D.UserID = T.UserID) [FIRST ATTEMPT EFFORTS],
		(SELECT COUNT(id) FROM #EmplTempGetAllOccurancesFromWebHistory E WHERE E.UserID = T.UserID )[FIRST ATTEMPT CLOSED] 
	FROM #tempUsers T
	GROUP BY T.UserID

	-- SELECT '#EmploymentVerificationStats' TempTable, * FROM #EmploymentVerificationStats

	SELECT * FROM #EmploymentVerificationStats
	WHERE (@Investigator IS NULL OR Investigator IN (SELECT * from [dbo].[Split](':',@Investigator)))

	UNION ALL

	SELECT 'Totals' Investigator, 
			SUM(EmplEfforts) AS [Empl Efforts],
			SUM(VerifiedSeeAttached) AS [VERIFIED/SEE ATTACHED],
			SUM(UnVerifiedSeeAttached) AS [UNVERIFIED/SEE ATTACHED],
			SUM(FirstAttemptEfforts) AS [FirstAttemptEfforts],
			SUM(FirstAttemptClosed) AS [FirstAttemptClosed]
	FROM #EmploymentVerificationStats
	WHERE (@Investigator IS NULL OR Investigator IN (SELECT * from [dbo].[Split](':',@Investigator)))

-- Temporary Tables

DROP TABLE #tempUsers
DROP TABLE #EmplTempChangeLog
DROP TABLE #EmplTempEfforts
DROP TABLE #EmplTempFinalEfforts
DROP TABLE #EmplTempGetModifiedValuesForClosedAttempts
DROP TABLE #EmplTempGetAllOccurancesFromWebHistory
DROP TABLE #EmploymentVerificationStats
DROP TABLE #EmplFirstAttemptEffortsFinal

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

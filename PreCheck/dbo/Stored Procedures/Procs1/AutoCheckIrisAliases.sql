
-- Alter Procedure AutoCheckIrisAliases
 
-- =============================================
-- AuthOR:		Dongmei He
-- Create date: 5/14/2012
-- DescriptiON:	 Auto submit Crim ORders when all ORdering requirements are met. this Sp is called FROM PrecheckWinService.AutoCheckIrisAliASes
-- =============================================
-- =============================================
-- Edited by :		Kiran
-- Edited date:		1/29/2013
-- DescriptiON:	 updating AutoCheckAliAS =1
-- =============================================
-- =============================================
-- Edited By :	Deepak Vodethela	
-- Edited date:	01/11/2017
-- Description:	As part of Alias Logic Re-Write project all the Aliases will be from dbo.ApplAlias (Overflow table).Only AutoOrder records should be selected to send automatically.
-- =============================================
-- Edited By :	Deepak Vodethela	
-- Edited date:	05/18/2017
-- Description:	Only AutoOrder records should be selected to send automatically. Created a new stored procedure "Crim_MarkToSend_AutoOrder" to get only the "AutoOrdr" records.
-- =============================================
-- Edited By :	Deepak Vodethela	
-- Edited date:	10/04/2017
-- Description:	Added the below conditions to the service:
--				AliasCount rule of 0 means that 1 name is sent (primary) 
--				AliasCount rule of 1 means 2 names are sent (primary + 1) 
--				AliasCount rule of 2 means 3 names are sent (primary + 2) 
--				AliasCount rule of 3 means 4 names are sent (primary + 3) 
--				AliasCount rule of 4 means 5 names are sent (primary + 4)
-- =============================================
-- Edited By :	Anil Rai
-- Edited date:	07/04/2023
-- Description:	Added To exclude two criminal jurisdictions from the Order Management Auto Order Service as per HDT 99680
-- =============================================

CREATE PROCEDURE [dbo].[AutoCheckIrisAliases]
AS

SET ANSI_WARNINGS OFF 
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

	CREATE TABLE #IrisAliasUpdate (
		CrimID int,
		APNO int,
		ReadyToSend bit,
		ReadyToSend_Old bit,
		ApStatus char(1), 
		Iris_Rec varchar(3), 
		[Clear] varchar(1), 
		Clear_Old varchar(1),
		BatchNumber float, 
		BatchNumber_Old float,
		DeliveryMethod varchar(50), 
		CrimEnteredTime datetime,
		CNTY_NO INT,
		Researcher_Aliases_count varchar(4),
		AliasCount int,
		IsPrimaryName bit,
		HasSpecialInstructions Bit 
	)

	---Index on temp table
	CREATE CLUSTERED INDEX IX_IrisAlias_01 ON #IrisAliasUpdate(CrimID,APNO)

	-- Get all the Qualifying records to be processed for AutoOrder
	INSERT INTO #IrisAliasUpdate 
		SELECT	CrimID,
				A.APNO,
				ReadyToSend,
				ReadyToSend,
				A.ApStatus,
				Iris_Rec, 
				[Clear], 
				[Clear],			
				BatchNumber, 
				BatchNumber, 
				DeliveryMethod, 
				CrimEnteredTime,
				c.CNTY_NO,
				ISNULL(Researcher_Aliases_count,0) Researcher_Aliases_count,
				ISNULL(AliasCount,0) AliasCount,
				ISNULL(IsPrimaryName,0) IsPrimaryName,
				CASE WHEN (C.Crim_SpecialInstr IS NULL OR CAST(C.Crim_SpecialInstr AS VARCHAR(MAX)) = '') THEN 0 ELSE 1 END-- Skip the Auto Order if there are special instructions
		FROM dbo.Crim AS c(NOLOCK) 
		INNER JOIN dbo.TblCounties AS ct(NOLOCK) ON c.CNTY_NO = ct.CNTY_NO 
		INNER JOIN dbo.appl AS a(NOLOCK) ON c.apno = a.apno
		LEFT OUTER JOIN (SELECT APNO, COUNT(1) AS AliasCount FROM dbo.ApplAlias(NOLOCK) WHERE IsPublicRecordQualified = 1 AND IsActive = 1 GROUP BY APNO) AS Y ON A.APNO = Y.APNO
		LEFT OUTER JOIN (SELECT APNO, COUNT(IsPrimaryName) AS IsPrimaryName FROM dbo.ApplAlias(NOLOCK) WHERE IsPrimaryName = 1 GROUP BY APNO, IsPrimaryName) AS Z ON A.APNO = Z.APNO
		LEFT OUTER JOIN dbo.Iris_Researchers AS ir(NOLOCK) ON c.vENDORid = ir.R_id 
		LEFT OUTER JOIN dbo.Iris_Researcher_Charges AS irc(NOLOCK) ON irc.Researcher_id = ir.R_id AND c.CNTY_NO = irc.cnty_no
		WHERE (UPPER(A.ApStatus) IN ('P','W'))
		  AND (UPPER(C.iris_rec) = 'YES')
		  AND (C.batchnumber IS NULL OR C.batchnumber = '0')
		  AND (ISNULL(C.ReadyToSend,0) = 0)
		  AND (A.inuse IS NULL)
		  --AND (A.InUse != 'CNTY_W' OR A.NeedsReview NOT LIKE '%2') -- VD: 06/04/2018 -- Do Not pick it up if the report is in Transitive status
		  AND (A.NeedsReview NOT LIKE '%1') -- VD: 04/27/2017 -- Do Not Consider any reports for which PositiveID was not run
		  AND (A.NeedsReview NOT LIKE '%7') -- VD: 05/04/2017 -- Do Not Consider any reports when there is NO SSN
		  AND ((DATEDIFF(mi, C.Crimenteredtime, GETDATE()) >= 1  AND UPPER(C.Clear) = 'R' AND C.deliverymethod <> 'ONLINEDB') 
			OR (DATEDIFF(mi, C.Crimenteredtime, GETDATE()) >= 1  AND UPPER(C.Clear) = 'R' AND C.deliverymethod = 'ONLINEDB' AND C.cnty_no <> 2480)
			OR (DATEDIFF(mi, C.Crimenteredtime, GETDATE()) >= 20 AND UPPER(C.Clear) = 'R' AND (C.cnty_no = 2480) AND (C.deliverymethod = 'ONLINEDB') )   
			OR (C.deliverymethod LIKE 'WEB%SERVICE%' AND UPPER(C.Clear) = 'E' AND DATEDIFF(mi, C.Crimenteredtime, GETDATE()) >= 1 ))
		  AND C.deliverymethod IN ('Call_In', 'InHouse','E-Mail','Fax','ONlineDB','WEB SERVICE','Integration') 
		  AND (ISNULL(C.AutoCheckAlias,0) = 0)
		  AND C.IsHidden = 0
		  --schapyala on 03/28/2021 to exclude OMNI from being AutoOrdered - temp fix while fixing alias issue 
		  AND C.vendorid not in (190,97800,99699,214351,283913,301168,715036,782852,800623,807735,808795,809028,824454,824455,824456,824457,824458,824459,824460,824461,824462,824463,824464,824465,883823,924112,939583,960210,961499,1157916,1167917,1170460,1202690,1255562,1306195,1347562,1347610,2133365)
		  AND C.CNTY_NO NOT IN ('3667','5') --added by Anil Rai for HDT 99680
	--SELECT * FROM #IrisAliasUpdate

-- The below update is for logic to handle any reopens that did not go through the preprocessing logic – if the alias names are missing
	UPDATE Appl
		SET InUse = 'CNTY_S',
			NeedsReview = LEFT(NeedsReview,1) + '2'
	WHERE APNO IN (SELECT DISTINCT APNO FROM #IrisAliasUpdate WHERE (AliasCount = 0 OR IsPrimaryName = 0)) AND (InUse IS NULL)

	-- Release the reports which are struck for unknow reason(TO DO - Need to investigate and find out the real reason why is this happenning)
	UPDATE A SET A.InUse = NULL
	FROM dbo.Appl a WHERE A.APNO	IN (
	SELECT C.APNO FROM dbo.Crim c(NOLOCK) WHERE C.CrimID	IN (
	SELECT s.SectionKeyID FROM dbo.ApplAlias_Sections s(nolock) WHERE s.ApplAliasID	IN (
	SELECT aa.ApplAliasID FROM dbo.ApplAlias aa	WHERE aa.APNO	IN (
	SELECT a.APNO FROM dbo.Appl a WHERE a.InUse = 'CNTY_W'))))

	-- Delete any App's that have AliasCount = 0 from main set
	DELETE #IrisAliasUpdate WHERE CrimID IN (SELECT CrimID FROM #IrisAliasUpdate WHERE AliasCount = 0 )

	
-- The below update is for logic to handle any reopens that did not go through the preprocessing logic – if the alias names are missing

	-- Get all the records that needs to be skipped. i.e When it finds the same Criminal Counties more than once and plugging in the Private Notes.
	SELECT DISTINCT C.* 
		INTO #tmpSkipAutoOrder 
	FROM #IrisAliasUpdate AS C 
	INNER JOIN (SELECT APNO, MAX(CrimID) AS CrimID, County, COUNT(CNTY_NO) NumOfCounties
				FROM Crim(NOLOCK) 
				WHERE IsHidden = 0
				GROUP BY APNO, County
				HAVING COUNT(CNTY_NO) > 1) AS Y ON C.APNO = Y.APNO AND C.CrimID = Y.CrimID

	--SELECT * FROM #tmpSkipAutoOrder
	
	-- Delete the records that have more than one similar county from the main resultset
	DELETE #IrisAliasUpdate WHERE CrimID IN (SELECT CrimID FROM #tmpSkipAutoOrder)

	-- Get all the Private Notes that was sent earlier and append
	SELECT	APNO,
			CrimID,
			CNTY_NO,
			REPLACE(STUFF('  Previously Sent Names: ' + (SELECT '; ' + ISNULL(Priv_Notes,'')
					FROM Crim AS B(NOLOCK)
					WHERE (B.APNO = A.APNO AND B.CNTY_NO = A.CNTY_NO)
					  AND Priv_Notes LIKE '%Names Sent:%' 
					  AND ISNULL(Priv_Notes,'') <> '' 
					  AND B.CrimID != A.CrimID
					ORDER BY CrimID DESC
					FOR XML PATH('')), 1, 2, ''),'; ', char(13) + char(10)) AS Priv_Notes
		INTO #tmpUpdatePrivateNotes
	From #tmpSkipAutoOrder AS A

	--SELECT * FROM crim where casT(Apno as varchar) + cast(cnty_no as varchar) in (select casT(Apno as varchar) + cast(cnty_no as varchar) from #tmpUpdatePrivateNotes) order by apno,county
	--select * from #tmpUpdatePrivateNotes

	-- Update the skipped CrimID's Private Notes, so that the Public Records investigtaor knows what were sent earlier in Order Management
	--SELECT C.APNO,C.CNTY_NO, C.County, C.CrimID, C.Priv_Notes, P.APNO, P.CNTY_NO, P.Priv_Notes
	UPDATE C
		SET C.Priv_Notes = ISNULL(P.Priv_Notes,'') + ISNULL(C.Priv_Notes,'')
	FROM CRIM AS C
	INNER JOIN #tmpUpdatePrivateNotes AS P ON C.CrimID = P.CrimID
	WHERE ISNULL(C.PRIV_NOTES,'') NOT LIKE '%Previously Sent Names:%'
	  AND ISNULL(P.Priv_Notes,'') <> ''

	DROP TABLE #tmpSkipAutoOrder
	DROP TABLE #tmpUpdatePrivateNotes

	-- Researcher_Aliases_count = 'All'
	SELECT * INTO #tmpAll
	FROM #IrisAliasUpdate
	WHERE Researcher_Aliases_count = 'All'
	
	--SELECT * FROM #tmpAll

	-- Get all the Disqualified records when Researcher_Aliases_count = 'All'
	SELECT * INTO #tmpAllToBeDeleted
	FROM #tmpAll
	WHERE ((CASE WHEN Researcher_Aliases_count = 'All' THEN 5 ELSE Researcher_Aliases_count END) <  AliasCount	)
	   OR (HasSpecialInstructions = 1)

	--SELECT * FROM #tmpAllToBeDeleted

	-- Delete all the Disqualified reports when Researcher_Aliases_count = 'All'
	DELETE FROM #IrisAliasUpdate WHERE CrimID IN (SELECT CrimID FROM #tmpAllToBeDeleted)

	-- Researcher_Aliases_count <> 'All'
	SELECT * INTO #tmpOtherThanAll
	FROM #IrisAliasUpdate
	WHERE Researcher_Aliases_count != 'All'
	
	--SELECT * FROM #tmpOtherThanAll

	-- Get all the Disqualified records when Researcher_Aliases_count <> 'All'
	SELECT * INTO #tmpOtherThanAllToBeDeleted
	FROM #tmpOtherThanAll
	WHERE ((CASE WHEN Researcher_Aliases_count = '0' THEN 1 ELSE Researcher_Aliases_count END) <  AliasCount)
	  AND ((CASE WHEN Researcher_Aliases_count = '1' THEN 2 ELSE Researcher_Aliases_count END) <  AliasCount)
	  AND ((CASE WHEN Researcher_Aliases_count = '2' THEN 3 ELSE Researcher_Aliases_count END) <  AliasCount)
	  AND ((CASE WHEN Researcher_Aliases_count = '3' THEN 4 ELSE Researcher_Aliases_count END) <  AliasCount)
	  AND ((CASE WHEN Researcher_Aliases_count = '4' THEN 5 ELSE Researcher_Aliases_count END) <  AliasCount)
	   OR (HasSpecialInstructions = 1)

	--SELECT * FROM #tmpOtherThanAllToBeDeleted

	-- Delete all the Disqualified reports when Researcher_Aliases_count <> 'All'
	DELETE FROM #IrisAliasUpdate WHERE CrimID IN (SELECT CrimID FROM #tmpOtherThanAllToBeDeleted)

	--DROP TABLE #IrisAliasUpdate
	DROP TABLE #tmpAll
	DROP TABLE #tmpAllToBeDeleted
	DROP TABLE #tmpOtherThanAll
	DROP TABLE #tmpOtherThanAllToBeDeleted

	-- Get all the Qualified Reports
	--SELECT * FROM #IrisAliasUpdate ORDER BY Researcher_Aliases_count

	-- Lock the application for AutoOrder service.
	UPDATE A
		SET A.InUse = 'ChkAlias'
	FROM Appl AS A(NOLOCK)
	INNER JOIN #IrisAliasUpdate AS T ON A.APNO = T.APNO

	UPDATE A 
		SET ReadyToSend = 1,
			BatchNumber=0,
			[Clear] = ''
	FROM #IrisAliasUpdate A
	LEFT JOIN dbo.ApplAlias AS AA(NOLOCK) ON A.APNO = AA.APNO AND AA.IsPublicRecordQualified = 1 AND AA.IsActive=1

	-- Insert into ApplAlias_Sections when these records are Sent by Winservice i.e. when count is set to all
	-- VD-05/11/2018 - Added the below logic to NOT to insert any duplicate aliases
	INSERT INTO [dbo].[ApplAlias_Sections]([ApplSectionID],[SectionKeyID],[ApplAliasID],[IsActive],[CreatedBy], [LastUpdatedBy])
		SELECT DISTINCT 5 , I.CrimID , AA.ApplAliasID, 1 , 'AutoOrdr', 'AutoOrdr' 
		FROM #IrisAliasUpdate AS I
		LEFT JOIN dbo.ApplAlias AS AA(NOLOCK) ON I.APNO = AA.APNO
		WHERE IsPublicRecordQualified = 1 
		  AND AA.IsActive = 1 
		  AND NOT EXISTS (SELECT aas.SectionKeyID, aas.ApplAliasID 
						  FROM dbo.ApplAlias_Sections aas(NOLOCK) 
						  WHERE aas.IsActive = 1
						    AND aas.SectionKeyID = I.CrimID	
							AND aas.ApplAliasID	= AA.ApplAliasID )

		/* VD:05/11/2018 - The below code was inserting duplicate aliases, when program which changes the status to “Ordering” was failing
		SELECT DISTINCT 5 , I.CrimID , AA.ApplAliasID, 1 , 'AutoOrdr', 'AutoOrdr' 
		FROM #IrisAliasUpdate AS I
		LEFT JOIN dbo.ApplAlias AS AA(NOLOCK) ON I.APNO = AA.APNO
		WHERE IsPublicRecordQualified = 1 AND AA.IsActive = 1 
		*/

	-- This statement below will skip the county to be skiped in next sweep
	-- This is done in order to eliminate any issues with countys stuck in pending for long time. This may not be an issue but trying this work around -- kiran	,1/29/2013				
	UPDATE C 
		SET AutoCheckAlias = 1,
			ReadyToSend = A.ReadyToSend
	FROM dbo.Crim C 
	INNER JOIN #IrisAliasUpdate A ON C.CrimID = A.CrimID

	EXEC dbo.Crim_MarkToSend_AutoOrder 'Call_In','AutoOrdr'
	
	EXEC dbo.Crim_MarkToSend_AutoOrder 'InHouse','AutoOrdr'

	EXEC dbo.Crim_MarkToSend_AutoOrder 'E-Mail','AutoOrdr'

	EXEC dbo.Crim_MarkToSend_AutoOrder 'Fax','AutoOrdr'

	EXEC dbo.Crim_MarkToSend_AutoOrder 'OnlineDB','AutoOrdr'

	EXEC dbo.Crim_MarkToSend_AutoOrder 'WEB SERVICE','AutoOrdr'
	
	EXEC dbo.Crim_MarkToSend_AutoOrder 'Integration','AutoOrdr'

	UPDATE dbo.Appl
		SET InUse = NULL
	WHERE InUse = 'ChkAlias'

	-- Start : Insert Qualified Names into Criminal Private Notes

	UPDATE C
		SET C.Priv_Notes = ISNULL(C.Priv_Notes,'') + STUFF('  AutoOrdr' + ', ' + CAST(CURRENT_TIMESTAMP AS VARCHAR) + ', Names Sent: ' + (SELECT ISNULL(First,'') +' '+ ISNULL(Middle,'') +' '+ ISNULL(Last,'') +' '+ ISNULL(Generation,'') + ', '
					FROM dbo.ApplAlias_Sections AS AA (NOLOCK)
					INNER JOIN ApplAlias AS A(NOLOCK) ON AA.ApplAliasID = A.ApplAliasID
					WHERE AA.SectionKeyID = C.CrimID 
					  AND AA.ApplSectionID = 5 
					  AND AA.IsActive = 1
					FOR XML PATH('')), 1, 2, '') 
	FROM Crim AS C(NOLOCK)
	WHERE C.CrimID IN (SELECT CrimID From #IrisAliasUpdate AS S(NOLOCK))

	-- End : Insert Qualified Names into Criminal Private Notes

	--UPDATE A 
	--	SET Clear = c.Clear,
	--	BatchNumber = c.BatchNumber
	--FROM dbo.Crim c 
	--INNER JOIN #IrisAliasUpdate A ON C.Crimid = A.Crimid

	-- Insert into Audit Log - Dependencies
	INSERT INTO IrisAliasUpdate_AutoCheck_Log
				(CrimID,
				ReadyToSend,
				ReadyToSend_Old,
                txtlast,
                txtlast_old,
                txtalias,
                txtalias_old,
                txtalias2,
                txtalias2_old,
                txtalias3,
                txtalias3_old,
                txtalias4,
                txtalias4_old, 
                ApStatus, 
				Iris_Rec, 
				Clear, 
				Clear_Old,
				BatchNumber, 
				BatchNumber_Old,
				DeliveryMethod,
				CrimEnteredTime,
				InsertTimeStamp,
				DoneVia)
        SELECT	DISTINCT CrimID,
				ReadyToSend,
				ReadyToSend_Old,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0, 
                ApStatus, 
				Iris_Rec, 
				Clear, 
				Clear_Old,
				BatchNumber, 
				BatchNumber_Old,
				DeliveryMethod,
				CrimEnteredTime,
				GETDATE(),
				'AutoOrdr'
		FROM #IrisAliasUpdate 


--------- Do not Auto Order for the below Queues
--------   exec Crim_MarkToSEND 'Fax-CopyofCheck'
--------   exec Crim_MarkToSEND 'Mail'
--------   exec Crim_MarkToSEND 'NewONline'

	DROP TABLE #IrisAliasUpdate


/*
	DECLARE @APNO bigint

	CREATE TABLE #IrisAliasUpdate (
		CrimID int,
		APNO int,
		ReadyToSend bit,
		ReadyToSend_Old bit,
		ApStatus char(1), 
		Iris_Rec varchar(3), 
		[Clear] varchar(1), 
		Clear_Old varchar(1),
		BatchNumber float, 
		BatchNumber_Old float,
		DeliveryMethod varchar(50), 
		CrimEnteredTime datetime,
		CNTY_NO INT,
		Researcher_Aliases_count varchar(4),
		AliasCount int,
		IsPrimaryName bit,
		HasSpecialInstructions Bit 
	)

	-- Get all the Qualifying records to be processed for AutoOrder
	INSERT INTO #IrisAliasUpdate 
	SELECT	CrimID,
			A.APNO,
			ReadyToSend,
			ReadyToSend,
			A.ApStatus,
			Iris_Rec, 
			[Clear], 
			[Clear],			
			BatchNumber, 
			BatchNumber, 
			DeliveryMethod, 
			CrimEnteredTime,
			c.CNTY_NO,
			ISNULL(Researcher_Aliases_count,0) Researcher_Aliases_count,
			ISNULL(AliasCount,0) AliasCount,
			ISNULL(IsPrimaryName,0) IsPrimaryName,
			CASE WHEN (C.Crim_SpecialInstr IS NULL OR CAST(C.Crim_SpecialInstr AS VARCHAR(MAX)) = '') THEN 0 ELSE 1 END-- Skip the Auto Order if there are special instructions
	FROM dbo.Crim AS c(NOLOCK) 
	INNER JOIN dbo.Counties AS ct(NOLOCK) ON c.CNTY_NO = ct.CNTY_NO 
	INNER JOIN dbo.appl AS a(NOLOCK) ON c.apno = a.apno
	LEFT OUTER JOIN (SELECT APNO, COUNT(1) AS AliasCount FROM dbo.ApplAlias(NOLOCK) WHERE IsPublicRecordQualified = 1 AND IsActive = 1 GROUP BY APNO) AS Y ON A.APNO = Y.APNO
	LEFT OUTER JOIN (SELECT APNO, COUNT(IsPrimaryName) AS IsPrimaryName FROM dbo.ApplAlias(NOLOCK) WHERE IsPrimaryName = 1 GROUP BY APNO, IsPrimaryName) AS Z ON A.APNO = Z.APNO
	LEFT OUTER JOIN dbo.Iris_Researchers AS ir(NOLOCK) ON c.vENDORid = ir.R_id 
	LEFT OUTER JOIN dbo.Iris_Researcher_Charges AS irc(NOLOCK) ON irc.Researcher_id = ir.R_id AND c.CNTY_NO = irc.cnty_no
	WHERE (UPPER(A.ApStatus) IN ('P','W'))
	  AND (UPPER(C.iris_rec) = 'YES')
	  AND (C.batchnumber IS NULL OR C.batchnumber = '0')
	  AND (ISNULL(C.ReadyToSend,0) = 0)
	  AND (A.inuse IS NULL)
	  AND (A.NeedsReview NOT LIKE '%1') -- VD: 04/27/2017 -- Do Not Consider any reports for which PositiveID was not run
	  AND (A.NeedsReview NOT LIKE '%7') -- VD: 05/04/2017 -- Do Not Consider any reports when there is NO SSN
	  AND ((DATEDIFF(mi, C.Crimenteredtime, GETDATE()) >= 1  AND UPPER(C.Clear) = 'R' AND C.deliverymethod <> 'ONLINEDB') 
		OR (DATEDIFF(mi, C.Crimenteredtime, GETDATE()) >= 1  AND UPPER(C.Clear) = 'R' AND C.deliverymethod = 'ONLINEDB' AND C.cnty_no <> 2480)
		OR (DATEDIFF(mi, C.Crimenteredtime, GETDATE()) >= 20 AND UPPER(C.Clear) = 'R' AND (C.cnty_no = 2480) AND (C.deliverymethod = 'ONLINEDB') )   
		OR (C.deliverymethod LIKE 'WEB%SERVICE%' AND UPPER(C.Clear) = 'E' AND DATEDIFF(mi, C.Crimenteredtime, GETDATE()) >= 1 ))
	  AND C.deliverymethod IN ('Call_In', 'InHouse','E-Mail','Fax','ONlineDB','WEB SERVICE','Integration') 
	  AND (ISNULL(C.AutoCheckAlias,0) = 0)
	  AND C.IsHidden = 0

	--SELECT * FROM #IrisAliasUpdate i inner join counties c on i.cnty_no =c.cnty_no

-- The below update is for logic to handle any reopens that did not go through the preprocessing logic – if the alias names are missing
	UPDATE Appl
		SET InUse = 'CNTY_S',
			NeedsReview = LEFT(NeedsReview,1) + '2'
	WHERE APNO IN (SELECT DISTINCT APNO FROM #IrisAliasUpdate WHERE (AliasCount = 0 OR IsPrimaryName = 0)) AND (InUse IS NULL)

	-- Delete any App's that have AliasCount = 0 from main set
	DELETE #IrisAliasUpdate WHERE CrimID IN (SELECT CrimID FROM #IrisAliasUpdate WHERE AliasCount = 0 )
-- The below update is for logic to handle any reopens that did not go through the preprocessing logic – if the alias names are missing

	-- Get all the records that needs to be skipped. i.e When it finds the same Criminal Counties more than once and plugging in the Private Notes.
	SELECT DISTINCT C.* 
		INTO #tmpSkipAutoOrder 
	FROM #IrisAliasUpdate AS C 
	INNER JOIN (SELECT APNO, MAX(CrimID) AS CrimID, County, COUNT(CNTY_NO) NumOfCounties
				FROM Crim(NOLOCK) 
				GROUP BY APNO, County
				HAVING COUNT(CNTY_NO) > 1) AS Y ON C.APNO = Y.APNO AND C.CrimID = Y.CrimID

	--SELECT * FROM #tmpSkipAutoOrder
	
	-- Delete the records that have more than one similar county from the main resultset
	DELETE #IrisAliasUpdate WHERE CrimID IN (SELECT CrimID FROM #tmpSkipAutoOrder)

	-- Get all the Private Notes that was sent earlier and append
	SELECT	APNO,
			CrimID,
			CNTY_NO,
			REPLACE(STUFF('  Previously Sent Names: ' + (SELECT '; ' + ISNULL(Priv_Notes,'')
					FROM Crim AS B(NOLOCK)
					WHERE (B.APNO = A.APNO AND B.CNTY_NO = A.CNTY_NO)
					  AND Priv_Notes LIKE '%Names Sent:%' 
					  AND ISNULL(Priv_Notes,'') <> '' 
					  AND B.CrimID != A.CrimID
					ORDER BY CrimID DESC
					FOR XML PATH('')), 1, 2, ''),'; ', char(13) + char(10)) AS Priv_Notes
		INTO #tmpUpdatePrivateNotes
	From #tmpSkipAutoOrder AS A

	--SELECT * FROM crim where casT(Apno as varchar) + cast(cnty_no as varchar) in (select casT(Apno as varchar) + cast(cnty_no as varchar) from #tmpUpdatePrivateNotes) order by apno,county
	--select * from #tmpUpdatePrivateNotes

	-- Update the skipped CrimID's Private Notes, so that the Public Records investigtaor knows what were sent earlier in Order Management
	--SELECT C.APNO,C.CNTY_NO, C.County, C.CrimID, C.Priv_Notes, P.APNO, P.CNTY_NO, P.Priv_Notes
	UPDATE C
		SET C.Priv_Notes = ISNULL(P.Priv_Notes,'') + ISNULL(C.Priv_Notes,'')
	FROM CRIM AS C
	INNER JOIN #tmpUpdatePrivateNotes AS P ON C.CrimID = P.CrimID
	WHERE ISNULL(C.PRIV_NOTES,'') NOT LIKE '%Previously Sent Names:%'
	  AND ISNULL(P.Priv_Notes,'') <> ''

	DROP TABLE #tmpSkipAutoOrder
	DROP TABLE #tmpUpdatePrivateNotes

	-- Delete all searches that do not qualify for AutoOrder because the number of aliases exceeds what the vendor allows - forcing them to goto Order Management
	DELETE #IrisAliasUpdate 
	WHERE ((CASE WHEN Researcher_Aliases_count = 'All' THEN 5 ELSE Researcher_Aliases_count END) <  AliasCount	)
	OR   (HasSpecialInstructions = 1)
	

	-- Lock the application for AutoOrder service.
	UPDATE A
		SET A.InUse = 'ChkAlias'
	FROM Appl AS A(NOLOCK)
	INNER JOIN #IrisAliasUpdate AS T ON A.APNO = T.APNO

	UPDATE A 
		SET ReadyToSend = 1,
			BatchNumber=0,
			[Clear] = ''
	FROM #IrisAliasUpdate A
	LEFT JOIN dbo.ApplAlias AS AA(NOLOCK) ON A.APNO = AA.APNO AND AA.IsPublicRecordQualified = 1 AND AA.IsActive=1

	-- Insert into ApplAlias_Sections when these records are Sent by Winservice i.e. when count is set to all
	INSERT INTO [dbo].[ApplAlias_Sections]([ApplSectionID],[SectionKeyID],[ApplAliasID],[IsActive],[CreatedBy], [LastUpdatedBy])
		SELECT DISTINCT 5 , I.CrimID , AA.ApplAliasID, 1 , 'AutoOrdr', 'AutoOrdr' 
		FROM #IrisAliasUpdate AS I
		LEFT JOIN dbo.ApplAlias AS AA(NOLOCK) ON I.APNO = AA.APNO
		WHERE IsPublicRecordQualified = 1 AND AA.IsActive = 1 

	-- This statement below will skip the county to be skiped in next sweep
	-- This is done in order to eliminate any issues with countys stuck in pending for long time. This may not be an issue but trying this work around -- kiran	,1/29/2013				
	UPDATE C 
		SET AutoCheckAlias = 1,
			ReadyToSend = A.ReadyToSend
	FROM dbo.Crim C 
	INNER JOIN #IrisAliasUpdate A ON C.CrimID = A.CrimID

	EXEC dbo.Crim_MarkToSend_AutoOrder 'Call_In','AutoOrdr'
	
	EXEC dbo.Crim_MarkToSend_AutoOrder 'InHouse','AutoOrdr'

	EXEC dbo.Crim_MarkToSend_AutoOrder 'E-Mail','AutoOrdr'

	EXEC dbo.Crim_MarkToSend_AutoOrder 'Fax','AutoOrdr'

	EXEC dbo.Crim_MarkToSend_AutoOrder 'OnlineDB','AutoOrdr'

	EXEC dbo.Crim_MarkToSend_AutoOrder 'WEB SERVICE','AutoOrdr'
	
	UPDATE dbo.Appl
		SET InUse = NULL
	WHERE InUse = 'ChkAlias'

	-- Start : Insert Qualified Names into Criminal Private Notes

	UPDATE C
		SET C.Priv_Notes = STUFF('  AutoOrdr' + ', ' + CAST(CURRENT_TIMESTAMP AS VARCHAR) + ', Names Sent: ' + (SELECT ISNULL(First,'') +' '+ ISNULL(Middle,'') +' '+ ISNULL(Last,'') +' '+ ISNULL(Generation,'') + ', '
					FROM dbo.ApplAlias_Sections AS AA (NOLOCK)
					INNER JOIN ApplAlias AS A(NOLOCK) ON AA.ApplAliasID = A.ApplAliasID
					WHERE AA.SectionKeyID = C.CrimID 
					  AND AA.ApplSectionID = 5 
					  AND AA.IsActive = 1
					FOR XML PATH('')), 1, 2, '') 
	FROM Crim AS C
	WHERE C.CrimID IN (SELECT CrimID From #IrisAliasUpdate AS S(NOLOCK))

	-- End : Insert Qualified Names into Criminal Private Notes

	UPDATE A 
		SET Clear = c.Clear,
		BatchNumber = c.BatchNumber
	FROM dbo.Crim c 
	INNER JOIN #IrisAliasUpdate A ON C.Crimid = A.Crimid

	-- Insert into Audit Log - Dependencies
	INSERT INTO IrisAliasUpdate_AutoCheck_Log
				(CrimID,
				ReadyToSend,
				ReadyToSend_Old,
                txtlast,
                txtlast_old,
                txtalias,
                txtalias_old,
                txtalias2,
                txtalias2_old,
                txtalias3,
                txtalias3_old,
                txtalias4,
                txtalias4_old, 
                ApStatus, 
				Iris_Rec, 
				Clear, 
				Clear_Old,
				BatchNumber, 
				BatchNumber_Old,
				DeliveryMethod,
				CrimEnteredTime,
				InsertTimeStamp,
				DoneVia)
        SELECT	DISTINCT CrimID,
				ReadyToSend,
				ReadyToSend_Old,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0, 
                ApStatus, 
				Iris_Rec, 
				Clear, 
				Clear_Old,
				BatchNumber, 
				BatchNumber_Old,
				DeliveryMethod,
				CrimEnteredTime,
				GETDATE(),
				'AutoOrdr'
		FROM #IrisAliasUpdate 


--------- Do not Auto Order for the below Queues
--------   exec Crim_MarkToSEND 'Fax-CopyofCheck'
--------   exec Crim_MarkToSEND 'Mail'
--------   exec Crim_MarkToSEND 'NewONline'

	DROP TABLE #IrisAliasUpdate
*/

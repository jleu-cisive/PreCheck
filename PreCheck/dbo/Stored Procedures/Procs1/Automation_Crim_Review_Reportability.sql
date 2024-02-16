
/*
 =============================================
 Author:	Kiran Miryala
 Create date: 7/21/2016
 Description: Automation of reporting misdemeanors
 Modified By: Deepak Vodethela
 Modified Date: 10/14/2019
 Description:  Limit Reporting of Misdemeanor and Lower Level Degrees by Client Affiliate for Client Advent
 Modified Date: 05/11/2020
 Description:  Add ZipCrim changes. Route Record Founds and Clears with Disclosures to Review Reportability Queue
 Modified Date: 05/28/2020
 Description:  eVerifle changes for Renovo
 Modified By: Santosh Chapyala
 Modified Date: 11/05/2020
 Description: Added a new clientID for strategic clients and configure reporting rules
 Modified By: Deepak Vodethela	
 Modified Date: 11/11/2020
 Description: TP# 95126 - Oasis: Send response to Zipcrim after all searches are complete. Removed Clear = 'F' for 249 (everifile/zipcrim)
 Modified Date: 11/19/2020
 Description:  TP#92575 - PreCheck: Part B to 91980 Create another clear status for internal clears to handle disclosures
 VD:12/21/2020 - TP#92767 - PreCheck: Lead sent to ZipCrim before "Review Reportability Service" Update. Introduced RefCrimStageID = 4 (Review Reportability Service Completed)
 VD:01/19/2020 - TP#92767 - Update "Review Reportability Completed" status to Affiliate's (4,5,229,230,231,249) and also for MIN, See Attached and Cancelled statuses
 VD:03/08/2021 - As part of code review, the Table Variables have been changed to Temporary Tables
 =============================================
  */
CREATE PROCEDURE [dbo].[Automation_Crim_Review_Reportability]
	
AS
BEGIN
SET NOCOUNT ON

	DROP TABLE IF EXISTS #TblReview_InitialList;
	DROP TABLE IF EXISTS #TblCrim;
	DROP TABLE IF EXISTS #TblCrimExceptions;
	DROP TABLE IF EXISTS #ReportableMisdemeanor;
	DROP TABLE IF EXISTS #NotReportableLowerLevelMisdemeanors;
	DROP TABLE IF EXISTS #Felony;

	CREATE TABLE #TblReview_InitialList([APNO] INT, AffiliateID int, CLNO Int)

	CREATE TABLE #TblCrim ([APNO] INT, AffiliateID int, CLNO Int, CrimID Int, [Clear] varchar(1),Cnty_No Int,County varchar(40),
							  Degree varchar(1), Disp_Date datetime, Date_Filed datetime,Ordered varchar(20),
							  Priv_Notes varchar(max), txtalias char(2), txtalias2 char(2), txtalias3 char(2), txtalias4 char(2), 
							  txtlast char(2), Crimenteredtime datetime, 
							  IRIS_REC varchar(3), vendorid varchar(50),refDispositionID Int,skipReview Bit,refDispositionTypeID int,
							  PartnerReferenceLeadNumber varchar(50))

	CREATE TABLE #TblCrimExceptions (CrimID Int,ExceptionNotes varchar(1000))

	CREATE TABLE #ReportableMisdemeanor ([MisdemeanorValues] CHAR)
	CREATE TABLE #NotReportableLowerLevelMisdemeanors ([LowerLevelMisdemeanorValues] CHAR)
	CREATE TABLE #ReportableLowerLevelMisdemeanors ([ReportableLowerLevelMisdemeanorValues] CHAR)
	CREATE TABLE #Felony ([FelonyValues] CHAR)
	DECLARE @Past7Years DATE = DATEADD(yyyy,-7,CONVERT (DATE, CURRENT_TIMESTAMP))
	DECLARE @Past10Years DATE = DATEADD(yyyy,-10,CONVERT (DATE, CURRENT_TIMESTAMP)) 
	DECLARE @Zipcrim_eRailSafe_ERSB_CLNO INT = 16024 --(Prod: 16024) --(Test: 15869)
	DECLARE @Zipcrim_eRailSafe_ERSB_Priority_CLNO INT = 16469 --(Prod: 16469) --(Test: 16289)
	DECLARE @ZipCrim_7Years_CLNO INT = 16023 --(Prod: 16023) --(Test: 15868)
	DECLARE @ZipCrim_10Years_CLNO INT = 16022 --(Prod: 16022) --(Test: 15867)
               
	-- Misdemeanor Values Variable 
	INSERT INTO #ReportableMisdemeanor
			SELECT rcd.refCrimDegree FROM dbo.refCrimDegree rcd WHERE rcd.refCrimDegree IN ('1','2','3','4','5','6','7','8','M') 

	-- Lower Level Misdemeanor Values Variables - Not Reportable
	INSERT INTO #NotReportableLowerLevelMisdemeanors
			SELECT rcd.refCrimDegree FROM dbo.refCrimDegree rcd WHERE rcd.refCrimDegree IN ('3','4','5','6','8')

	-- Lower Level Misdemeanor Values Variable - Reportable
	INSERT INTO #ReportableLowerLevelMisdemeanors
			SELECT rcd.refCrimDegree FROM dbo.refCrimDegree rcd WHERE rcd.refCrimDegree IN ('1','2','7','M')

	-- Felony Values Variable
	INSERT INTO #Felony
			SELECT rcd.refCrimDegree FROM dbo.refCrimDegree rcd WHERE rcd.refCrimDegree IN ('F','9') 

	--SELECT '#ReportableMisdemeanor' AS TableName, * FROM #ReportableMisdemeanor
	--SELECT '#Felony' AS TableName, * FROM #Felony

	--Get the initial Qualified list of Apps that qualify for review reportability
	INSERT INTO #TblReview_InitialList
	SELECT A.Apno, C.AffiliateID,A.CLNO
	FROM dbo.Appl A with (nolock)  
	LEFT JOIN (SELECT COUNT(1) cnt, APNO 
				FROM dbo.Crim with (nolock) 
				WHERE ISNULL(CLEAR,'') = 'F'
					AND IsHidden = 0 
					AND RefCrimStageID = 2 -- Include "ReOrder Servce Completed" crims only 
				GROUP BY Apno) Crim1 ON A.APNO = Crim1.APNO
	INNER JOIN Client C ON a.CLNO = C.CLNO AND c.AffiliateID IN (4,5,229,230,231) -- 4(HCA), 5(HCA - Parallon),229(AdventHealth - MedStaff),230(AdventHealth), 231(AdventHealth - Volunteers)
	WHERE A.ApStatus IN ('P', 'W') 
	 AND (Crim1.apno IS NOT NULL)
	 AND A.InUse IS NULL 
	 AND ISNULL(A.Investigator, '') <> '' 
	 AND A.userid IS NOT NULL 
	 AND ISNULL(A.CAM, '') = '' 

	--249 (everifile/zipcrim)
	INSERT INTO #TblReview_InitialList
	SELECT A.Apno, C.AffiliateID,A.CLNO
	FROM dbo.Appl A with (nolock)  
	LEFT JOIN (SELECT COUNT(1) cnt, APNO 
				FROM dbo.Crim with (nolock) 
				WHERE ISNULL(CLEAR,'') in ('T','F')
					AND IsHidden = 0 
					AND RefCrimStageID = 2 -- Include "ReOrder Servce Completed" crims only 
				GROUP BY Apno) Crim1 ON A.APNO = Crim1.APNO
	INNER JOIN Client C ON a.CLNO = C.CLNO AND c.AffiliateID IN (249) --249 (everifile/zipcrim)
	WHERE A.ApStatus IN ('P', 'W') --'F') --> 11/11/2020 : Deepak - for TP# 95126
	 AND (Crim1.apno IS NOT NULL)
	 AND A.InUse IS NULL 
	 AND ISNULL(A.Investigator, '') <> '' 
	 AND A.userid IS NOT NULL 
	 AND ISNULL(A.CAM, '') = '' 

	-- for (everifile/zipcrim) clients to handle "MIN, See Attached and Cancelled"
	INSERT INTO #TblReview_InitialList
	SELECT A.Apno, C.AffiliateID,A.CLNO
	FROM dbo.Appl A with (nolock)  
	LEFT JOIN (SELECT COUNT(1) cnt, APNO 
				FROM dbo.Crim with (nolock) 
				WHERE ISNULL(CLEAR,'') IN ('P','S','C')
					AND IsHidden = 0 
					AND RefCrimStageID = 2 -- Include "ReOrder Servce Completed" crims only 
				GROUP BY Apno) Crim1 ON A.APNO = Crim1.APNO
	INNER JOIN Client C ON a.CLNO = C.CLNO AND c.AffiliateID IN (249) --249 (everifile/zipcrim)
	WHERE A.ApStatus IN ('P', 'W') --'F') --> 11/11/2020 : Deepak - for TP# 95126
	 AND (Crim1.apno IS NOT NULL)
	 AND A.InUse IS NULL 
	 AND ISNULL(A.Investigator, '') <> '' 
	 AND A.userid IS NOT NULL 
	 AND ISNULL(A.CAM, '') = '' 

	-- for All clients to handle "Clear Internal"
	INSERT INTO #TblReview_InitialList
	SELECT A.Apno, C.AffiliateID, A.CLNO
	FROM dbo.Appl A with (nolock)  
	LEFT JOIN (SELECT COUNT(1) cnt, APNO 
				FROM dbo.Crim with (nolock) 
				WHERE ISNULL(CLEAR,'') in ('B')
					AND IsHidden = 0 
				GROUP BY Apno) Crim1 ON A.APNO = Crim1.APNO
	INNER JOIN Client C ON a.CLNO = C.CLNO 
	WHERE A.ApStatus IN ('P', 'W')
	 AND (Crim1.apno IS NOT NULL)
	 AND A.InUse IS NULL 
	 AND ISNULL(A.Investigator, '') <> '' 
	 AND A.userid IS NOT NULL 
	 AND ISNULL(A.CAM, '') = '' 

	-- for All clients to handle "Clear Internal"
	INSERT INTO #TblCrim
	SELECT t.[APNO] , AffiliateID , t.CLNO , CrimID , [Clear] ,Cnty_No ,County, Degree , Disp_Date , Date_Filed , Ordered,
			Priv_Notes , txtalias , txtalias2 , txtalias3 , txtalias4 , txtlast , Crimenteredtime , IRIS_REC , vendorid,refDispositionID,
			1,0, c.PartnerReferenceLeadNumber
	FROM #TblReview_InitialList t 
	INNER JOIN Crim c (Nolock) ON t.APNO = c.APNO
	WHERE c.IsHidden = 0 
	  --AND ISNULL(CLEAR,'') IN ('B') --> VD: 02/02/2021
	  AND ISNULL(CLEAR,'') IN ('P','S','C','B') --VD:02/02/2021 - TP#92767 - Update "Review Reportability Completed"
	  
	-- Get all the "Record Found and Active" Crims which are NOT present in the [Crim_ReviewReportabilityLog] table	
	INSERT INTO #TblCrim
	SELECT t.[APNO] , AffiliateID , CLNO , CrimID , [Clear] ,Cnty_No ,County, Degree , Disp_Date , Date_Filed , Ordered,
			Priv_Notes , txtalias , txtalias2 , txtalias3 , txtalias4 , txtlast , Crimenteredtime , IRIS_REC , vendorid ,refDispositionID,0,0,
			c.PartnerReferenceLeadNumber
	FROM #TblReview_InitialList t 
	INNER JOIN Crim c (Nolock) ON t.APNO = c.APNO 
	--AND (SELECT COUNT(1) 
	--	 FROM [Crim_ReviewReportabilityLog] r 
	--	 WITH (NOLOCK) WHERE r.crimid = c.crimid ) = 0 -- VD:12/22/2020 - Removed Reportability Log dependency
	WHERE c.IsHidden = 0 
	  AND ISNULL(CLEAR,'') = 'F'
	  AND C.RefCrimStageID = 2 -- Include "ReOrder Servce Completed" crims only 


	INSERT INTO #TblCrim
	SELECT t.[APNO] , AffiliateID , t.CLNO , CrimID , [Clear] ,Cnty_No ,County, Degree , Disp_Date , Date_Filed , Ordered,
			Priv_Notes , txtalias , txtalias2 , txtalias3 , txtalias4 , txtlast , Crimenteredtime , IRIS_REC , vendorid,refDispositionID,
			Case when (ISNULL(CLEAR,'') = 'T' AND Priv_Notes LIKE '%***Disclosures***\nYes\%' 			
			--Case when (Priv_Notes LIKE '%***Disclosures***\nYes\%'  --VD:11/19/2020
			--Case when (CRIM_SpecialInstr LIKE '%***Disclosures***\nYes\%' 
	  --OR ISNULL(Crim_SelfDisclosed,0) = 1 --UNCOMMENT IF WE NEED TO CONSIDER ADMITTED/SELF-DISCLOSED RECORDS --JUNE MENTIONED EVERIFILE DOES NOT SHARE
	  ) then 0 else 1 end,0, c.PartnerReferenceLeadNumber
	FROM #TblReview_InitialList t 
	INNER JOIN Crim c (Nolock) ON t.APNO = c.APNO
	--LEFT JOIN DBO.ApplAdditionalData A (NOLOCK) ON T.APNO = A.APNO --UNCOMMENT IF WE NEED TO CONSIDER ADMITTED/SELF-DISCLOSED RECORDS --JUNE MENTIONED EVERIFILE DOES NOT SHARE
	--AND (SELECT COUNT(1) 
	--	 FROM [Crim_ReviewReportabilityLog] r 
	--	 WITH (NOLOCK) WHERE r.crimid = c.crimid ) = 0 -- VD:12/22/2020 - Removed Reportability Log dependency
	WHERE c.IsHidden = 0 
	  AND ISNULL(CLEAR,'') IN ('T')	
	  AND C.RefCrimStageID = 2 -- Include "ReOrder Servce Completed" crims only 

	--select * from #TblReview_InitialList
	--Select * from #TblCrim

	--SELECT '#TblReview_InitialList' AS TableName, * FROM #TblReview_InitialList
	--SELECT '#tempCrim' AS TableName, t.Apno, t.AffiliateID, t.Degree, t.Disp_Date, t.Date_Filed, t.County, t.Cnty_No, t.[Clear], * FROM #tempCrim AS t ORDER BY t.AffiliateID DESC   

	-- Insert new Crims in [Crim_ReviewReportabilityLog] table
	INSERT INTO [dbo].[Crim_ReviewReportabilityLog]
					([CrimID]
					,[APNO]
					,[County]
					,[Clear]
					,[Degree]
					,[Disp_Date])
					(
			SELECT	[CrimID]
					,[APNO]
					,[County]
					,[Clear]
					,[Degree]
					,[Disp_Date] 
			FROM #TblCrim c
			WHERE c.AffiliateID IN (4,5,229,230,231,249)
					)

	-- Update "Clear Internal - B" status to "Clear"
	UPDATE C 
		SET C.CLEAR = 'T', C.Last_Updated = CURRENT_TIMESTAMP
	FROM CRIM C 
	INNER JOIN #TblCrim AS t ON c.CrimID = t.CrimID
	WHERE t.Clear = 'B'

	-- Insert into ChangeLog
	INSERT INTO dbo.ChangeLog
	(
		--HEVNMgmtChangeLogID - column value is auto-generated
		TableName,
		ID,
		OldValue,
		NewValue,
		ChangeDate,
		UserID
	)
	SELECT 'Crim.Clear', c.CrimID,'B','T', CURRENT_TIMESTAMP,'RRSvc'
	FROM #TblCrim AS c
	WHERE c.Clear = 'B'

	-- Update the "Review Reportability Service Completed status" for AffiliateID IN (4,5,229,230,231,249) 
	--SELECT '#TblCrim - Update  ', *
		UPDATE C SET C.RefCrimStageID = 4
	FROM dbo.Crim AS c
	INNER JOIN #TblCrim AS t ON c.CrimID = t.CrimID
	WHERE (skipReview = 1 OR AffiliateID IN (4,5,229,230,231,249))

	/* --VD:02/02/2021 - TP#92767 - Update "Review Reportability Completed"
	-- Update the "Review Reportability Service Completed" status for "MIN", "See Attached" and "Cancelled" status for AffiliateID's IN (4,5,229,230,231,249)
	--SELECT '#TblCrim - Update  ', *
		UPDATE C SET C.RefCrimStageID = 4
	FROM dbo.Crim AS c
	INNER JOIN #TblCrim AS t ON c.APNO = t.APNO
	WHERE (AffiliateID IN (4,5,229,230,231,249) AND C.[Clear] IN ('P','S','C'))
	  AND C.IsHidden = 0
	  */

    --Drop Clears that do not need Review - no disclosures
	DELETE #TblCrim
	Where (skipReview = 1 OR AffiliateID NOT IN (4,5,229,230,231,249))

	--Update the DispositionType for applying for review reportability business rules
	Update T Set refDispositionTypeID = isnull(D.refDispositionTypeID,0)
	From #TblCrim T left join refDisposition D on T.refDispositionID = D.refDispositionID

	-- Report record WHERE Degree is misdemeanor AND disposition DATE is with IN seven years.
	-- If no Disposition DATE, do the following:
	-- Reference the file DATE
	-- If the file DATE is within 7 years we do nothing (Those are true pending orders that will need to be reported)
	-- If the file DATE is beyond 7 years it will go to INTO review reportability status no matter what the degree is
	-- If there is no file DATE listed it will go to INTO review reportability status no matter what the degree is

	--Removed 9 from the exception list as it needs to be considered as a Felony - always reportable
	--schapyala on 09/20

	-- Get all the Reportable Crims which have file DATE is beyond 7 years which includes Misdemeanor and Felony Degrees
	DROP TABLE IF EXISTS #tempCrimReportable
	SELECT * 
		INTO #tempCrimReportable 
	FROM #TblCrim T
	WHERE T.[CLEAR] = 'F' 
	 AND (
			-- Check who is this for ..
			CASE 
				WHEN T.AffiliateID IN (229,230,231) THEN -- If it is advent..
					-- Now check if this is non reportable..
					CASE 
						WHEN t.Degree IN (SELECT m.ReportableLowerLevelMisdemeanorValues FROM #ReportableLowerLevelMisdemeanors m) 
									AND (t.Disp_Date >= @Past7Years OR Date_Filed >=  @Past7Years) 
								THEN 1 -- Reportable misdemeanors within 7 years
						WHEN t.Degree IN (SELECT m.FelonyValues FROM #Felony m) 
								THEN 1 -- Felony is always Reportable irrespective of dates
						ELSE 0 -- everything else is not reportable 
					END

				-- If it is HCA..
				WHEN T.AffiliateID IN (4,5) THEN  
					CASE -- Check misdemeanor/felony
						WHEN t.Degree IN (SELECT m.MisdemeanorValues FROM #ReportableMisdemeanor m) 
										AND (t.Disp_Date >= @Past7Years OR Date_Filed >=  @Past7Years) 
								THEN 1-- Misdemeanor within 7 years
						WHEN t.Degree IN (SELECT m.FelonyValues FROM #Felony m) 
								THEN 1 -- -- Felony is always Reportable irrespective of dates
						ELSE 0 -- everything else is not reportable 
					END 

				-- If it is Zipcrim/eRailsafe..
				WHEN T.AffiliateID IN (249) THEN  
					CASE -- For ZIPCRIM 10 YEARS
						WHEN t.CLNO= @ZipCrim_10Years_CLNO AND refDispositionTypeID NOT IN (2,3) AND (t.Disp_Date <= @Past10Years OR Date_Filed <=  @Past10Years) 
								THEN 1 --Reportable within 10 years

						-- For ZIPCRIM 7 YEARS and ZIPCRIM 99 YEARS
						WHEN t.CLNO in (@ZipCrim_7Years_CLNO,@Zipcrim_eRailSafe_ERSB_CLNO,@Zipcrim_eRailSafe_ERSB_Priority_CLNO) AND refDispositionTypeID NOT IN (2,3) AND (t.Disp_Date <= @Past7Years OR Date_Filed <=  @Past7Years) 
								THEN 1  --Reportable within 7 years

						-- everything else is not reportable
						ELSE 0  
					END

				Else 
					0  -- everything  is not reportable 
			END = 1
		)                                                                                            
                                                                                                  
	--SELECT '#tempCrimReportable' AS TableName, t.Apno, t.AffiliateID, t.Degree, t.Disp_Date, t.Date_Filed, t.County, t.Cnty_No, t.[Clear], * FROM #tempCrimReportable AS T ORDER BY t.AffiliateID DESC                

	-- Do not report any record WHERE Degree is misdemeanor AND disposition DATE is more then seven years old.
	DROP TABLE IF EXISTS #tempCrimUnReportable
	SELECT * 
		INTO #tempCrimUnReportable 
	FROM #TblCrim AS T
	WHERE [CLEAR] = 'F' 
	 AND (
			-- Check who is this for ..
			CASE 
				WHEN T.AffiliateID IN (229,230,231) THEN -- If it is advent..
					-- Now check if this is non reportable..
					CASE 
						WHEN T.Degree IN (SELECT m.LowerLevelMisdemeanorValues FROM #NotReportableLowerLevelMisdemeanors m) THEN 0 -- non reportable misdemeanors
						ELSE 1 -- everything else is reportable 
					END

				-- If it is HCA..
				WHEN T.AffiliateID IN (4,5) THEN   
					CASE -- Check misdemeanor/felony
						WHEN t.Degree IN (SELECT m.MisdemeanorValues FROM #ReportableMisdemeanor m)  AND ((CONVERT (DATE, Disp_Date) <  @Past7Years )) THEN 0 -- Misdemeanor
						ELSE 1 -- everything else is reportable 
					END 

				-- If it is zipcrim/everifile..
				WHEN T.AffiliateID IN (249) THEN   
					CASE 
						-- dont report Infractions, Ordinance Violations, Disorderly Persons, or Summary Offense
						WHEN t.Degree IN ('5','6','7','8')  THEN 0 

						-- dont report Petty Misdemeanor and the jurisdiction state is equal to “MN” -- UPDATED FROM NOT EQUAL TO EQUAL ON 06/01
						WHEN t.Degree IN ('1')  and county like '%MN' THEN 0 

						--dO NOT REPORT Non-Conviction
						WHEN refDispositionTypeID = 2 THEN 0 

						ELSE 1 -- everything else is reportable 
					END

				Else 
					1 -- everything is reportable 
			END = 0
		)

	--SELECT '#tempCrimReportable' AS TableName,t.Apno, t.AffiliateID, t.Degree, t.Disp_Date, t.Date_Filed, t.County, t.Cnty_No, t.[Clear], * FROM #tempCrimReportable AS t ORDER BY t.AffiliateID DESC, T.CrimID DESC
	--SELECT '#tempCrimUnReportable' AS TableName, t.Apno, t.AffiliateID, t.Degree, t.Disp_Date, t.Date_Filed, t.County, t.Cnty_No, t.[Clear], * FROM #tempCrimUnReportable AS t ORDER BY t.AffiliateID DESC, T.CrimID DESC

	--SELECT '#tempCrimReportable' AS TableName,t.Apno, t.AffiliateID, t.Degree, t.Disp_Date, t.Date_Filed, t.County, t.Cnty_No, t.[Clear], * FROM #tempCrimReportable AS t WHERE T.AffiliateID IN (229,230,231) ORDER BY t.AffiliateID DESC, T.CrimID DESC
	--SELECT '#tempCrimUnReportable' AS TableName,t.Apno, t.AffiliateID, t.Degree, t.Disp_Date, t.Date_Filed, t.County, t.Cnty_No, t.[Clear], * FROM #tempCrimUnReportable AS t WHERE T.AffiliateID IN (229,230,231) ORDER BY t.AffiliateID DESC, T.CrimID DESC

	-- Get all the Crim's which are NOT Reportable 
	DROP TABLE IF EXISTS #tempMasterTounused
	SELECT C.* 
		INTO #tempMasterTounused 
	FROM #TblCrim c 
	INNER JOIN #tempCrimUnReportable u ON u.apno = c.apno AND u.CrimID <> c.CrimID AND u.CNTY_NO = c.CNTY_NO  
	WHERE c.crimid NOT IN (SELECT Crimid FROM #tempCrimUnReportable)
                
	--SELECT '#tempMasterTounused' AS TableName,t.Apno, t.AffiliateID, t.Degree, t.Disp_Date, t.Date_Filed, t.County, t.Cnty_No, t.[Clear], * FROM #tempMasterTounused AS T ORDER BY t.AffiliateID DESC, T.CrimID DESC

	-- Mark the Crim's as NOT Reportable
	DROP TABLE IF EXISTS #tempTounused
	SELECT u.* 
		INTO #tempTounused 
	FROM #tempMasterTounused c 
	INNER JOIN #tempCrimUnReportable u ON u.apno = c.apno AND u.CNTY_NO = c.CNTY_NO

	--SELECT DISTINCT '#tempTounused' AS TableName,t.Apno, t.AffiliateID, t.Degree, t.Disp_Date, t.Date_Filed, t.County, t.Cnty_No, t.[Clear], * FROM #tempTounused AS T ORDER BY t.AffiliateID DESC, T.CrimID DESC

	--Move the crims to unused when they are NOT Reportable
	UPDATE dbo.Crim 
		SET IsHidden = 1, 
		Priv_Notes = CAST( CURRENT_TIMESTAMP as varchar) + ' - Record not reportable due to client reporting guidelines, moved MASTER record to unused by Review Reportability service;  ' + Priv_Notes
	WHERE CrimID IN (SELECT crimid FROM #tempTounused)

	--SELECT 'Crim' AS TableName, * FROM Crim c WHERE c.CrimID IN (SELECT crimid FROM #tempTounused)
	DROP TABLE IF EXISTS #tempDistinctCrimUnReportable
	SELECT DISTINCT APNO,CNTY_NO, County, min(CrimID) CrimID 
		INTO #tempDistinctCrimUnReportable 
	FROM #tempCrimUnReportable 
	GROUP BY APNO,CNTY_NO, County 

	DROP TABLE IF EXISTS #TempNoInsertRecord
	SELECT t1.APNO,t1.CNTY_NO, t1.County, t1.CrimID 
		INTO #TempNoInsertRecord 
	FROM #tempDistinctCrimUnReportable t1 
	INNER JOIN #tempCrimReportable t2 ON t1.apno = t2.apno AND t1.CNTY_NO = t2.CNTY_NO  

	--SELECT '#tempDistinctCrimUnReportable' AS TableName,  * FROM #tempDistinctCrimUnReportable AS t
	--SELECT '#TempNoInsertRecord' AS TableName, * FROM #TempNoInsertRecord AS t

	INSERT INTO dbo.Crim(APNO, County, [Clear], Ordered,  DOB, SSN,  Pub_Notes, Priv_Notes, txtalias,
							txtalias2, txtalias3, txtalias4, txtlast,Crimenteredtime,
							Last_Updated, CNTY_NO, IRIS_REC, vendorid, RefCrimStageID, PartnerReferenceLeadNumber
	) 
	SELECT  APNO, County, 'T', Ordered,  NUll, Null, Null, 
			CAST( CURRENT_TIMESTAMP as varchar) + ' - Original Record not reportable due to client reporting guidelines- set to unused and CLEAR record created by Review Reportability service;  ' + Priv_Notes, txtalias, txtalias2, txtalias3, txtalias4, 
			txtlast, Crimenteredtime, 
			CURRENT_TIMESTAMP, CNTY_NO, IRIS_REC, vendorid, 
			4 -- Set the new entry to "Review Reportability Completed status"
			, PartnerReferenceLeadNumber
	FROM #tempCrimUnReportable  
	WHERE crimid NOT IN (SELECT crimid FROM #tempTounused) 
	  AND crimid IN (SELECT crimid FROM #tempDistinctCrimUnReportable)
	  AND crimid NOT IN (SELECT crimid FROM #TempNoInsertRecord)

	--Move the crims to unused after creating a clear record when they are not reportable
	UPDATE Crim 
		SET IsHidden = 1 ,
		Priv_Notes = CAST( CURRENT_TIMESTAMP as varchar) + ' - Record not reportable due to client reporting guidelines, moved original record to unused and replaced with a clear record by Review Reportability service;  ' + Priv_Notes
	WHERE CrimID IN (SELECT crimid 
					 FROM #tempCrimUnReportable 
					 WHERE crimid NOT IN (SELECT crimid 
										  FROM #tempTounused))

	--SELECT '#Text' AS TableName, APNO, County, 'T', Ordered,  NUll, Null, Null, 
	--		CAST( CURRENT_TIMESTAMP as varchar) + ' - Moved original record to Unused by Review Reportability service.  ' + ISNULL(Priv_Notes,''), txtalias, txtalias2, txtalias3, txtalias4, 
	--		txtlast, Crimenteredtime, 
	--		CURRENT_TIMESTAMP, CNTY_NO, IRIS_REC, vendorid
	--FROM #tempCrimUnReportable  
	--WHERE crimid NOT IN (SELECT crimid FROM #tempTounused) 
	-- AND crimid IN (SELECT crimid FROM #tempDistinctCrimUnReportable)
	-- AND crimid NOT IN (SELECT crimid FROM #TempNoInsertRecord)

	--SELECT '#Crim - Message' AS TableName, * FROM Crim WHERE CrimID IN (SELECT crimid FROM #tempCrimUnReportable WHERE crimid NOT IN  (SELECT crimid FROM #tempTounused))
                
	-- Do not report any record WHERE Degree is misdemeanor AND disposition DATE is more than seven years old.
	INSERT INTO #TblCrimExceptions
	SELECT [CrimID],ExceptionNotes = CAST( CURRENT_TIMESTAMP as varchar) + ': Moved to Review reportability based on defined business rules; '
	FROM #TblCrim 
	WHERE [Clear] = 'F' 
	 AND (
			--if ZipCrim - temporary - schapyala 04/30/2020
			(
				(affiliateid =249 AND						
					(
						((ISNULL(Disp_Date,'') = '') AND (ISNULL(Date_Filed,'') = ''))
						OR
						--Disposition date beyond 7 years from present date and equal to CLNO 16024 (Zipcrim eRailSafe-ERSB), send to Review Reportability for manual review. 
						(CLNO in (@Zipcrim_eRailSafe_ERSB_CLNO,@Zipcrim_eRailSafe_ERSB_Priority_CLNO) AND (Disp_Date > @Past7Years OR Date_Filed >  @Past7Years) )
						OR
						--Route to RR for PRI review - Traffic, Traffic Misdemeanor, Criminal Traffic, Other, or Unknown
						(ISNULL(degree,'') IN ('2','3','4','O','U','') ) 
						OR
						(
							(refDispositionTypeID = 3) --Requires Research
							--AND (CASE -- For ZIPCRIM 10 YEARS
							--		WHEN CLNO= @ZipCrim_10Years_CLNO 
							--			AND (
							--					((ISNULL(Disp_Date,'') = '') AND (ISNULL(Date_Filed,'') = ''))
							--					OR ((ISNULL(Disp_Date,'') = '') AND (CONVERT (DATE, Date_Filed) <= @Past10Years ))
							--					OR ((CONVERT (DATE, Disp_Date)) <= @Past10Years AND (CONVERT (DATE, Date_Filed) <= @Past10Years )) 
							--				)									
							--		THEN 1 --Reportable within 10 years

							--		-- For ZIPCRIM 7 YEARS and ZIPCRIM 99 YEARS
							--		WHEN CLNO in (@ZipCrim_7Years_CLNO,@Zipcrim_eRailSafe_ERSB_CLNO,@Zipcrim_eRailSafe_ERSB_Priority_CLNO) 
							--			AND (
							--					((ISNULL(Disp_Date,'') = '') AND (ISNULL(Date_Filed,'') = ''))
							--					OR ((ISNULL(Disp_Date,'') = '') AND (CONVERT (DATE, Date_Filed) <= @Past7Years ))
							--					OR ((CONVERT (DATE, Disp_Date)) <= @Past7Years AND (CONVERT (DATE, Date_Filed) <= @Past7Years )) 
							--				)									
							--				THEN 1  --Reportable within 7 years

							--		-- everything else is not reportable
							--		ELSE 0  
							--	END = 1)
						)
					)
				)
			) 
			OR
			(
				(Degree = 'O'OR degree= 'U' OR ISNULL(degree,'') = '' 
				OR Degree IN (SELECT m.MisdemeanorValues FROM #ReportableMisdemeanor m))
				AND (
						((ISNULL(Disp_Date,'') = '') AND (ISNULL(Date_Filed,'') = ''))
						OR ((ISNULL(Disp_Date,'') = '') AND (CONVERT (DATE, Date_Filed) <= @Past7Years ))
						OR ((CONVERT (DATE, Disp_Date)) <= @Past7Years AND (CONVERT (DATE, Date_Filed) <= @Past7Years )) 
					)
			)
		)

	INSERT INTO #TblCrimExceptions
	SELECT [CrimID],ExceptionNotes = CAST( CURRENT_TIMESTAMP as varchar) + ': Researcher returned result as Clear. Moved to Review reportability for reinvestigation of disclosure; '
	FROM #TblCrim 
	WHERE [Clear] = 'T' 


	--SELECT 'UPDATE crim SET [Clear] = D' AS TableName, * FROM dbo.Crim c
	--WHERE Crimid IN (SELECT Crimid FROM #tempCrimException)
	--	AND IsHidden = 0

	UPDATE C 
		SET [Clear] = 'D', 
			Priv_Notes = ExceptionNotes  + ISNULL(Priv_Notes,''),
			C.RefCrimStageID = 4 -- VD:12/22/2020 - Set the status to Review reportability Completed
	fROM DBO.CRIM C INNER JOIN #TblCrimExceptions T ON C.CRIMID = T.CRIMID
	WHERE IsHidden = 0

	-- Reopen reports that were Qualified for Review Reportability(RR) and Mark them to Pending
	-- so that they are avaiable in the RR Queue
	--SELECT DISTINCT A.*
	UPDATE A SET A.APSTATUS = 'P' 
	FROM APPL AS A 
	INNER JOIN CRIM AS C ON A.APNO = C.APNO AND C.IsHidden = 0
	WHERE C.[Clear] = 'D'
	  AND A.ApStatus = 'F'
	  AND A.APNO > 5165722

	INSERT INTO [dbo].[Crim_ReviewReportabilityStatusLog]
				([CrimID]
				,[APNO]
				,[County]
				,[OldStatus],[NewStatus]
				,[Degree]
				)
				(
		SELECT	C.[CrimID]
				,[APNO]
				,[County]
				,[Clear],'D'
				,[Degree]
		FROM DBO.CRIM C INNER JOIN #TblCrimExceptions T ON C.CRIMID = T.CRIMID
		WHERE [Clear] = 'D')
				

	--Drop Table #TblReview_InitialList
	Drop Table #tempCrimReportable
	Drop Table #tempCrimUnReportable
	Drop Table #tempMasterTounused
	Drop Table #tempTounused
	drop table #TempNoInsertRecord
	Drop Table #tempDistinctCrimUnReportable

END

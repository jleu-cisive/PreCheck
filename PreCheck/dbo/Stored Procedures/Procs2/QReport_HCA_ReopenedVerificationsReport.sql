/* =============================================
 Author		: Shashank Bhoi    
 Requester	: Laura Lohnes    
 Create date: 09/04/2023    
 Description: HCA: Reopened Verifications Report     
 Execution	: EXEC [dbo].[QReport_HCA_ReopenedVerificationsReport] '2023-01-01','2023-06-09','16135:13309','0'
-- ============================================= */
CREATE PROCEDURE dbo.QReport_HCA_ReopenedVerificationsReport 
	@StartDate DateTime,    
	@EndDate DateTime,    
	@CLNO varchar(MAX) = NULL,    
	@AffiliateIDs varchar(MAX) = '0' 
AS
BEGIN
SET NOCOUNT ON;

--DECLARE @StartDate Date = '2023-01-01',
--		@EndDate Date = '2023-06-09',
--		@clno int = 0,
--		@AffiliateIDs varchar(MAX) = '0'--Code added by vairavan for ticket id -67226 

SELECT @EndDate = DATEADD(day, 1, @EndDate)

IF(@clno = '' OR LOWER(@clno) = 'null' OR @clno = '0')
	SET @clno = NULL;  

IF(@AffiliateIDs = '' OR LOWER(@AffiliateIDs) = 'null' OR @AffiliateIDs = '0')
	SET @AffiliateIDs = NULL;  

DROP TABLE IF EXISTS #SectStat;
SELECT Code,Description 
INTO #SectStat 
FROM dbo.SectStat with (NOLOCK) 
WHERE Description NOT IN ( 'PENDING','OnHold-AIReview','ComplianceReinvestigation','NEEDS REVIEW');

DROP TABLE IF EXISTS #SectSubStatus;
SELECT CAST(SectSubStatusID AS CHAR(2)) AS SectSubStatusID,SectSubStatus 
INTO #SectSubStatus 
FROM dbo.SectSubStatus WITH (NOLOCK)

DROP TABLE IF EXISTS #ApplDetails;
SELECT	C.CLNO,
		A.Apno,
		A.First AS CandidateFirstName,
		A.Last AS CandidateLastName,
		C.AffiliateID
INTO	#ApplDetails
FROM	dbo.Appl		AS A WITH (NOLOCK)	
		JOIN dbo.Client AS C WITH (NOLOCK)	ON A.CLNO = C.CLNO
WHERE	(@CLNO IS NULL OR EXISTS (SELECT value FROM fn_Split(@CLNO,':') WHERE value = c.CLNO )) 
		AND (@AffiliateIDs IS NULL OR EXISTS (SELECT value FROM fn_Split(@AffiliateIDs,':') WHERE value = c.AffiliateID ))
		AND A.OrigCompDate >= @StartDate 
		AND A.OrigCompDate <= @EndDate	

CREATE NONCLUSTERED INDEX [IX_ApplDetails_Apno] ON dbo.#ApplDetails
(
	APNO ASC
)
INCLUDE(CLNO,CandidateFirstName,CandidateLastName,AffiliateID) ON [PRIMARY]
;

DROP TABLE IF EXISTS #Educat
;WITH cteA AS (
	SELECT A.*,e.School,CL.HEVNMgmtChangeLogID,CL.ID,CL.TableName,CL.OldValue,CL.NewValue,CL.ChangeDate,LAG(CL.ChangeDate) OVER(PARTITION BY CL.ID,CL.TableName ORDER BY CL.HEVNMgmtChangeLogID) as [Date of Previous Status] , 
	COUNT(*) OVER(PARTITION BY ID ORDER BY ID ) AS R
	FROM	dbo.ChangeLog			AS CL WITH (NOLOCK)
			JOIN dbo.Educat			AS E WITH (NOLOCK) ON CL.ID = E.EducatID
			JOIN dbo.#ApplDetails   AS A WITH (NOLOCK)	ON E.APNO = A.APNO
	WHERE	CL.TableName IN ('Educat.SectStat','Educat.SectSubStatus')	
)
SELECT *,Row_number() OVER(PARTITION BY Apno, ID,CL.TableName ORDER BY ChangeDate DESC) AS LatestRecord 
INTO #Educat 
FROM cteA AS CL WHERE R > 1
AND (
			(
			EXISTS ( SELECT 1 FROM #SectStat AS SS1 WITH (NOLOCK) WHERE SS1.Code = CL.OldValue AND CL.TableName = 'Educat.SectStat')
			AND EXISTS ( SELECT 1 FROM #SectStat AS SS2 WITH (NOLOCK) WHERE SS2.Code = CL.NewValue AND CL.TableName = 'Educat.SectStat')
			)
			OR 
			(
			EXISTS (
			SELECT 1 FROM #SectSubStatus AS SSS1 WITH (NOLOCK) WHERE SectSubStatusID = CL.OldValue AND CL.TableName = 'Educat.SectSubStatus')
			AND EXISTS (SELECT 1 FROM #SectSubStatus AS SSS2 WITH (NOLOCK) WHERE SectSubStatusID = CL.NewValue AND CL.TableName = 'Educat.SectSubStatus')
			)
	)

SELECT	
		E1.CLNO,
		REPLACE(REPLACE(rf.Affiliate, CHAR(13), ''), CHAR(10), '') AS Affiliate,
		E1.APNO,
		E1.ID AS [Lead ID #],
		E1.CandidateFirstName,
		E1.CandidateLastName,
		'Educat' AS Section,
		REPLACE(REPLACE(E1.School, CHAR(13), ''), CHAR(10), '') AS [Specific Lead],
		SS1.Description AS [Previous Closed Status],
		SSS1.SectSubStatus AS [Previous Closed Sub Status],
		--E1.[Date of Previous Status] , 
		try_convert(varchar, E1.[Date of Previous Status], 22) AS [Date of Previous Status],
		--E2.[Date of Previous Status] AS [Date of Previous Sub Status], 
		try_convert(varchar, E2.[Date of Previous Status], 22) AS [Date of Previous Sub Status], 
		SS2.Description AS [Updated Closed Status],
		SSS2.SectSubStatus AS [Updated Closed Sub Status],
		--E1.ChangeDate AS [Date of Updated Status],
		try_convert(varchar, E1.ChangeDate, 22) AS [Date of Updated Status],
		--E2.ChangeDate AS [Date of Updated Sub Status],
		try_convert(varchar, E2.ChangeDate, 22) AS  [Date of Updated Sub Status],
		DateDiff(day,E1.[Date of Previous Status],E1.ChangeDate) AS [Business Days Between Statuses],
		DateDiff(day,E2.[Date of Previous Status],E2.ChangeDate) AS [Business Days Between Sub Statuses]
FROM	#Educat					AS E1 
		JOIN #Educat			AS E2 ON E1.ID = E2.ID
								AND E1.AffiliateID = E2.AffiliateID 
								AND E1.CLNO = E2.CLNO AND E1.APNO = E2.APNO AND E1.AffiliateID = E2.AffiliateID
		JOIN dbo.refAffiliate	AS rf WITH(NOLOCK) ON E1.AffiliateID = rf.AffiliateID
		LEFT JOIN #SectStat		AS SS1 WITH (NOLOCK) ON SS1.Code = E1.OldValue AND E1.TableName = 'Educat.SectStat'
		LEFT JOIN #SectStat		AS SS2 WITH (NOLOCK) ON SS2.Code = E1.NewValue AND E1.TableName = 'Educat.SectStat'
		LEFT JOIN #SectSubStatus AS SSS1 WITH (NOLOCK) ON SSS1.SectSubStatusID = E2.OldValue AND E2.TableName = 'Educat.SectSubStatus'
		LEFT JOIN #SectSubStatus AS SSS2 WITH (NOLOCK) ON SSS2.SectSubStatusID = E2.NewValue AND E2.TableName = 'Educat.SectSubStatus'
WHERE	E1.TableName = 'Educat.SectStat'
		AND E2.TableName = 'Educat.SectSubStatus'
		AND E1.LatestRecord =1 AND E2.LatestRecord =1

END


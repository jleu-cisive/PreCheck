
/*
Created By	:	Larry Ouch
Created Date:	02/07//2017
Description	:	AS part of AliAS Logic Re-Write project all the AliASes will be from dbo.ApplAliAS (Overflow table).
Execution	:	EXEC [dbo].[Crim_GetAliasesToSend] 23404470
*/

CREATE PROCEDURE [dbo].[Crim_GetAliasesToSend]
    @CrimID int 
AS   
SET NOCOUNT ON

	
SELECT AA.APNO, AA.ApplAliasID, X.SectionKeyID, X.IsActive
         INTO #tmpRecordsNotToBeSent 
FROM dbo.ApplAlias AS AA(NOLOCK) 
LEFT OUTER JOIN dbo.ApplAlias_Sections AS X(NOLOCK) ON AA.ApplAliasID = X.ApplAliasID 
WHERE X.SectionKeyID = @CrimID
  --AND IsPublicRecordQualified = 1

--SELECT * FROM #tmpRecordsNotToBeSent


IF((SELECT COUNT(*) FROM #tmpRecordsNotToBeSent ) > 0)
BEGIN
	SELECT DISTINCT ApplAliasID, APNO, First, Middle, Last, IsMaiden, Generation, IsPublicRecordQualified, IsPrimaryName, ApplAlias_IsActive, AddedBy
	FROM 
	(
	SELECT  ApplAliasID, APNO, First, Middle, Last, IsMaiden, Generation, IsPublicRecordQualified, IsPrimaryName, A.IsActive AS ApplAlias_IsActive, AddedBy
	FROM ApplAlias AS A(NOLOCK)
	WHERE APNO IN (SELECT APNO FROM #tmpRecordsNotToBeSent) 
	  --AND IsPublicRecordQualified = 1	  
	  AND IsPrimaryName = 1
	  AND ApplAliasID NOT IN (SELECT ApplAliasID FROM #tmpRecordsNotToBeSent WHERE IsActive = 0)
	UNION ALL
	SELECT ApplAliasID, APNO, First, Middle, Last, IsMaiden, Generation, IsPublicRecordQualified, IsPrimaryName, A.IsActive AS ApplAlias_IsActive, AddedBy
	FROM ApplAlias AS A (NOLOCK)
	WHERE APNO IN (SELECT APNO FROM #tmpRecordsNotToBeSent) 
	  AND ApplAliasID IN (SELECT ApplAliasID FROM #tmpRecordsNotToBeSent WHERE IsActive = 1)
	) AS X
	ORDER BY APNO, IsPrimaryName DESC, IsPublicRecordQualified DESC
END
ELSE
BEGIN
	SELECT ApplAliasID, APNO, First, Middle, Last, IsMaiden, Generation, IsPublicRecordQualified, IsPrimaryName, A.IsActive AS ApplAlias_IsActive, AddedBy 
	FROM ApplAlias AS A(NOLOCK)
	WHERE APNO IN (SELECT APNO FROM Crim(NOLOCK) WHERE CrimID = @CrimID) 
	  --AND IsPublicRecordQualified = 1
	  AND IsPrimaryName = 1
	ORDER BY APNO, IsPrimaryName DESC, IsPublicRecordQualified DESC
END


DROP TABLE #tmpRecordsNotToBeSent
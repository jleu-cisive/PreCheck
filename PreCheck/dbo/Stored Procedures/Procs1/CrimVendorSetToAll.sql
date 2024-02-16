-- ======================================================================================================
-- Author:		Larry Ouch/ Deepak Vodethela
-- Create date: August 3, 2017
-- Description:	Stored procedure for Q-Report '[Crim Vendor Set To All]'
-- Parameters: @StartDate, @EndDate
-- ======================================================================================================
CREATE PROCEDURE [dbo].[CrimVendorSetToAll]
@startDate DATETIME,
@endDate DATETIME

AS

       SELECT DISTINCT A.Apno, IR.R_Name AS 'VendorName', C.County, C.CrimID,
                 (SELECT COUNT(*) FROM ApplAlias (NOLOCK) WHERE APNO = A.APNO AND IsPublicRecordQualified = 1 AND IsActive = 1) AS [QualifiedNames],
                 (SELECT COUNT(*) FROM ApplAlias_Sections (NOLOCK) WHERE SectionKeyID = C.CrimID AND IsActive = 1) AS [SentNames],
                 ((SELECT COUNT(*) FROM ApplAlias (NOLOCK) WHERE APNO = A.APNO AND IsPublicRecordQualified = 1 AND IsActive = 1) -
                 (SELECT COUNT(*) FROM ApplAlias_Sections (NOLOCK) WHERE SectionKeyID = C.CrimID AND IsActive = 1)) AS [NamesNotSent]
       INTO #TempVendorAllSent
       FROM Appl A (NOLOCK)
       INNER JOIN Crim C (NOLOCK) ON C.Apno = A.Apno
       INNER JOIN Iris_Researcher_Charges IRC (NOLOCK) ON IRC.Researcher_id = C.vendorid AND IRC.cnty_no = C.CNTY_NO
       INNER JOIN Iris_Researchers IR (NOLOCK) ON IR.r_id = IRC.researcher_id
       WHERE IRC.Researcher_Aliases_count = 'All'
	   AND (a.[ApDate] BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(D,1,@EndDate)))


       --SELECT '#TempVendorAllSent' AS TableName, * FROM #TempVendorAllSent ORDER BY vendorname

       SELECT AA.APNO, AA.ApplAliasID, X.SectionKeyID AS CrimID, ISNULL(Last,'') +' '+ ISNULL(First,'') +' '+ ISNULL(Middle,'') +' '+ ISNULL(Generation,'') AS QualifiedNames
                     INTO #tmpAliasesNotSent
       FROM dbo.ApplAlias AS AA(NOLOCK) 
       LEFT OUTER JOIN dbo.ApplAlias_Sections AS X(NOLOCK) ON AA.ApplAliasID = X.ApplAliasID AND X.IsActive = 0
       WHERE X.SectionKeyID IN (SELECT CrimID FROM #TempVendorAllSent )
         AND IsPublicRecordQualified = 1 
         AND AA.IsActive = 1

       --SELECT '#tmpAliasesNotSent' AS TableName, * FROM #tmpAliasesNotSent

       SELECT  CrimID, APNO,
                     NamesNotSentToVendor = STUFF((SELECT '/ ' + QualifiedNames
                                                                     FROM #tmpAliasesNotSent b 
                                                                     WHERE b.CrimID = a.CrimID 
                                                                     FOR XML PATH('')), 1, 2, '') 
              INTO #tmpSelectedAliases
       FROM #tmpAliasesNotSent A
       GROUP BY CrimID,APNO--, Last, First, Middle, Generation, AliasCount
       ORDER BY APNO

       --SELECT '#tmpSelectedAliases' AS TableName, * FROM #tmpSelectedAliases

       SELECT T.APNO, VendorName, County, QualifiedNames, SentNames, NamesNotSent, NamesNotSentToVendor
       FROM #TempVendorAllSent AS T
       LEFT OUTER JOIN #tmpSelectedAliases AS A ON T.CrimID = A.CrimID
	   ORDER BY VendorName ASC, County ASC


DROP TABLE #TempVendorAllSent
DROP TABLE #tmpAliasesNotSent
DROP TABLE #tmpSelectedAliases


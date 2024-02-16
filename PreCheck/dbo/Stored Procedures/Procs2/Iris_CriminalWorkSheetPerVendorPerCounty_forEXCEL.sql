
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
--- Modified by Lalit on 31 oct 2022 for #59433
-- =============================================
CREATE PROCEDURE [dbo].[Iris_CriminalWorkSheetPerVendorPerCounty_forEXCEL] 
	@VendorID int,
@County int

 AS

SELECT
	C.CrimID
   ,C.APNO
   ,C.County
   ,C.Ordered
   ,CASE
		WHEN ISNULL(AA.AliasName, '') = '' THEN ISNULL(A.Last, '') + ', ' + ISNULL(A.First, '') + ' ' + ISNULL(A.Middle, '')
		ELSE AA.AliasName
	END AS FullName
   ,A.DOB AS DOB
   ,A.SSN AS SSN
   ,CONCAT('Client ID ', cl.CLNO, ', Affiliate ID ', ISNULL(cl.AffiliateID, '0'), ',', ISNULL(C.CRIM_SpecialInstr, '')) AS KnownHits
FROM Crim C WITH (NOLOCK)
INNER JOIN Appl A WITH (NOLOCK)
	ON A.APNO = C.APNO
INNER JOIN Client cl WITH (NOLOCK)
	ON A.CLNO = cl.CLNO
LEFT JOIN (SELECT
		t.SectionKeyID
	   ,STUFF((SELECT DISTINCT
				' / ' + ISNULL(A.Last, '') + ', ' + ISNULL(A.First, '') + ' ' + ISNULL(A.Middle, '')
			FROM ApplAlias AS A
			INNER JOIN dbo.ApplAlias_Sections AS S
				ON A.ApplAliasID = S.ApplAliasID
			WHERE S.SectionKeyID = t.SectionKeyID
			AND S.IsActive = 1
			AND S.ApplSectionID = 5
			FOR XML PATH (''), TYPE)
		.value('.', 'VARCHAR(MAX)'), 1, 2, '') AS AliasName
	FROM ApplAlias_Sections t
	GROUP BY t.SectionKeyID) AA
	ON AA.SectionKeyID = C.CrimID
WHERE (C.vendorid = @VendorID)
AND (C.CNTY_NO = @County)
AND (C.Clear IN ('O', 'W'))
AND C.IsHidden = 0
ORDER BY Ordered, FullName
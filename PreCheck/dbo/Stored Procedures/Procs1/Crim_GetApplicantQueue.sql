/*
-- Edited By :	Deepak Vodethela	
-- Edited Date:	03/27/2017
-- Description:	As part of Alias Logic Re-Write project all the Aliases will be from dbo.ApplAlias (Overflow table).
-- Execution: EXEC [dbo].[Crim_GetApplicantQueue]

-- Updated By Doug DeGenaro
-- Description : We are not using COUNTY NO 1 anymore, we merged 1 and 2682 together and now for DPS are using 2682
-- We are using ApplAlias table now for aliases, so Appl table is no longer needed for Aliases

-- Updated by Humera Ahmed on 2/10/2022
-- Descriptioon : To resolve the SQL time out exception error, we're releasing 250 crims at a time.
*/
-- EXEC [Crim_GetApplicantQueue]
CREATE PROCEDURE [dbo].[Crim_GetApplicantQueue]
AS
SET NOCOUNT ON

SELECT DISTINCT TOP 250  C.CrimID, C.APNO, C.[Clear],
          aa.[Last], aa.Middle, aa.[First], A.DOB
FROM dbo.Crim C WITH (NOLOCK)
INNER JOIN dbo.Appl a ON A.APNO = C.APNO
INNER JOIN dbo.ApplAlias aa WITH (NOLOCK) ON C.APNO = aa.APNO AND AA.IsPublicRecordQualified = 1 AND AA.IsActive = 1
WHERE (C.CNTY_NO = 2682 OR C.vendorid = 262) AND C.[Clear] = 'R'
--and c.APNO = 4518391

SET NOCOUNT OFF

--select * from dbo.ApplAlias_Sections where SectionKeyID=26705353
--select * from dbo.ApplAlias where apno = 4518391
--update dbo.Allias

--update dbo.ApplAlias set IsPublicRecordQualified = 1 where Apno = 4903650
--update dbo.Crim set Clear='R' where CrimID = 26707463


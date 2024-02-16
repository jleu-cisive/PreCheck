-- Alter Procedure FormInvestigatorVerified

/***
Got from prod on 02/09/2018 by dhe
****/
--[dbo].[FormInvestigatorVerified] 2251465 --4159597
CREATE PROCEDURE [dbo].[FormInvestigatorVerified] --3423545
(@apno int)
AS
SET NOCOUNT ON

SELECT 	'Empl' AS TableName
	, SectStat
	, ISNULL(IsCAMReview, 0) AS IsCAMReview
	, ISNULL(IsHidden, 0) AS IsHidden
	, EmplID AS [ID]
	, CASE	WHEN SectStat BETWEEN '2' AND '5' THEN From_V ELSE From_A END AS FromDate
	, CASE	WHEN SectStat BETWEEN '2' AND '5' THEN To_V   ELSE To_A   END AS ToDate
	, CASE	WHEN CHARINDEX('present', LOWER(CASE WHEN SectStat BETWEEN '2' AND '5' THEN To_V ELSE To_A END)) <> 0 THEN ApDate
		ELSE ISNULL(dbo.GetDateTime(CASE WHEN SectStat BETWEEN '2' AND '5' THEN To_V ELSE To_A END), ApDate + 1)
	  END As ToDateTime
	, CASE	WHEN SectStat BETWEEN '2' AND '5' THEN Position_V ELSE Position_A END AS UserDef1
	, Employer AS [Name]
	, CompDate
	, dbo.Empl.City
	, dbo.Empl.State
	, dbo.Empl.ZipCode
	, @APNO as APNO
	, empl.createdDate --new
    --, empl.Last_worked as 'Last_Updated' --new
	,empl.Last_Updated
	, '' AS Priv_Notes
	,CASE WHEN SectStat NOT IN ('2','3','4','5') THEN ISNULL(eta.ETADate, '') ELSE '' END AS ETADate 
FROM 	dbo.Empl WITH (NOLOCK) INNER JOIN dbo.Appl WITH (NOLOCK) ON dbo.Empl.APNO = dbo.Appl.APNO
        JOIN dbo.ApplSections ON dbo.ApplSections.Section = 'Empl'
        LEFT JOIN dbo.ApplSectionsETA(NOLOCK) eta ON dbo.Empl.APNO = eta.Apno AND dbo.Empl.EmplID = eta.SectionKeyID 
WHERE 	ISNULL(dbo.Empl.IsOnReport, 1) = 1 AND dbo.Appl.APNO = @apno --AND eta.ApplSectionID = 1--IN (SELECT APNO FROM dbo.Appl WHERE SSN = (SELECT TOP 1 SSN FROM dbo.Appl WHERE APNO = --@apno) AND APNO <> @apno)
  --AND dbo.Empl.SectStat NOT IN ('2','3','4','5')

UNION

SELECT 	'Educat' AS TableName
	, SectStat
	, ISNULL(IsCAMReview, 0)
	, ISNULL(IsHidden, 0)
	, EducatID AS [ID]
	, CASE	WHEN SectStat BETWEEN '2' AND '5' THEN From_V ELSE From_A END AS FromDate
	, CASE	WHEN SectStat BETWEEN '2' AND '5' THEN To_V   ELSE To_A   END AS ToDate
	, CASE	WHEN CHARINDEX('present', LOWER(CASE WHEN SectStat BETWEEN '2' AND '5' THEN To_V ELSE To_A END)) <> 0 THEN ApDate
		ELSE ISNULL(dbo.GetDateTime(CASE WHEN SectStat BETWEEN '2' AND '5' THEN To_V ELSE To_A END), ApDate + 1)
	  END As ToDateTime
	, CASE	WHEN SectStat BETWEEN '2' AND '5' THEN Degree_V + ' - ' + Studies_V ELSE Degree_A + ' - ' + Studies_A END
	, School + CASE WHEN LEN(ISNULL(CampusName, '')) > 0 THEN ' - ' + CampusName ELSE '' END AS [Name]
	, CompDate
	, dbo.Educat.City
	, dbo.Educat.State
	, dbo.Educat.ZipCode
	, @APNO as APNO
   ,Educat.CreatedDate--new
  , CASE   WHEN isnull(Educat.last_updated,'1/1/1900') > isnull(Educat.last_worked,'1/1/1900') AND isnull(Educat.last_updated,'1/1/1900') > isnull(Educat.Web_Updated,'1/1/1900') THEN Educat.last_updated   
		   WHEN isnull(Educat.last_worked,'1/1/1900') > isnull(Educat.last_updated,'1/1/1900') AND isnull(Educat.last_worked,'1/1/1900') > isnull(Educat.Web_Updated,'1/1/1900') THEN Educat.last_updated 
		   WHEN isnull(Educat.Web_Updated,'1/1/1900') > isnull(Educat.last_worked,'1/1/1900') AND isnull(Educat.Web_Updated,'1/1/1900') > isnull(Educat.last_updated,'1/1/1900') THEN Educat.Web_Updated
		   ELSE Educat.Last_Updated
		   END   as 'Last_Updated'   
	, '' AS Priv_Notes 
	,CASE WHEN SectStat NOT IN ('2','3','4','5') THEN ISNULL(eta.ETADate, '') ELSE '' END AS ETADate
FROM 	dbo.Educat WITH (NOLOCK) INNER JOIN dbo.Appl WITH (NOLOCK) ON dbo.Educat.APNO = dbo.Appl.APNO
        JOIN dbo.ApplSections ON dbo.ApplSections.Section = 'Educat'
        LEFT JOIN dbo.ApplSectionsETA(NOLOCK) eta ON dbo.Educat.APNO = eta.Apno AND dbo.Educat.EducatID = eta.SectionKeyID 
WHERE 	ISNULL(dbo.Educat.IsOnReport, 1) = 1 AND dbo.Appl.APNO = @apno --AND eta.ApplSectionID = 2--IN (SELECT APNO FROM dbo.Appl WHERE SSN = (SELECT TOP 1 SSN FROM dbo.Appl WHERE APNO --= @apno) AND APNO <> @apno)
  --AND dbo.Educat.SectStat NOT IN ('2','3','4','5')


UNION

SELECT 	'ProfLic' AS TableName
	, SectStat
	, ISNULL(IsCAMReview, 0)
	, ISNULL(IsHidden, 0)
	, ProfLicID AS [ID]
	, [Year] 	--FromDate
	, CONVERT(varchar, Expire, 101) --ToDate
	, '1/1/1900' AS ToDateTime
	, ISNULL(Status, '') + ' - ' + ISNULL(dbo.ProfLic.State, '')
	, Lic_Type AS [Name]
	, CompDate
	, NULL
	, dbo.ProfLic.State
	, NULL
	, @APNO as APNO
    ,ProfLic.createdDate --new
    , ProfLic.Last_updated as 'Last_Updated' --new
	, '' AS Priv_Notes 
	,CASE WHEN SectStat NOT IN ('2','3','4','5') THEN ISNULL(eta.ETADate, '') ELSE '' END AS ETADate 
FROM 	dbo.ProfLic WITH (NOLOCK) INNER JOIN dbo.Appl WITH (NOLOCK) ON dbo.ProfLic.APNO = dbo.Appl.APNO
JOIN dbo.ApplSections ON dbo.ApplSections.Section = 'ProfLic'
LEFT JOIN dbo.ApplSectionsETA(NOLOCK) eta ON dbo.ProfLic.APNO = eta.Apno AND dbo.ProfLic.ProfLicID = eta.SectionKeyID 
WHERE 	ISNULL(dbo.ProfLic.IsOnReport, 1) = 1 AND dbo.Appl.APNO = @apno --AND eta.ApplSectionID = 4--IN (SELECT APNO FROM dbo.Appl WHERE SSN = (SELECT TOP 1 SSN FROM dbo.Appl WHERE --APNO = @apno) AND APNO <> @apno)
  --AND dbo.ProfLic.SectStat NOT IN ('2','3','4','5')

UNION

SELECT 	'PersRef' AS TableName
	, SectStat
	, ISNULL(IsCAMReview, 0)
	, ISNULL(IsHidden, 0)
	, PersRefID AS [ID]
	, NULL	--FromDate
	, NULL	--ToDate
	, '1/1/1900' AS ToDateTime
	, Rel_V	--UserDef1
	, [Name]
	, CompDate
	, NULL
	, NULL
	, NULL
	, @APNO as APNO
    ,PersRef.createdDate --new
    , PersRef.Last_updated as 'Last_Updated' --new
	, '' AS Priv_Notes 
	, '' AS ETADate 
FROM 	dbo.PersRef WITH (NOLOCK) INNER JOIN dbo.Appl WITH (NOLOCK) ON dbo.PersRef.APNO = dbo.Appl.APNO
        --LEFT JOIN dbo.ApplSectionsETA(NOLOCK) eta ON dbo.PersRef.APNO = eta.Apno AND dbo.PersRef.PersRefID = eta.SectionKeyID 
WHERE	ISNULL(dbo.PersRef.IsOnReport, 1) = 1 AND dbo.Appl.APNO = @apno --AND eta.ApplSectionID = 3--IN (SELECT APNO FROM dbo.Appl WHERE SSN = (SELECT TOP 1 SSN FROM dbo.Appl WHERE --APNO = @apno) AND APNO <> @apno)


UNION

SELECT	'Crim' AS TableName
	, '0'
	, ISNULL(IsCAMReview, 0)
	, ISNULL(IsHidden, 0)
	, CrimID AS [ID]
	, [Clear]			--FromDate  In code used as Clear and not fromdate
	, CAST(CNTY_NO as varchar)	--ToDate In code used as county number and not Todate
	, '1/1/1900' AS ToDateTime
	, ISNULL(Degree, '0') --UserDef1
	, Case when  (select isStatewide from dbo.TblCounties C (NOLOCK) where c.cnty_no = dbo.Crim.cnty_no and A_County not like '%statewide%') = 1 then County + '"STATEWIDE"'
        else County 
       End 
	, CASE	WHEN Clear IN ('R', 'M', '') THEN NULL
		ELSE CompDate
	  END
	, NULL
	, NULL
	, NULL
	, @APNO as APNO
    --,Crim.createdDate --new
	,Crim.Crimenteredtime --new
    , Crim.Last_updated as 'Last_Updated' --new
	, '' AS Priv_Notes 
	,eta.ETADate
	--,CASE WHEN Clear NOT IN ('T','F', ) THEN ISNULL(eta.ETADate, '') ELSE '' END AS ETADate
FROM	dbo.Crim WITH (NOLOCK) INNER JOIN dbo.Appl WITH (NOLOCK) ON dbo.Crim.APNO = dbo.Appl.APNO
         JOIN dbo.ApplSections ON dbo.ApplSections.Section = 'Crim'
        LEFT JOIN dbo.ApplSectionsETA(NOLOCK) eta ON dbo.Crim.APNO = eta.Apno AND dbo.Crim.CrimID = eta.SectionKeyID 
WHERE	dbo.Appl.APNO = @apno --AND eta.ApplSectionID = 5
  --AND dbo.Crim.Clear NOT IN ('T','F','P')

UNION
SELECT 	'DL' AS TableName
	, SectStat
	, ISNULL(IsCAMReview, 0)
	, ISNULL(IsHidden, 0)
	, dbo.DL.APNO AS [ID]
	, NULL	--FromDate
	, NULL	--ToDate
	, null AS ToDateTime
	, null	--UserDef1
	, null
	, null
	, NULL
	, NULL
	, NULL
	, @APNO as APNO
    , null --new
    , null as 'Last_Updated' --new
	, '' AS Priv_Notes 
	, CASE WHEN SectStat NOT IN ('2','3','4','5') THEN ISNULL(eta.ETADate, '') ELSE '' END AS ETADate
FROM 	dbo.DL WITH (NOLOCK) LEFT OUTER JOIN
        ApplSectionsETA AS eta WITH (NOLOCK) ON eta.Apno = DL.APNO AND eta.ApplSectionID = 6
WHERE dbo.DL.APNO = @apno 




SET NOCOUNT OFF


SELECT 	'Empl' AS TableName
	, SectStat
	, ISNULL(IsCAMReview, 0) AS IsCAMReview
	, ISNULL(IsHidden, 0) AS IsHidden
	, EmplID AS [ID]
	, CASE	WHEN SectStat BETWEEN '2' AND '5' THEN From_V ELSE From_A END AS FromDate
	, CASE	WHEN SectStat BETWEEN '2' AND '5' THEN To_V   ELSE To_A   END AS ToDate
	, CASE	WHEN CHARINDEX('present', LOWER(CASE WHEN SectStat BETWEEN '2' AND '5' THEN To_V ELSE To_A END)) <> 0 THEN ApDate
		ELSE ISNULL(dbo.GetDateTime(CASE WHEN SectStat BETWEEN '2' AND '5' THEN To_V ELSE To_A END), ApDate + 1)
	  END As ToDateTime
	, CASE	WHEN SectStat BETWEEN '2' AND '5' THEN Position_V ELSE Position_A END AS UserDef1
	, Employer AS [Name]
	, CompDate
	, dbo.Empl.City
	, dbo.Empl.State
	, dbo.Empl.ZipCode
	, @APNO as APNO
	, empl.createdDate --new
    --, empl.Last_worked as 'Last_Updated' --new
	,empl.Last_Updated
	,CASE WHEN SectStat NOT IN ('2','3','4','5') THEN ISNULL(eta.ETADate, '') ELSE '' END AS ETADate 
FROM 	dbo.Empl WITH (NOLOCK) INNER JOIN dbo.Appl WITH (NOLOCK) ON dbo.Empl.APNO = dbo.Appl.APNO
JOIN dbo.ApplSections ON dbo.ApplSections.Section = 'Empl'
LEFT JOIN dbo.ApplSectionsETA(NOLOCK) eta ON dbo.Empl.APNO = eta.Apno AND dbo.Empl.EmplID = eta.SectionKeyID 
WHERE 	ISNULL(dbo.Empl.IsOnReport, 1) = 1 AND dbo.Appl.APNO = @apno --AND eta.ApplSectionID = 1 --IN (SELECT APNO FROM dbo.Appl WHERE SSN = (SELECT TOP 1 SSN FROM dbo.Appl WHERE APNO = --@apno) AND APNO <> @apno)
  --AND dbo.Empl.SectStat NOT IN ('2','3','4','5')

UNION

SELECT 	'Educat' AS TableName
	, SectStat
	, ISNULL(IsCAMReview, 0)
	, ISNULL(IsHidden, 0)
	, EducatID AS [ID]
	, CASE	WHEN SectStat BETWEEN '2' AND '5' THEN From_V ELSE From_A END AS FromDate
	, CASE	WHEN SectStat BETWEEN '2' AND '5' THEN To_V   ELSE To_A   END AS ToDate
	, CASE	WHEN CHARINDEX('present', LOWER(CASE WHEN SectStat BETWEEN '2' AND '5' THEN To_V ELSE To_A END)) <> 0 THEN ApDate
		ELSE ISNULL(dbo.GetDateTime(CASE WHEN SectStat BETWEEN '2' AND '5' THEN To_V ELSE To_A END), ApDate + 1)
	  END As ToDateTime
	, CASE	WHEN SectStat BETWEEN '2' AND '5' THEN Degree_V + ' - ' + Studies_V ELSE Degree_A + ' - ' + Studies_A END
	, School + CASE WHEN LEN(ISNULL(CampusName, '')) > 0 THEN ' - ' + CampusName ELSE '' END AS [Name]
	, CompDate
	, dbo.Educat.City
	, dbo.Educat.State
	, dbo.Educat.ZipCode
	, @APNO as APNO
   ,Educat.CreatedDate--new
  , CASE   WHEN isnull(Educat.last_updated,'1/1/1900') > isnull(Educat.last_worked,'1/1/1900') AND isnull(Educat.last_updated,'1/1/1900') > isnull(Educat.Web_Updated,'1/1/1900') THEN Educat.last_updated   
		   WHEN isnull(Educat.last_worked,'1/1/1900') > isnull(Educat.last_updated,'1/1/1900') AND isnull(Educat.last_worked,'1/1/1900') > isnull(Educat.Web_Updated,'1/1/1900') THEN Educat.last_updated 
		   WHEN isnull(Educat.Web_Updated,'1/1/1900') > isnull(Educat.last_worked,'1/1/1900') AND isnull(Educat.Web_Updated,'1/1/1900') > isnull(Educat.last_updated,'1/1/1900') THEN Educat.Web_Updated
		   ELSE Educat.Last_Updated
		   END   as 'Last_Updated'   
   ,CASE WHEN SectStat NOT IN ('2','3','4','5') THEN ISNULL(eta.ETADate, '') ELSE '' END AS ETADate 
FROM 	dbo.Educat WITH (NOLOCK) INNER JOIN dbo.Appl WITH (NOLOCK) ON dbo.Educat.APNO = dbo.Appl.APNO
JOIN dbo.ApplSections ON dbo.ApplSections.Section = 'Educat'
LEFT JOIN dbo.ApplSectionsETA(NOLOCK) eta ON dbo.Educat.APNO = eta.Apno AND dbo.Educat.EducatID = eta.SectionKeyID 
WHERE 	ISNULL(dbo.Educat.IsOnReport, 1) = 1 AND dbo.Appl.APNO = @apno --AND eta.ApplSectionID = 2 --IN (SELECT APNO FROM dbo.Appl WHERE SSN = (SELECT TOP 1 SSN FROM dbo.Appl WHERE APNO --= @apno) AND APNO <> @apno)
  --AND dbo.Educat.SectStat NOT IN ('2','3','4','5')

UNION

SELECT 	'ProfLic' AS TableName
	, SectStat
	, ISNULL(IsCAMReview, 0)
	, ISNULL(IsHidden, 0)
	, ProfLicID AS [ID]
	, [Year] 	--FromDate
	, CONVERT(varchar, Expire, 101) --ToDate
	, '1/1/1900' AS ToDateTime
	, ISNULL(Status, '') + ' - ' + ISNULL(dbo.ProfLic.State, '')
	, Lic_Type AS [Name]
	, CompDate
	, NULL
	, dbo.ProfLic.State
	, NULL
	, @APNO as APNO
    ,ProfLic.createdDate --new
    , ProfLic.Last_updated as 'Last_Updated' --new
	,CASE WHEN SectStat NOT IN ('2','3','4','5') THEN ISNULL(eta.ETADate, '') ELSE '' END AS ETADate  
FROM 	dbo.ProfLic WITH (NOLOCK) INNER JOIN dbo.Appl WITH (NOLOCK) ON dbo.ProfLic.APNO = dbo.Appl.APNO
JOIN dbo.ApplSections ON dbo.ApplSections.Section = 'ProfLic'
LEFT JOIN dbo.ApplSectionsETA(NOLOCK) eta ON dbo.ProfLic.APNO = eta.Apno AND dbo.ProfLic.ProfLicID = eta.SectionKeyID 
WHERE 	ISNULL(dbo.ProfLic.IsOnReport, 1) = 1 AND dbo.Appl.APNO = @apno --AND eta.ApplSectionID = 4 --IN (SELECT APNO FROM dbo.Appl WHERE SSN = (SELECT TOP 1 SSN FROM dbo.Appl WHERE --APNO = @apno) AND APNO <> @apno)
  --AND dbo.ProfLic.SectStat NOT IN ('2','3','4','5')


UNION

SELECT 	'PersRef' AS TableName
	, SectStat
	, ISNULL(IsCAMReview, 0)
	, ISNULL(IsHidden, 0)
	, PersRefID AS [ID]
	, NULL	--FromDate
	, NULL	--ToDate
	, '1/1/1900' AS ToDateTime
	, Rel_V	--UserDef1
	, [Name]
	, CompDate
	, NULL
	, NULL
	, NULL
	, @APNO as APNO
    ,PersRef.createdDate --new
    , PersRef.Last_updated as 'Last_Updated' --new
	,'' AS ETADate
FROM 	dbo.PersRef WITH (NOLOCK) INNER JOIN dbo.Appl WITH (NOLOCK) ON dbo.PersRef.APNO = dbo.Appl.APNO
--LEFT JOIN dbo.ApplSectionsETA(NOLOCK) eta ON dbo.PersRef.APNO = eta.Apno AND dbo.PersRef.PersRefID = eta.SectionKeyID 
WHERE	ISNULL(dbo.PersRef.IsOnReport, 1) = 1 AND dbo.Appl.APNO = @apno --AND eta.ApplSectionID = 3 --IN (SELECT APNO FROM dbo.Appl WHERE SSN = (SELECT TOP 1 SSN FROM dbo.Appl WHERE --APNO = @apno) AND APNO <> @apno)

UNION

SELECT	'Crim' AS TableName
	, '0'
	, ISNULL(IsCAMReview, 0)
	, ISNULL(IsHidden, 0)
	, CrimID AS [ID]
	, [Clear]			--FromDate  In code used as Clear and not fromdate
	, CAST(CNTY_NO as varchar)	--ToDate In code used as county number and not Todate
	, '1/1/1900' AS ToDateTime
	, ISNULL(Degree, '0') --UserDef1
	, Case when  (select isStatewide from dbo.TblCounties C (NOLOCK) where c.cnty_no = dbo.Crim.cnty_no and A_County not like '%statewide%') = 1 then County + '"STATEWIDE"'
        else County 
       End 
	, CASE	WHEN Clear IN ('R', 'M', '') THEN NULL
		ELSE CompDate
	  END
	, NULL
	, NULL
	, NULL
	, @APNO as APNO
    --,Crim.createdDate --new
	,Crim.Crimenteredtime --new
    , Crim.Last_updated as 'Last_Updated' --new
	,eta.ETADate
	--,CASE WHEN [Clear] NOT IN ('T','F') THEN ISNULL(eta.ETADate, '') ELSE '' END AS ETADate
FROM	dbo.Crim WITH (NOLOCK) INNER JOIN dbo.Appl WITH (NOLOCK) ON dbo.Crim.APNO = dbo.Appl.APNO
JOIN dbo.ApplSections ON dbo.ApplSections.Section = 'Crim'
LEFT JOIN dbo.ApplSectionsETA(NOLOCK) eta ON dbo.Crim.APNO = eta.Apno AND dbo.Crim.CrimID = eta.SectionKeyID 
WHERE	dbo.Appl.APNO = @apno --AND eta.ApplSectionID = 5
  --AND dbo.Crim.Clear NOT IN ('T','F','P')

  UNION
SELECT 	'DL' AS TableName
	, SectStat
	, ISNULL(IsCAMReview, 0)
	, ISNULL(IsHidden, 0)
	, dbo.DL.APNO AS [ID]
	, NULL	--FromDate
	, NULL	--ToDate
	, null AS ToDateTime
	, null	--UserDef1
	, null
	, null
	, NULL
	, NULL
	, NULL
	, @APNO as APNO
    , null --new
    , null as 'Last_Updated' --new
	--, '' AS Priv_Notes 
	, CASE WHEN SectStat NOT IN ('2','3','4','5') THEN ISNULL(eta.ETADate, '') ELSE '' END AS ETADate
FROM 	dbo.DL WITH (NOLOCK) LEFT OUTER JOIN
        ApplSectionsETA AS eta WITH (NOLOCK) ON eta.Apno = DL.APNO AND eta.ApplSectionID = 6
WHERE dbo.DL.APNO = @apno 



SET NOCOUNT OFF

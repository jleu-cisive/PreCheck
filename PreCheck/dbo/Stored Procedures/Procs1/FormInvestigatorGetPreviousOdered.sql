

CREATE PROCEDURE [dbo].[FormInvestigatorGetPreviousOdered]
(@apno int)
AS
SET NOCOUNT ON
DECLARE @SSN varchar(11)
set @SSN = (SELECT TOP 1 SSN FROM dbo.Appl with (nolock) WHERE APNO = @apno)
IF ISNULL(@SSN,'') <> ''
SELECT 	'Empl' AS TableName
	, SectStat
	, ISNULL(IsCAMReview, 0) AS IsCAMReview
	, EmplID AS [ID]
	, From_V AS FromDate
	, To_V AS ToDate
	, CASE	WHEN CHARINDEX('present', LOWER(To_V)) <> 0 THEN ApDate
		ELSE ISNULL(dbo.GetDateTime(To_V), A.ApDate + 1)
	  END As ToDateTime
	, Position_V AS UserDef1
	, Employer AS [Name]
	, A.CompDate 
	, Em.City
	, Em.State
	, Em.ZipCode
	, A.APNO
, '' AS Priv_Notes 
,ISNULL(eta.ETADate, '') AS ETADate
FROM 	dbo.Empl Em  with (nolock) INNER JOIN dbo.Appl A  with (nolock) ON Em.APNO = A.APNO 
  JOIN dbo.ApplSections ON dbo.ApplSections.Section = 'Empl'
        LEFT JOIN dbo.ApplSectionsETA(NOLOCK) eta ON Em.APNO = eta.Apno AND Em.EmplID = eta.SectionKeyID 
WHERE 	A.SSN = @SSN AND A.APNO <> @apno AND ISNULL(Em.IsHistoryRecord, 0) = 0 AND Em.SectStat <> '0'

UNION

SELECT 	'Educat' AS TableName
	, SectStat
	, ISNULL(IsCAMReview, 0)
	, EducatID AS [ID]
	, From_V
	, To_V
	, CASE	WHEN CHARINDEX('present', LOWER(To_V)) <> 0 THEN ApDate
		ELSE ISNULL(dbo.GetDateTime(To_V), A.ApDate + 1)
	  END
	, ISNULL(Degree_V, '') + ' - ' + ISNULL(Studies_V, '')
	, School + CASE WHEN LEN(ISNULL(CampusName, '')) > 0 THEN ' - ' + CampusName ELSE '' END AS [Name]
	, A.CompDate 
	, Ed.City
	, Ed.State
	, Ed.ZipCode
	, A.APNO
, '' AS Priv_Notes 
,ISNULL(eta.ETADate, '') AS ETADate
FROM 	dbo.Educat Ed  with (nolock) INNER JOIN dbo.Appl A  with (nolock) ON Ed.APNO = A.APNO 
JOIN dbo.ApplSections ON dbo.ApplSections.Section = 'Educat'
        LEFT JOIN dbo.ApplSectionsETA(NOLOCK) eta ON Ed.APNO = eta.Apno AND Ed.EducatID = eta.SectionKeyID 
WHERE 	A.SSN = @SSN AND A.APNO <> @apno AND ISNULL(Ed.IsHistoryRecord, 0) = 0 AND Ed.SectStat <> '0'

UNION

SELECT 	'ProfLic' AS TableName
	, SectStat
	, ISNULL(IsCAMReview, 0)
	, ProfLicID AS [ID]
	, [Year]	--FromDate
	, CONVERT(varchar, Expire, 101)	--ToDate
	, '1/1/1900' AS ToDateTime
	, ISNULL(Status, '') + ' - ' + ISNULL(PL.State, '')
	, Lic_Type AS [Name]
	, A.CompDate 
	, NULL
	, PL.State
	, NULL
	, A.APNO
, '' AS Priv_Notes 
,'' AS ETADate
FROM 	dbo.ProfLic PL  with (nolock) INNER JOIN dbo.Appl A  with (nolock) ON PL.APNO = A.APNO 
WHERE 	A.SSN = @SSN AND A.APNO <> @apno AND ISNULL(PL.IsHistoryRecord, 0) = 0 AND PL.SectStat <> '0'

UNION

SELECT 	'PersRef' AS TableName
	, SectStat
	, ISNULL(IsCAMReview, 0)
	, PersRefID AS [ID]
	, NULL	--From_V
	, NULL	--To_V
	, '1/1/1900' AS ToDateTime
	, Rel_V
	, [Name]
	, A.CompDate 
	, NULL
	, NULL
	, NULL
	, A.APNO
, '' AS Priv_Notes 
,'' AS ETADate
FROM 	dbo.PersRef PR  with (nolock) INNER JOIN dbo.Appl A  with (nolock) ON PR.APNO = A.APNO 
WHERE 	A.SSN = @SSN AND A.APNO <> @apno AND ISNULL(PR.IsHistoryRecord, 0) = 0 AND PR.SectStat <> '0'

UNION

SELECT 	'Crim' AS TableName
	, '0'
	, ISNULL(IsCAMReview, 0)
	, CrimID AS [ID]
	, [Clear]			--From_V
	, CAST(CNTY_NO as varchar)	--To_V
	, '1/1/1900' AS ToDateTime
	, ISNULL(Degree, '0')		--UserDef1
	, County AS [Name]
	, A.CompDate 
	, NULL
	, NULL
	, NULL
	, A.APNO
, '' AS Priv_Notes 
,ISNULL(eta.ETADate, '') AS ETADate
FROM 	dbo.Crim Cr  with (nolock) INNER JOIN dbo.Appl A  with (nolock) ON Cr.APNO = A.APNO 
 JOIN dbo.ApplSections ON dbo.ApplSections.Section = 'Crim'
        LEFT JOIN dbo.ApplSectionsETA(NOLOCK) eta ON Cr.APNO = eta.Apno AND Cr.CrimID = eta.SectionKeyID 
WHERE 	A.SSN = @SSN AND A.APNO <> @apno AND ISNULL(Cr.IsHistoryRecord, 0) = 0 AND Cr.[Clear] <> ''

SET NOCOUNT OFF




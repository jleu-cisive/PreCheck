

CREATE PROCEDURE [dbo].[FormInvestigatorGetApp]
(@apno int)
AS
SET NOCOUNT ON

SELECT 	'Empl' AS TableName
	, SectStat
	, ISNULL(IsCAMReview, 0) AS IsCAMReview
	, EmplID AS [ID]
	, From_A AS FromDate
	, To_A AS ToDate
	, CASE	WHEN CHARINDEX('present', LOWER(To_A)) <> 0 THEN getdate()
		ELSE ISNULL(dbo.GetDateTime(To_A), ISNULL(dbo.Appl.ApDate, getdate()) + 1)
	  END As ToDateTime
	, CASE	WHEN CHARINDEX('present', LOWER(To_A)) <> 0 THEN DATEDIFF(year, ISNULL(ApDate, getdate()), getdate())
		ELSE DATEDIFF(year, ISNULL(dbo.GetDateTime(To_A),getdate()), getdate())
	  END As NumOfYear
	, isnull(Position_A,'')  + CASE 	WHEN DNC = 1 THEN ' (Do not contact)'
				WHEN DNC = 0 THEN ' (OK to contact)'
				WHEN DNC IS NULL THEN ' (Unknown)'
	  END AS UserDef1
  	, Employer AS [Name]
	, CASE	WHEN dbo.Empl.City IS NULL AND LEN(dbo.Empl.Location) > 0 AND CHARINDEX(',', dbo.Empl.Location) > 0 THEN SUBSTRING(dbo.Empl.Location, 1, CHARINDEX(',', dbo.Empl.Location) - 1)
		ELSE ISNULL(dbo.Empl.City, '')
	  END As City
	, CASE	WHEN dbo.Empl.State IS NULL AND LEN(dbo.Empl.Location) > 0 THEN SUBSTRING(dbo.Empl.Location, CHARINDEX(',', dbo.Empl.Location) + 1, LEN(dbo.Empl.Location) - CHARINDEX(',', dbo.Empl.Location))
		ELSE dbo.Empl.State
	  END As State
	, dbo.Empl.ZipCode
	, ISNULL( dbo.Empl.Priv_Notes, '') AS Priv_Notes
	, @APNO AS APNO
	,ISNULL(eta.ETADate, '') AS ETADate 
FROM 	dbo.Empl WITH (NOLOCK) INNER JOIN dbo.Appl WITH (NOLOCK) ON dbo.Empl.APNO = dbo.Appl.APNO
JOIN dbo.ApplSections ON dbo.ApplSections.Section = 'Empl'
LEFT JOIN dbo.ApplSectionsETA(NOLOCK) eta ON dbo.Empl.APNO = eta.Apno AND dbo.Empl.EmplID = eta.SectionKeyID 
WHERE 	dbo.Empl.APNO = @apno AND ISNULL(dbo.Empl.IsHistoryRecord, 0) = 0 --AND eta.ApplSectionID = 1

UNION ALL

SELECT 	'Educat' AS TableName
	, SectStat
	, ISNULL(IsCAMReview, 0)
	, EducatID AS [ID]
	, From_A
	, To_A
	, CASE	WHEN CHARINDEX('present', LOWER(To_A)) <> 0 THEN ISNULL(ApDate,getdate())
		ELSE ISNULL(dbo.GetDateTime(To_A), ISNULL(dbo.Appl.ApDate, getdate()) + 1)
	  END As ToDateTime
	, CASE	WHEN CHARINDEX('present', LOWER(To_A)) <> 0 THEN DATEDIFF(year, ISNULL(ApDate,getdate()), getdate())
		ELSE DATEDIFF(year, ISNULL(dbo.GetDateTime(To_A),getdate()), getdate())
	  END As NumOfYear
	, ISNULL(Degree_A, '') + ' - ' + ISNULL(Studies_A, '')
   	, School + CASE WHEN LEN(ISNULL(CampusName, '')) > 0 THEN ' - ' + CampusName ELSE '' END AS [Name]
	, dbo.Educat.City
	, dbo.Educat.State
	, dbo.Educat.ZipCode
	, ISNULL(dbo.Educat.Priv_Notes, '') as  Priv_Notes
	, @APNO AS APNO
	,ISNULL(eta.ETADate, '') AS ETADate 
FROM 	dbo.Educat WITH (NOLOCK) INNER JOIN dbo.Appl WITH (NOLOCK) ON dbo.Educat.APNO = dbo.Appl.APNO
JOIN dbo.ApplSections ON dbo.ApplSections.Section = 'Educat'
LEFT JOIN dbo.ApplSectionsETA(NOLOCK) eta ON dbo.Educat.APNO = eta.Apno AND dbo.Educat.EducatID = eta.SectionKeyID 
WHERE 	dbo.Educat.APNO = @apno AND ISNULL(dbo.Educat.IsHistoryRecord, 0) = 0 --AND eta.ApplSectionID = 2

UNION ALL

SELECT 	'ProfLic' AS TableName
	, SectStat
	, ISNULL(IsCAMReview, 0)
	, ProfLicID AS [ID]
	, [Year]	--FromDate
	, CONVERT(varchar, Expire, 101) --ToDate
	, '1/1/1900' AS ToDateTime
	, 0
	, ISNULL(Status, '') + ' - ' + ISNULL(State, '')
  	, Lic_Type AS [Name]
	, NULL
	, dbo.ProfLic.State
	, NULL
	, ISNULL(dbo.ProfLic.Priv_Notes, '') as  Priv_Notes
	, @APNO AS APNO
	,'' AS ETADate
FROM 	dbo.ProfLic 
LEFT JOIN dbo.ApplSectionsETA(NOLOCK) eta ON dbo.ProfLic.APNO = eta.Apno AND dbo.ProfLic.ProfLicID = eta.SectionKeyID 
WHERE dbo.ProfLic.APNO = @apno AND ISNULL(dbo.ProfLic.IsHistoryRecord, 0) = 0 --AND eta.ApplSectionID = 4

UNION ALL

SELECT 	'PersRef' AS TableName
	, SectStat
	, ISNULL(IsCAMReview, 0)
	, PersRefID AS [ID]
	, NULL	--FromDate
	, NULL	--ToDate
	, '1/1/1900' AS ToDateTime
	, 0
	, Rel_V
   	, [Name]
	, NULL
	, NULL
	, NULL
	, ISNULL(dbo.PersRef.Priv_Notes, '') as  Priv_Notes
	, @APNO AS APNO
	,''AS ETADate
FROM 	dbo.PersRef 
--LEFT JOIN dbo.ApplSectionsETA(NOLOCK) eta ON dbo.PersRef.APNO = eta.Apno AND dbo.PersRef.PersRefID = eta.SectionKeyID 
WHERE dbo.PersRef.APNO = @apno AND ISNULL(dbo.PersRef.IsHistoryRecord, 0) = 0 --AND eta.ApplSectionID = 3
SET NOCOUNT OFF




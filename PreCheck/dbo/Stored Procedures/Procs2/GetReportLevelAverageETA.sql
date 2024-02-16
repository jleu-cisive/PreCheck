--[dbo].[GetReportLevelAverageETA] 3993276 , 12771 --3433432
--[dbo].[GetReportLevelAverageETA] 3433432, 12771 --
CREATE PROCEDURE [dbo].[GetReportLevelAverageETA] 
@apno int,
@clno int
AS

set nocount on

DECLARE @HasETA bit

SELECT @HasETA = Value FROM ClientConfiguration WHERE (ConfigurationKey = 'Report_&_Component_ETA_Display_In_Client_Access' AND CLNO = @clno)

IF @HasETA = 1
	BEGIN
		SELECT --LEFT(CONVERT(VARCHAR, MAX(ETADate), 101), 10) AS ETADate, 
				CASE WHEN CAST(MAX(A.ETADate) AS DATE) < CAST(CURRENT_TIMESTAMP AS DATE) THEN 'Unavailable' 
						ELSE LEFT(CONVERT(VARCHAR, MAX(ETADate), 101), 10) 
				END AS ETADate,
		(SELECT Value FROM ClientConfiguration WHERE  ConfigurationKey = 'ClientAccess_ETA_Blurb' AND CLNO = 0) AS Blurb
		 FROM ApplSectionsETA AS A(NOLOCK) 
		 LEFT OUTER JOIN dbo.Crim AS C(NOLOCK) ON A.SectionKeyID = C.CrimID	AND A.ApplSectionID	= 5
		 LEFT OUTER JOIN dbo.EMPL AS E(NOLOCK) ON A.SectionKeyID = E.EmplID	AND A.ApplSectionID	= 1
		 LEFT OUTER JOIN dbo.Educat AS ED(NOLOCK) ON A.SectionKeyID = ED.EducatID AND A.ApplSectionID = 2
		 LEFT OUTER JOIN dbo.ProfLic AS P(NOLOCK) ON A.SectionKeyID = P.ProfLicID AND A.ApplSectionID = 4
		 LEFT OUTER JOIN dbo.DL AS D(NOLOCK) ON A.Apno = D.APNO AND A.ApplSectionID = 6
		 LEFT OUTER JOIN dbo.MedInteg AS M(NOLOCK) ON A.Apno = M.APNO AND A.ApplSectionID = 7
		 WHERE (C.Clear NOT IN ('T','F','P')
		   OR M.SectStat NOT IN ('2','3','4','5')
		   OR D.SectStat NOT IN ('2','3','4','5')
		   OR P.SectStat NOT IN ('2','3','4','5')
		   OR ED.SectStat NOT IN ('2','3','4','5')
		   OR E.SectStat NOT IN ('2','3','4','5'))
		 GROUP BY A.Apno 
		 HAVING A.Apno = @apno
	END
	ELSE
		SELECT '' AS ETADate, '' AS Blurb








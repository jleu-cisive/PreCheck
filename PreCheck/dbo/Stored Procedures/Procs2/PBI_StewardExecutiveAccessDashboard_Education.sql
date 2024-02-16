-- =============================================
/*
-- Author      : Vairavan  A
-- Create date : 11/22/2022
-- Description : To get data for Applications dataset of StewardExecutiveAccessDashboard Power Bi report
EXEC [PBI_StewardExecutiveAccessDashboard_Education] 2019,228,15382 --19sec
*/
-- =============================================
CREATE PROCEDURE dbo.PBI_StewardExecutiveAccessDashboard_Education
-- Add the parameters for the stored procedure here
@Year int,
@AffiliateID int,
@weborderparentclno smallint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	SET NOCOUNT ON;
	
	
;WITH cteApplIds AS
(
	SELECT a.APNO
	FROM dbo.Appl a WITH (nolock)
	INNER JOIN client c WITH (nolock)
		ON c.clno = a.clno
	INNER JOIN dbo.ClientCertification cer (nolock)
		ON cer.APNO = a.APNO AND cer.ClientCertReceived='Yes'
	WHERE year(a.OrigCompDate) >= @Year --2019
	--AND month(a.apDate) = 1
AND c.AffiliateID IN (@AffiliateID)--(228)
AND c.weborderparentclno = @weborderparentclno-- 15382
	AND a.OrigCompDate IS NOT NULL
), cteEduIds AS
(
	SELECT app.APNO, edu.EducatID, edu.School, ISNULL(edu.IsIntl, 0) IsInternational, edu.SectStat, edu.Last_Updated
	FROM [dbo].Educat edu WITH (nolock)
	INNER JOIN cteApplIds app
		ON edu.APNO = app.APNO
	WHERE edu.IsOnReport = 1 AND edu.IsHidden = 0
)
, cteChangeLogs AS
(
	SELECT cl.ID, MAX(cl.ChangeDate) ChangeDate
	FROM dbo.ChangeLog cl WITH (nolock)
	INNER JOIN cteEduIds edu
		ON cl.ID = edu.EducatID
	WHERE cl.NewValue IN ('1','2','3','4','5','6','7','8','A','E','B') AND cl.TableName = 'Educat.SectStat' AND YEAR(ChangeDate) >= @Year--2019
	GROUP BY cl.ID
), cteEdu AS
(
	SELECT edu.APNO, edu.EducatID EducatId, edu.School, edu.IsInternational, edu.SectStat
	, eduStatus.Description EducatStatus, edu.Last_Updated EducationLastUpdated
	, CASE WHEN cl.ChangeDate IS NOT NULL THEN cl.ChangeDate
			WHEN edu.SectStat IN ('1','2','3','4','5','6','7','8','A','E','B') THEN edu.Last_Updated
			ELSE NULL
			END ComponentClosingDate
	FROM cteEduIds edu
	INNER JOIN dbo.SectStat eduStatus 
		ON edu.SectStat = eduStatus.Code
	LEFT JOIN cteChangeLogs cl 
		ON cl.ID = edu.EducatID --AND cl.NewValue IN ('2','3','4','5') AND cl.TableName = 'Empl.SectStat'
)
SELECT *
FROM cteEdu
where EducatStatus NOT IN ('NEEDS REVIEW','PENDING','OnHold-AIReview')
AND ComponentClosingDate is not null

    
    
END


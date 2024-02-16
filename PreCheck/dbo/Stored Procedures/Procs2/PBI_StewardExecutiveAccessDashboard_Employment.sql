-- =============================================
/*
-- Author      : Vairavan  A
-- Create date : 11/22/2022
-- Description : To get data for Applications dataset of StewardExecutiveAccessDashboard Power Bi report
EXEC [PBI_StewardExecutiveAccessDashboard_Employment] 2019,228,15382
*/
-- =============================================
CREATE PROCEDURE dbo.PBI_StewardExecutiveAccessDashboard_Employment
-- Add the parameters for the stored procedure here
@Year int,
@AffiliateID int,
@weborderparentclno smallint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	SET NOCOUNT ON;
	;
;WITH cteApplIds AS
(
	SELECT a.APNO
	FROM dbo.Appl a WITH (nolock)
	INNER JOIN client c WITH (nolock)
		ON c.clno = a.clno
	INNER JOIN dbo.ClientCertification cer WITH (nolock)
		ON cer.APNO = a.APNO AND cer.ClientCertReceived='Yes'
	WHERE year(a.OrigCompDate) >= @Year --2019
	AND c.AffiliateID IN (@AffiliateID)--(228)
AND c.weborderparentclno = @weborderparentclno--15382
	AND a.OrigCompDate IS NOT NULL
), cteEmplIds AS
(
	SELECT app.APNO, empl.EmplID, empl.Employer, ISNULL(empl.IsIntl, 0) IsInternational, empl.SectStat, empl.Last_Updated
	FROM [dbo].[Empl] empl WITH (nolock)
	INNER JOIN cteApplIds app 
		ON empl.APNO = app.APNO
	WHERE empl.IsOnReport = 1 AND empl.IsHidden = 0
)
, cteChangeLogs AS
(
	SELECT cl.ID, MAX(cl.ChangeDate) ChangeDate
	FROM dbo.ChangeLog cl WITH (nolock)
	INNER JOIN cteEmplIds empl
		ON cl.ID = empl.EmplID
	WHERE cl.NewValue IN ('1','2','3','4','5','6','7','8','A','E','B') AND cl.TableName = 'Empl.SectStat' AND YEAR(ChangeDate) >= @Year--2019
	GROUP BY cl.ID
), cteEmpl AS
(
	SELECT empl.APNO, empl.EmplID EmploymentId, empl.Employer, empl.IsInternational, empl.SectStat
	, emplStatus.Description EmplStatus, empl.Last_Updated EmplomentLastUpdated
	, CASE WHEN cl.ChangeDate IS NOT NULL THEN cl.ChangeDate
			WHEN empl.SectStat IN ('1','2','3','4','5','6','7','8','A','E','B') THEN empl.Last_Updated
			ELSE NULL
			END ComponentClosingDate
	FROM cteEmplIds empl
	INNER JOIN dbo.SectStat emplStatus WITH (nolock)
		ON empl.SectStat = emplStatus.Code
	LEFT JOIN cteChangeLogs cl 
		ON cl.ID = empl.EmplID --AND cl.NewValue IN ('2','3','4','5') AND cl.TableName = 'Empl.SectStat'
)
SELECT *
FROM cteEmpl
WHERE EmplStatus NOT IN ('NEEDS REVIEW','PENDING','OnHold-AIReview')
AND ComponentClosingDate IS NOT NULL

    
    
END


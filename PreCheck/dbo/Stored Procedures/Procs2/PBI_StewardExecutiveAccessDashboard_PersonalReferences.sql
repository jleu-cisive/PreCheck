-- =============================================
/*
-- Author      : Vairavan  A
-- Create date : 11/22/2022
-- Description : To get data for Applications dataset of StewardExecutiveAccessDashboard Power Bi report
EXEC [PBI_StewardExecutiveAccessDashboard_PersonalReferences] 2019,228,15382 --10sec
*/
-- =============================================
CREATE PROCEDURE dbo.PBI_StewardExecutiveAccessDashboard_PersonalReferences
-- Add the parameters for the stored procedure here
@Year int,
@AffiliateID int,
@weborderparentclno smallint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	SET NOCOUNT ON;
	
;WITH cteApplId AS
(
	SELECT a.APNO,a.apdate
	FROM dbo.Appl a WITH (nolock)
	INNER JOIN client c WITH (nolock)
		ON c.clno = a.clno
	INNER JOIN dbo.ClientCertification cer with(nolock)
		ON cer.APNO = a.APNO AND cer.ClientCertReceived='Yes'
	WHERE year(a.OrigCompDate) >= @Year--2019
	--AND month(a.apDate) = 1
AND c.AffiliateID IN (@AffiliateID)--(228)
AND c.weborderparentclno = @weborderparentclno--15382
	AND a.OrigCompDate IS NOT NULL
), cteRefIds AS
(
	SELECT app1.APNO,app1.apdate, p.PersRefID, p.[Name] , p.SectStat, p.Last_Updated
	FROM [dbo].PersRef p WITH (nolock)
	INNER JOIN cteApplId app1
		ON p.APNO = app1.APNO
	WHERE p.IsOnReport = 1 AND p.IsHidden = 0
)
, cteChangeLogs AS
(
	SELECT cl.ID, MAX(cl.ChangeDate) ChangeDate
	FROM dbo.ChangeLog cl WITH (nolock)
	INNER JOIN cteRefIds pl
		ON cl.ID = pl.PersRefID
	WHERE cl.NewValue IN ('1','2','3','4','5','6','7','8','A','E','B') AND cl.TableName = 'PersRef.SectStat' AND YEAR(ChangeDate) >= @Year--2019
	GROUP BY cl.ID
), ctePRef AS
(
	SELECT pl.APNO,apdate CreateDate, pl.PersRefID PersRefID, [Name] PersRefName , 
	pl.SectStat,  PRefStatus.Description PersonalRefStatus, pl.Last_Updated PRefLastUpdated
	, CASE WHEN cl.ChangeDate IS NOT NULL THEN cl.ChangeDate
			WHEN pl.SectStat IN ('1','2','3','4','5','6','7','8','A','E','B') THEN pl.Last_Updated
			ELSE NULL
			END ComponentClosingDate
	FROM cteRefIds pl
	INNER JOIN dbo.SectStat PRefStatus  with(nolock)
		ON pl.SectStat = PRefStatus.Code
	LEFT JOIN cteChangeLogs cl
		ON cl.ID = pl.PersRefID --AND cl.NewValue IN ('2','3','4','5') AND cl.TableName = 'Empl.SectStat'
)
SELECT *
FROM ctePRef
WHERE PersonalRefStatus NOT IN ('NEEDS REVIEW','PENDING','OnHold-AIReview')
AND  ComponentClosingDate is not null
    
    
END


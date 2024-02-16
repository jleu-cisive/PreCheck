-- =============================================
/*
-- Author      : Vairavan  A
-- Create date : 11/22/2022
-- Description : To get data for Applications dataset of StewardExecutiveAccessDashboard Power Bi report
EXEC [PBI_StewardExecutiveAccessDashboard_Criminal] 2019,228,15382 --30sec
*/
-- =============================================
CREATE PROCEDURE dbo.PBI_StewardExecutiveAccessDashboard_Criminal
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
	INNER JOIN dbo.ClientCertification cer with(nolock)
		ON cer.APNO = a.APNO AND cer.ClientCertReceived='Yes'
	WHERE year(a.OrigCompDate) >= @Year--2019
AND c.AffiliateID IN (@AffiliateID)-- (228)
AND c.weborderparentclno = @weborderparentclno--15382
	AND a.OrigCompDate IS NOT NULL
), cteCrimIds AS
(
	SELECT app.APNO, cr.CrimID, cr.County
	, IsInternational =	CASE WHEN ISNULL(d.refCountyTypeID, 0) = 5 THEN 1 ELSE 0 END
	, RecordFound = CASE WHEN css.CrimDescription <> 'Clear' THEN 1 ELSE 0 END
	, Degree = CASE 
		WHEN cr.Degree = '1' THEN 'Petty Misdemeanor'
		WHEN cr.Degree = '2' THEN 'Traffic Misdemeanor'
		WHEN cr.Degree = '3' THEN 'Criminal Traffic'
		WHEN cr.Degree = '4' THEN 'Traffic'
		WHEN cr.Degree = '5' THEN 'Ordinance Violation'
		WHEN cr.Degree = '6' THEN 'Infraction'
		WHEN cr.Degree = '7' THEN 'Disorderly Persons'
		WHEN cr.Degree = '8' THEN 'Summary Offense'
		WHEN cr.Degree = '9' THEN 'Indictable Crime'
		WHEN cr.Degree = 'F' THEN 'Felony'
		WHEN cr.Degree = 'M' THEN 'Misdemeanor'
		WHEN cr.Degree = 'O' THEN 'Other'
		WHEN cr.Degree = 'U' THEN 'Unknown'
	END
	, cr.Offense, cr.Crimenteredtime DateCreated, cr.Last_Updated LastUpdated
	FROM [dbo].Crim cr WITH (nolock)
	INNER JOIN cteApplIds app
		ON cr.APNO = app.APNO
	INNER JOIN dbo.counties d with(NOLOCK) 
		ON cr.CNTY_NO = d.CNTY_NO 
	INNER JOIN Crimsectstat css  with(Nolock)
		ON cr.Clear = css.crimsect
	WHERE cr.IsHidden = 0 AND cr.Clear IN ('F','T','P')
)
, cteChangeLogs AS
(
	SELECT cl.ID, MAX(cl.ChangeDate) ChangeDate
	FROM dbo.ChangeLog cl WITH (nolock)
	INNER JOIN cteCrimIds cr
		ON cl.ID = cr.CrimID
	WHERE cl.NewValue IN ('F','T','P') AND YEAR(ChangeDate) >= 2019
	GROUP BY cl.ID
), cteCrims AS
(
	SELECT cr.APNO, cr.CrimID, cr.County, cr.IsInternational, cr.RecordFound, cr.Degree, cr.Offense
	, cr.DateCreated
	, ComponentClosingDate = CASE WHEN cl.ChangeDate IS NOT NULL THEN cl.ChangeDate
			ELSE cr.LastUpdated END
	FROM cteCrimIds cr
	LEFT JOIN cteChangeLogs cl 
		ON cl.ID = cr.CrimID
)
SELECT *
FROM cteCrims
where ComponentClosingDate is not null

    
END


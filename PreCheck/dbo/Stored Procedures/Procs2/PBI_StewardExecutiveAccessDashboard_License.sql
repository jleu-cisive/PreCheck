-- =============================================
/*
-- Author      : Vairavan  A
-- Create date : 11/22/2022
-- Description : To get data for Applications dataset of StewardExecutiveAccessDashboard Power Bi report
EXEC [PBI_StewardExecutiveAccessDashboard_License] 2019,228,15382 --18sec
*/
-- =============================================
CREATE PROCEDURE dbo.PBI_StewardExecutiveAccessDashboard_License
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
	SELECT a.APNO, a.CLNO, c.[name], FORMAT(a.Apdate,'MM/dd/yyyy hh:mm tt') as [Report Date]
	FROM dbo.Appl a WITH (nolock)
	INNER JOIN client c WITH (nolock)
		ON c.clno = a.clno
	INNER JOIN dbo.ClientCertification cer (nolock)
		ON cer.APNO = a.APNO AND cer.ClientCertReceived='Yes'
	WHERE year(a.OrigCompDate) >= @Year--2019
	--AND month(a.apDate) = 1
AND c.AffiliateID IN (@AffiliateID)-- (228)
AND c.weborderparentclno = @weborderparentclno--15382
	AND a.OrigCompDate IS NOT NULL
), cteLicenseIds AS
(
	SELECT app.APNO, p.ProfLicID as [License ID] , ISNULL(p.Lic_NO, 0) as [License Number],p.Lic_Type_V [License Type],p.State_V as [License State], p.SectStat, p.Last_Updated, app.CLNO, app.[Name], app.[Report Date]
	FROM [dbo].ProfLic p WITH (nolock)
	INNER JOIN cteApplIds app
		ON p.APNO = app.APNO
	WHERE p.IsOnReport = 1 AND p.IsHidden = 0
)
, cteChangeLogs AS
(
	SELECT cl.ID, MAX(cl.ChangeDate) ChangeDate
	FROM dbo.ChangeLog cl WITH (nolock)
	INNER JOIN cteLicenseIds pl
		ON cl.ID = pl.[License ID]
	WHERE cl.NewValue IN ('1','2','3','4','5','6','7','8','A','E','B') AND cl.TableName = 'ProfLic.SectStat' AND YEAR(ChangeDate) >= @Year--2019
	GROUP BY cl.ID
), cteLicense AS
(
	SELECT pl.APNO, [CLNO] as [Client Number], [name] as [Account Name],pl.[License ID], pl.[License Number], pl.[License Type], pl.SectStat
	, LicStatus1.Description LicStatus,[License State], pl.Last_Updated LicenseLastUpdated
	, CASE WHEN cl.ChangeDate IS NOT NULL THEN cl.ChangeDate
			WHEN pl.SectStat IN ('1','2','3','4','5','6','7','8','A','E','B') THEN pl.Last_Updated
			ELSE NULL
			END ComponentClosingDate, [Report Date]
	FROM cteLicenseIds pl
	INNER JOIN dbo.SectStat LicStatus1 (NOLOCK)
		ON pl.SectStat = LicStatus1.Code
	LEFT JOIN cteChangeLogs cl
		ON cl.ID = pl.[License ID] --AND cl.NewValue IN ('2','3','4','5') AND cl.TableName = 'Empl.SectStat'
)
SELECT *
FROM cteLicense
WHERE LicStatus NOT IN ('NEEDS REVIEW','PENDING','OnHold-AIReview')
AND ComponentClosingDate is not null
ORDER by APNO

    
END


-- =============================================
/*
-- Author      : Vairavan  A
-- Create date : 11/22/2022
-- Description : To get data for Applications dataset of StewardExecutiveAccessDashboard Power Bi report
EXEC [PBI_StewardExecutiveAccessDashboard_SanctionCheck] 2019,228,15382 --30sec
*/
-- =============================================
CREATE PROCEDURE dbo.PBI_StewardExecutiveAccessDashboard_SanctionCheck
-- Add the parameters for the stored procedure here
@Year int,
@AffiliateID int,
@weborderparentclno smallint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	SET NOCOUNT ON;
	
;WITH cteAppl AS
(
	SELECT a.APNO
	FROM dbo.Appl a WITH (nolock)
	INNER JOIN client c WITH (nolock)
		ON c.clno = a.clno
	INNER JOIN dbo.ClientCertification cer with (nolock)
		ON cer.APNO = a.APNO AND cer.ClientCertReceived='Yes'
	WHERE year(a.OrigCompDate) >= @Year--2019
	AND c.AffiliateID IN (@AffiliateID)--(228)
AND c.weborderparentclno = @weborderparentclno--15382
	AND a.OrigCompDate IS NOT NULL
),
cteMedLog AS
(
	SELECT medLog.Status as ComponentData, medLog.APNO
	FROM [MedIntegLog] medLog WITH (nolock)
	INNER JOIN Appl a WITH (nolock)
		ON medLog.APNO = a.APNO 
	WHERE medlog.ChangeDate = (SELECT max(changedate) FROM MedIntegLog WHERE apno = a.apno)	
)
SELECT a.APNO, medStatus.Description SanctionCheckStatus, medLog.ComponentData
FROM cteAppl a
INNER JOIN [dbo].[MedInteg] as med WITH (nolock)
	ON a.[APNO] = med.[Apno] AND med.IsHidden = 0
INNER JOIN cteMedLog as medLog
	ON med.[APNO] = medLog.[APNO]
LEFT JOIN dbo.SectStat medStatus  WITH (nolock)
	ON med.SectStat = medStatus.Code


END




-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 10/07/2021
-- Description:	Licenses that do not Qualify For Automated Agent Processing
-- =============================================
CREATE PROCEDURE [dbo].[LicensesNotQualifyForAutomation]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- check the RequestMapping and IsAutomationEnabled = 1 to exclude the LicenseType in the below query.
    -- Insert statements for procedure here
SELECT distinct 'Licensing' as [Section],
		pl.ProfLicID as [LicenseID],
	    a.Apno as [APNO],
		a.CLNO as [EmployerId],
		pl.Lic_type as [Type],
		pl.State as [IssuingState],
		pl.Lic_No as [Number],
		pl.LicenseTypeID as [LicenseTypeID]
FROM Precheck.dbo.Appl a (NOLOCK)
INNER JOIN Precheck.dbo.Proflic pl (NOLOCK) ON a.APNO = pl.Apno 
LEFT join hevn.dbo.vwLicenseTypeAlias LicType on (pl.Lic_Type = LicType.[Type] or pl.Lic_Type =LicType.Alias OR Pl.Lic_Type  = LicType.TypeDesc)
WHERE pl.Ishidden = 0
AND pl.IsOnreport = 1 
AND pl.SectStat = '9'
AND a.Apdate >= '01/01/2021' 
AND pl.Is_Investigator_Qualified = 0
AND 
	((CONCAT(ISNULL(pl.[State],''), '-', ISNULL(LicType.[Type], pl.Lic_Type)) NOT IN (SELECT SectionKeyID FROM Precheck.[dbo].[DataXtract_RequestMapping] (NOLOCK) WHERE Section ='License' and IsBackgroundAutomationEnabled = 1))
	OR  
	(pl.Lic_No IS NULL OR LTRIM(RTRIM(pl.Lic_No)) = '' OR pl.Lic_No IN ('n/a') OR pl.Lic_Type IS NULL OR LTRIM(RTRIM(pl.Lic_Type)) = '' OR pl.Lic_Type IN ('n/a')))
														   
END



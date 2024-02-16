-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 09/28/2021
-- Description:	Licenses For Automated Agent Processing
-- =============================================
CREATE PROCEDURE [dbo].[QReport_LicensesForAutomatedAgentProcessing]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
SELECT 'Licensing' as [Section], 
		pl.ProfLicID [LicenseID],
		a.CLNO as [EmployerId],
		c.name as [EmployerName], 
		pl.Lic_type as [Type],
		pl.State as [IssuingState],
		'' as [ExpiresDate],
		a.Last as [Last],
		a.First as [First], 
		'' as [DOB],
		pl.Lic_No as [Number],
		a.SSN as [SSN], --full SSN
		Replace(a.SSN,'-','') as [SSN_NoDashes], -- SSN with no Dashes
		RIGHT(a.SSN,4) as [SSN_Last4], --Last 4# SSN
		LEFT(a.SSN,3) as [SSN1], --First 3# of SSN
		(CASE 
			WHEN CHARINDEX('-',a.SSN) > 0 
			THEN SUBSTRING(a.SSN,5,2)
			ELSE SUBSTRING(a.SSN,4,2) 
		END) as [SSN2], --Middle 2# of SSN
		RIGHT(a.SSN,4) [SSN3], -- Last 4# of SSN
		IsInvestigator_Qualified = case when Is_Investigator_Qualified =0 then 'False' else 'True' end,
		a.Apno as ReportNumber,
		pl.Investigator
FROM dbo.Appl a (NOLOCK)
INNER JOIN dbo.Client C (NOLOCK) ON a.clno = c.clno
INNER JOIN dbo.Proflic pl (NOLOCK) ON a.APNO = pl.Apno 
INNER JOIN dbo.SectStat ss (NOLOCK) ON pl.SectStat = ss.Code
WHERE  pl.Ishidden = 0
AND pl.IsOnreport = 1 
AND pl.SectStat = '9'
AND a.Apdate >= '01/01/2021' 


END

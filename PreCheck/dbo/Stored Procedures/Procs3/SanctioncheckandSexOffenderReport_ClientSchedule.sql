-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 04/01/2021
-- Description:	Create a new qreport for Conifer SO GSA OIG Report, for Turnaroundtime on components
-- EXEC [dbo].[SanctioncheckandSexOffenderReport_ClientSchedule]
-- =============================================
CREATE PROCEDURE [dbo].[SanctioncheckandSexOffenderReport_ClientSchedule]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT a.APNO [Report ID], a.First[Applicant First Name],a.Last[Applicant Last Name], A.Apdate [Report StartDate],
		   s.Description [SanctionCheck Status], Crs.CrimDescription[Sex Offender Status]
	 FROM APPL a WITH(NOLOCK)
	 INNER JOIN Client c WITH(NOLOCK) ON a.CLNO = c.CLNO
	 INNER JOIN CRIM cr WITH(NOLOCK) ON a.apno = cr.apno
	 INNER JOIN MedInteg m WITH(NOLOCK) ON a.apno = m.apno
	 INNER JOIN CrimsectStat crs WITH(NOLOCK) ON cr.CLear = crs.crimsect
	 INNER JOIN SectStat s WITH(NOLOCK) ON m.Sectstat = s.Code
	 WHERE Cr.CNTY_NO =2480 
	 AND cr.IsHidden = 0
	 AND a.Apstatus ='P'
	 AND c.AffiliateId = 129

END

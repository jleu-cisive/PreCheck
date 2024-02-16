-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 04/02/2021
-- Description:	Thomas and Thorngren request
-- EXEC [ThomasAndCompanyIntegration] 
--'03/01/2021','03/31/2021'
-- Add AffiliateId to the main query.
-- Modified by AmyLiu on 06/02/2021 for HDT7226 to trim whitespace
-- =============================================
CREATE PROCEDURE [dbo].[ThomasAndCompanyIntegration]
--	@StartDate datetime,
--	@EndDate datetime

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	CREATE TABLE #tempCLNO
	(
		CLNO int,
		ClientName varchar(100),
		AffiliateID int
	)

	 INSERT INTO #tempCLNO
	 SELECT CLNO,[Name] as ClientName, AffiliateID FROM dbo.Client (NOLOCK) where (WebOrderParentCLNO in (7519,15382,15623) OR Affiliateid in (4,5,237,228))


    -- Insert statements for procedure here
	SELECT distinct A.APNO [Report Number],A.SSN, A.First [Applicant First Name], A.Last  [Applicant Last Name], 
				 E.Employer [Employer Name], 
				E.State, E.From_A [Start Date Per Applicant],
				E.To_A [End Date Per Applicant],E.Position_A [Position Per Applicant], R.Affiliate,
				t.ClientName [HCA Client Name]  
	FROM dbo.Appl A  WITH(NOLOCK)
	INNER JOIN dbo.Empl E WITH(NOLOCK) ON A.APNO = E.APNO     
	INNER JOIN #tempCLNO t ON t.CLNO = a.CLNO	 
	INNER JOIN dbo.refAffiliate R WITH(NOLOCK) ON t.AffiliateID = R.AffiliateID 
	INNER JOIN dbo.[ClientEmployer] CE WITH(NOLOCK) ON (E.Employer = CE.Company OR CHARINDEX(ltrim(rtrim(e.Employer)), CE.AliasList) > 0 ) AND CE.Deleted = 0
	INNER JOIN #tempCLNO t1 ON t1.CLNO = CE.CLNO 
	WHERE A.ApStatus IN ('P')  
	AND E.DNC = 0     
	AND E.SectStat = '9'  
	AND E.IsOnReport = 1      
	AND E.Investigator = 'THORNGRE'     
	AND E.web_status NOT IN (60)   	



END

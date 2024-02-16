-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 04/26/2018
-- Description:	Creates a stored procedure instead of inline query for qreports.
-- =============================================
CREATE PROCEDURE [dbo].[Thomas_And_Thorngren_Request]
	-- Add the parameters for the stored procedure here
	@StartDate datetime,
	@EndDate datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Insert statements for procedure here
		SELECT A.APNO [Report #],A.SSN, A.First [Applicant First Name], A.Last  [Applicant Last Name], 
			E.Employer [Employer Name],   '' [Charges], E.State,From_A [Start Date Per Applicant],
			To_A [End Date Per Applicant],Position_A [Position Per Applicant], R.Affiliate,
			C.Name [HCA Client Name],  '' [Client if HCA facility],'' [Eligible for Rehire],'' [Start Date Per T&T],
			'' [End Date Per T&T],'' [Location from T&T],'' [Full or Part Time],'' [Position Per T&T] 
		FROM dbo.Appl A  
		INNER JOIN dbo.Empl E ON A.APNO = E.APNO     
		INNER JOIN dbo.Client C ON A.CLNO = C.CLNO   
		INNER JOIN dbo.refAffiliate R ON C.AffiliateID = R.AffiliateID  
		WHERE A.ApStatus IN ('P','W')  
		AND A.Apdate >= @StartDate and A.Apdate <= @EndDate   
		AND E.DNC = 0     
		AND E.SectStat = '9'  
		AND E.IsOnReport = 1      
		AND E.Investigator = 'THORNGRE'   
		AND E.web_status = 14  --AND E.web_status = 90    ORDER BY A.ApDate ASC




END

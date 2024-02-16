-- =============================================
-- Author:		Humera Ahmed
-- Create date: 1/13/2020
-- Description:	Show the client all of the report/APNO which were closed the day prior.
-- EXEC [dbo].[DailyEmailReport_PreviousDayClosureAPNO] 1616
-- =============================================
CREATE PROCEDURE [dbo].[DailyEmailReport_PreviousDayClosureAPNO]
	-- Add the parameters for the stored procedure here
	@Clno int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @AffiliateID int

	SET @AffiliateID = (SELECT c.AffiliateID  FROM client c WHERE c.CLNO = @Clno)

	SELECT
		a.CLNO [Client Number], 
		c.Name [Client Name], 
		cc.ClientCertBy [Onboarder], a.APNO [Report Number], 
		a.First + ' ' + a.Last [Applicant Name], 
		pm.PackageDesc [Package Ordered],
		format(a.ApDate,'MM/dd/yyyy HH:mm') [Report Start Date], 
		format(a.CompDate,'MM/dd/yyyy HH:mm') [Report Conclusion Date] 
	FROM appl a 
	INNER JOIN client c ON a.CLNO = c.CLNO
	INNER JOIN dbo.refAffiliate ra ON c.AffiliateID = ra.AffiliateID
	INNER JOIN dbo.ClientCertification cc ON a.APNO = cc.APNO
	INNER JOIN dbo.PackageMain pm ON a.PackageID = pm.PackageID
	WHERE 
		a.ApStatus = 'F' 
		AND a.clno = @Clno 
		AND c.AffiliateID = @AffiliateID
		AND cast(a.CompDate as date) = dateadd(day,-1, cast(getdate() as date))
	ORDER BY a.ApDate 
END

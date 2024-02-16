-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 05/20/2020
-- Description:	Applicant Primary Residence Analysis
-- =============================================
CREATE PROCEDURE ApplicantPrimaryResidenceAnalysis_QReport
	-- Add the parameters for the stored procedure here
	@StartDate datetime,
	@EndDate datetime,
	@CLNO int,
	@AffiliateId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT a.APNO as 'Report Number', a.OrigCompDate as 'Original Close Date', c.CLNO as 'Client Number', c.Name as 'Client Name',
	a.First as 'First Name', a.Last as 'Last Name', CONCAT(a.Addr_Num, ' ' , Addr_Street) as 'Address',
	a.City as City, a.State as 'State', a.Zip as Zip
	FROM APPL a
	INNER JOIN Client c on a.clno = c.clno
	INNER JOIN refAffiliate rf on c.AffiliateId = rf.AffiliateId
	WHERE a.OrigCompDate Between @StartDate and @EndDate
	AND c.CLNO = IIF(@CLNO=0, c.CLNO, @CLNO)
	AND rf.AffiliateId = IIF(@AffiliateId =0, rf.AffiliateId, @AffiliateId)
	ORDER BY APNO DESC
END

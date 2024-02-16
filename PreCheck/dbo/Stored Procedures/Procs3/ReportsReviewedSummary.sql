-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 12/06/2018
-- Description:	Reports Reviewed Summary for Scott Stewart to review numbers in AIMI and OASIS
-- EXEC ReportsReviewedSummary '12/05/2018','12/05/2018'
-- =============================================
CREATE PROCEDURE [dbo].[ReportsReviewedSummary]
	-- Add the parameters for the stored procedure here
	@StartDate datetime ,
	@EndDate Datetime 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	CREATE TABLE #TempBPMCounts
	(
		[WorkDate] [date] NULL,
		[Investigator] [varchar](20) NULL,
		[Count] [varchar](100) NULL
	) 

	INSERT INTO #TempBPMCounts
	EXEC [Metastorm9_2].dbo.[BPM_AppCounts_ByDate] @StartDate,@EndDate


	CREATE TABLE #TempOASISReviewed
	(
		[UserID] [varchar](20) NULL,
		[EnteredBy] int NULL,
		[DEMI] int NULL,
		[Reviewed(Get Next)] int null,
		[Reviewed(Not Get Next)] int null,
		[Total] int null,
		[Finaled] int null
	) 

	INSERT INTO #TempOASISReviewed
	EXEC [Applicant_Investigator_Performance_Report] @StartDate, @EndDate




	Select Investigator, sum(ReviewedinAIMI) as 'ReviewedinAIMI', sum(ReviewedInOASIS) as 'ReviewedInOASIS' into #tempReviewReports from
	(
		Select Investigator as 'Investigator', [Count] as 'ReviewedinAIMI', 0 'ReviewedInOASIS' from #TempBPMCounts where Investigator not in('AIMI - TotalCount', 'DEMI - TotalCount')

		UNION ALL

		Select UserID as 'Investigator', 0 as 'ReviewedinAIMI', Total as 'ReviewedInOASIS' from #TempOASISReviewed where Total > 0
	) A
	Group by Investigator


	Select Investigator, ReviewedinAIMI, ReviewedInOASIS, (ReviewedinAIMI  + ReviewedInOASIS ) as 'TotalReviewed' into #tempReviewedSummary from #tempReviewReports
	

	Select * from #tempReviewedSummary

	UNION ALL

	Select 'Total' as Investigator, Sum(ReviewedinAIMI) as ReviewedinAIMI, Sum( ReviewedInOASIS) as ReviewedInOASIS, sum(TotalReviewed) as TotalReviewed from #tempReviewedSummary


	DROP TABLE #TempBPMCounts
	DROP TABLE #TempOASISReviewed
	DROP TABLE #tempReviewReports
	DROP TABLE #tempReviewedSummary

END

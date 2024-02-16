
-- =============================================
-- Author:		James Norton
-- Create date: 10/14/20121
-- Description:	TOTAL NUMBER OF REPORTS PENDING FINAL QC REVIEW
-- Execution: EXEC QReport_TotalReportsPendingQCReview '09/01/2018', '09/30/2018', 0, 0, 0

-- =============================================
CREATE PROCEDURE [dbo].[QReport_QReport_OutstandingConsents]
	-- Add the parameters for the stored procedure here
	@StartDate date,
	@EndDate Date,	
    @AffiliateID int,
	@CLNO INT
AS
BEGIN

	SET ANSI_WARNINGS OFF 

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL  READ UNCOMMITTED



	--DECLARE temp tables (helps to maintain the same plan regardless of stats change)
	CREATE TABLE #tmp(
		[APNO] [int] NOT NULL,
		[CLNO] [smallint] NOT NULL,
		[Applicant First Name] [varchar](20) NOT NULL,
		[Applicant Last Name] [varchar](20) NOT NULL,
		[ApDate] [datetime] NULL)




	
	

		--Index on temp tables
	CREATE CLUSTERED INDEX IX_tmp_01 ON #tmp(APNO)
 


	-- Get all the "Finalized" reports
	INSERT INTO #tmp
	SELECT APNO, A.CLNO,  A.First AS [Applicant First Name], A.Last AS [Applicant Last Name], ApDate
	FROM dbo.Appl(NOLOCK) AS A
	INNER JOIN dbo.Client AS C(NOLOCK) ON A.CLNO = C.CLNO
	INNER JOIN dbo.refAffiliate AS RA WITH (NOLOCK) ON C.AffiliateID = RA.AffiliateID
	WHERE ApStatus = 'F' 
	  AND A.CLNO NOT IN (2135,3468)   AND (@CLNO IS NULL OR C.CLNO = @CLNO)
	  AND cast(ApDate as Date) BETWEEN @StartDate AND DATEADD(d,1,@EndDate)
  	  AND RA.AffiliateID = IIF(@AffiliateID = 0,RA.AffiliateID, @AffiliateID)
	  	

   Select * from #tmp;
  DROP TABLE #tmp


END


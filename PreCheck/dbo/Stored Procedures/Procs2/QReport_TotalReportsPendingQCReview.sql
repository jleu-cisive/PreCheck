-- =============================================
-- Author:		James Norton
-- Create date: 10/14/20121
-- Description:	TOTAL NUMBER OF REPORTS PENDING FINAL QC REVIEW
-- Execution: EXEC QReport_TotalReportsPendingQCReview '09/01/2018', '09/30/2018', 0, 0, 0
/* Modified By: Vairavan A
-- Modified Date: 07/12/2022
-- Description: Ticketno-53763 
Modify existing q-reports that have affiliate ids in their search parameters
Details: 
Change search parameters for the Affiliate Id field
     * search by multiple affiliate ids (ex 4:297)
     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates
     * multiple affiliates to be separated by a colon  
Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0)

Child ticket id -55503 Velocity Q reports Part 2
*/
---Testing
/*
EXEC [dbo].[QReport_TotalReportsPendingQCReview] '6/11/2015','6/11/2022' ,'0','0'
EXEC [dbo].[QReport_TotalReportsPendingQCReview] '6/11/2019','6/11/2022' ,'4','0'
EXEC [dbo].[QReport_TotalReportsPendingQCReview] '06/11/2015','06/11/2022' ,'4:30','0'
*/
-- =============================================
CREATE PROCEDURE [dbo].[QReport_TotalReportsPendingQCReview]
	-- Add the parameters for the stored procedure here
	@StartDate date,
	@EndDate Date,	
   -- @AffiliateID int,--code Commented by vairavan for ticket id -53763(55503)
	 @AffiliateIDs varchar(MAX) = '0',--code added by vairavan for ticket id -53763(55503)
	@CLNO INT
AS
BEGIN

	SET ANSI_WARNINGS OFF 

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL  READ UNCOMMITTED

	
   --code added by vairavan for ticket id -53763(55503) starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END
	--code added by vairavan for ticket id -53763(55503) ends

	--DECLARE temp tables (helps to maintain the same plan regardless of stats change)
	CREATE TABLE #tmp(
		[APNO] [int] NOT NULL,
		[CLNO] [smallint] NOT NULL,
		[Applicant First Name] [varchar](20) NOT NULL,
		[Applicant Last Name] [varchar](20) NOT NULL,
		[ApDate] [datetime] NULL,
		[CompDate] [datetime] NULL,
		[OrigCompDate] [datetime] NULL)

	

		--Index on temp tables
	CREATE CLUSTERED INDEX IX_tmp_01 ON #tmp(APNO)



	-- Get all the "Finalized" reports
	INSERT INTO #tmp
	SELECT APNO, A.CLNO,  A.First AS [Applicant First Name], A.Last AS [Applicant Last Name], ApDate, CompDate, A.OrigCompDate
	FROM dbo.Appl  AS A with(NOLOCK)
	INNER JOIN dbo.Client AS C with(NOLOCK) ON A.CLNO = C.CLNO
	INNER JOIN dbo.refAffiliate AS RA WITH (NOLOCK) ON C.AffiliateID = RA.AffiliateID
	WHERE ApStatus = 'F' 
	  --AND A.CLNO NOT IN (2135,3468)   AND (@CLNO IS NULL OR C.CLNO = @CLNO)
	    AND A.CLNO NOT IN (2135,3468)   AND (@CLNO IS NULL OR C.CLNO =  IIF(@CLNO=0,c.CLNO, @CLNO) )

	  AND cast(OrigCompDate as Date) BETWEEN @StartDate AND DATEADD(d,1,@EndDate)
   	 -- AND RA.AffiliateID = IIF(@AffiliateID = 0,RA.AffiliateID, @AffiliateID) --code commented by vairavan for ticket id -53763(55503)
	  and (@AffiliateIDs IS NULL OR ra.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763(55503)
	  	
	select * from #tmp;
	
  DROP TABLE #tmp


END




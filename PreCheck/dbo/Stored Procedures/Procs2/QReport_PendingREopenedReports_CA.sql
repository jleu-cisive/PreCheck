
-- =============================================
-- Author:		James Norton
-- Create date: 10/14/20121
-- Description:	PENDING REOPENDED REPORTS/UPDATED REPORTS
-- Execution: EXEC QReport_PendingREopenedReports '09/01/2018', '09/30/2018', 0, 0, 0

-- =============================================
CREATE PROCEDURE [dbo].[QReport_PendingREopenedReports_CA]
	-- Add the parameters for the stored procedure here
	@CLNO INT,
	@AffiliateID INT = 0,
	@StartDate datetime,
	@EndDate datetime
AS
BEGIN

	SET ANSI_WARNINGS OFF 

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL  READ UNCOMMITTED

 

	--DECLARE temp tables (helps to maintain the same plan regardless of stats change)
	CREATE TABLE #tmp(
		[Report Number] [int] NOT NULL,
		[Client ID] [smallint] NOT NULL,
		[Client Name] [varchar](100) NULL,
		[Affiliate] [varchar](100) NULL,
		[Applicant First Name] [varchar](20) NOT NULL,
		[Applicant Last Name] [varchar](20) NOT NULL,
		[Report Create Date] [datetime] NULL,    --Original Close Dat
		[Original Closed Date] [datetime] NULL,    --Original Close Dat
		[Reopen Date] [datetime] NULL,    --Original Close Dat
		[Complete Date] [datetime] NULL,    --Original Close Date
		[Current Status] [varchar](20) NULL)
	

	
	

		--Index on temp tables
	CREATE CLUSTERED INDEX IX_tmp_01 ON #tmp([Report Number])
	
     IF		(@CLNO = '0')SET @CLNO = NULL;
 

	-- Get all the "Pending" reports
	INSERT INTO #tmp
	SELECT APNO as [Report Number]
		, A.CLNO as [Client ID]
		, C.Name AS [Client Name]
		, ra.Affiliate
		, A.First AS [Applicant First Name]
		, A.Last AS [Applicant Last Name]
		,FORMAT(a.ApDate, 'MM/dd/yyyy hh:mm tt') AS 'Report Create Date'
		,FORMAT(a.OrigCompDate, 'MM/dd/yyyy hh:mm tt') AS 'Original Closed Date'
		,FORMAT(a.ReopenDate, 'MM/dd/yyyy hh:mm tt') AS 'Reopen Date'
		,FORMAT(a.CompDate, 'MM/dd/yyyy hh:mm tt') AS 'Complete Date'
		, A.ApStatus as [Current Status]
	FROM dbo.Appl(NOLOCK) AS A
	INNER JOIN dbo.Client AS C(NOLOCK) ON A.CLNO = C.CLNO
	INNER JOIN refAffiliate ra with (Nolock) on ra.AffiliateID = c.AffiliateID

	WHERE ApStatus = 'P' 
	  AND A.CLNO NOT IN (2135,3468) AND (@CLNO IS NULL OR C.CLNO = @CLNO)
	  AND C.AffiliateID = IIF(@AffiliateID=0,C.AffiliateID,@AffiliateID)
	  AND cast(OrigCompDate as Date) BETWEEN @StartDate AND DATEADD(d,1,@EndDate)
      AND cast(ReOpenDate as Date) BETWEEN @StartDate AND DATEADD(d,1,@EndDate)
	 
	 select * from #tmp; 	

	
  DROP TABLE #tmp


END


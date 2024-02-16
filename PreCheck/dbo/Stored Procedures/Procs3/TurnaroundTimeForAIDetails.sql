-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 07/25/2018
-- Requester: Dana Sangerhausen
-- Description:	Please create report that provides a detail version of AI Turnaround Time report.  
-- Parameters are dates, and should work the same as Turnaround Time for AI (No Auto Order) as far as logic what reports it includes.  
-- Output - Report Date/Time,  Reviewed Date/Time, Apno, Applicant First, Applicant Last, Client Name, Affiliate, Reviewed By, AI TAT (Hours between Report Date and Reviewed Date). 
-- EXEC [TurnaroundTimeForAIDetails] '07/01/2018', '07/15/2018'
-- =============================================

CREATE PROCEDURE [dbo].[TurnaroundTimeForAIDetails]

  @StartDate datetime,
  @EndDate datetime  

AS
BEGIN


	SET ANSI_WARNINGS OFF 

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL  READ UNCOMMITTED


	CREATE TABLE #ReportDetails(
		[APNO] [int] NOT NULL,
		[CLNO] [smallint] NOT NULL,
		[ClientName] [varchar](100) NULL,
		[Affiliate] [varchar](100) NULL,
		[Applicant First] [varchar](20) NOT NULL,
		[Applicant Last] [varchar](20) NOT NULL,
		[ReviewedBy] [varchar](100) NULL,
		[ReportDateTime] [datetime] NULL,
		[ReviewedDateTime] [datetime] NULL,	
		[ApplCreatedDate] [datetime] null,
		[EnteredVia] [varchar](8) null,
		[ReportEverGoToOnHoldStatus] [varchar](2) NULL
		)
 
 	CREATE TABLE #DateEnteredOnHoldStatus(
		[APNO] [int] NOT NULL,
		[DateEnteredOnHoldStatus] [datetime] not NULL
		)

 	CREATE TABLE #DateReleasedFromOnHoldStatus(
		[APNO] [int] NOT NULL,
		[DateReleasedFromOnHoldStatus] [datetime] not null
		)

	CREATE TABLE #ReportDetailsWithStatusDate(
			[APNO] [int] NOT NULL,
			[CLNO] [smallint] NOT NULL,
			[ClientName] [varchar](100) NULL,
			[Affiliate] [varchar](100) NULL,
			[Applicant First] [varchar](20) NOT NULL,
			[Applicant Last] [varchar](20) NOT NULL,
			[ReviewedBy] [varchar](100) NULL,
			[ReportDateTime] [datetime] NULL,
			[ReviewedDateTime] [datetime] NULL,	
			[ApplCreatedDate] [datetime] null,
			[EnteredVia] [varchar](8) null,
			[ReportEverGoToOnHoldStatus] [varchar](2) NULL,
			[DateEnteredOnHoldStatus] [datetime] not null,
			[DateReleasedFromOnHoldStatus] [datetime] not null
			)
	CREATE TABLE #ReportDeatilswithMilitaryTime(
			[APNO] [int] NOT NULL,
			[CLNO] [smallint] NOT NULL,
			[ClientName] [varchar](100) NULL,
			[Affiliate] [varchar](100) NULL,
			[Applicant First] [varchar](20) NOT NULL,
			[Applicant Last] [varchar](20) NOT NULL,
			[ReviewedBy] [varchar](100) NULL,
			[ReportDateTime] [datetime] NULL,
			[ReviewedDateTime] [datetime] NULL,	
			[ApplCreatedDate] [datetime] null,
			[EnteredVia] [varchar](8) null,
			[ReportEverGoToOnHoldStatus] [varchar](2) NULL,
			[DateEnteredOnHoldStatus] [datetime] not null,
			[DateReleasedFromOnHoldStatus] [datetime] not null,
			[ElapsedDaysOnHold] [int] null,
			[AIElapsedHours] [int] null
			)

			

 	CREATE CLUSTERED INDEX IX_ReportDetails_01 ON #ReportDetails(APNO)
 	CREATE CLUSTERED INDEX IX_ReportDetails_02 ON #DateEnteredOnHoldStatus(APNO)
 	CREATE CLUSTERED INDEX IX_ReportDetails_03 ON #DateReleasedFromOnHoldStatus(APNO)
 	CREATE CLUSTERED INDEX IX_ReportDetails_04 ON #ReportDetailsWithStatusDate(APNO)
	CREATE CLUSTERED INDEX IX_ReportDetails_05 ON #ReportDeatilswithMilitaryTime(APNO)

	INSERT INTO #ReportDetails
	SELECT	a.apno,c.CLNO, c.Name as 'ClientName',rf.Affiliate, a.First as 'Applicant First', a.Last as 'Applicant Last', o.Investigator as 'ReviewedBy', 
			a.ApDate as 'ReportDateTime', o.AIMICreatedDate as 'ReviewedDateTime', a.CreatedDate, a.EnteredVia,
			Case WHEN (Select Count(*) from Appl_StatusLog where (Curr_apstatus ='M' OR Prev_apstatus ='M')  and a.APNO = Appl_StatusLog.APNO) > 0 THEN 'Y' ELSE 'N' END as 'ReportEverGoToOnHoldStatus'
	FROM Appl a WITH(NOLOCK)
	INNER JOIN Client c WITH(NOLOCK) ON a.CLNo = c.CLNO
	INNER JOIN refAffiliate rf WITH(NOLOCK) ON c.AffiliateID = rf.AffiliateID
	INNER JOIN [Metastorm9_2].[dbo].[Oasis] o WITH(NOLOCK) ON a.apno = cast(o.apno AS INT) AND o.apno IS NOT NULL
	WHERE a.Apdate >= @StartDate AND a.Apdate < DATEADD(d,1,@EndDate)    
		 AND a.CLNO NOT IN (3468, 2135)
		 AND a.Investigator NOT IN ('DSOnly', 'Immuniz', 'AUTO')
		 AND o.AIMICreatedDate IS NOT NULL

	--SELECT * FROM #ReportDetails

	;WITH DateEnteredOnHoldStatus AS
	(
		SELECT  L.APNO, L.ChangeDate as 'DateEnteredOnHoldStatus',
				ROW_NUMBER() OVER (PARTITION BY L.Apno ORDER BY L.ChangeDate) AS RowNumber
		FROM Appl_StatusLog AS L(NOLOCK)
		INNER JOIN #ReportDetails AS D(NOLOCK) ON L.Apno = D.APNO	
		WHERE (Prev_apstatus ='P' AND Curr_apstatus ='M')
	)
	INSERT INTO #DateEnteredOnHoldStatus
	SELECT  APNO, DateEnteredOnHoldStatus
	FROM DateEnteredOnHoldStatus
	WHERE RowNumber = 1

	--SELECT * FROM #DateEnteredOnHoldStatus ORDER BY 1 
	--SELECT * FROM Appl_StatusLog L WHERE L.APNO = 4193968 AND Prev_apstatus ='P' AND Curr_apstatus ='M'

	;WITH DateReleasedFromOnHoldStatus AS
	(
		SELECT  L.APNO, L.ChangeDate as 'DateReleasedFromOnHoldStatus',
				ROW_NUMBER() OVER (PARTITION BY L.Apno ORDER BY L.ChangeDate) AS RowNumber
		FROM Appl_StatusLog AS L(NOLOCK)
		INNER JOIN #ReportDetails AS D(NOLOCK) ON L.Apno = D.APNO	
		WHERE (Prev_apstatus ='M' and Curr_apstatus ='P')
	)
	INSERT INTO #DateReleasedFromOnHoldStatus
	SELECT APNO, DateReleasedFromOnHoldStatus
	FROM DateReleasedFromOnHoldStatus
	WHERE RowNumber = 1
	
	--SELECT * FROM Appl_StatusLog L WHERE L.APNO = 4193968 AND Prev_apstatus ='M' AND Curr_apstatus ='P'

	--SELECT * FROM #DateReleasedFromOnHoldStatus ORDER BY 1 

	INSERT INTO #ReportDetailsWithStatusDate
	SELECT r.*, ISNULL(te.DateEnteredOnHoldStatus, r.ApplCreatedDate) as 'DateEnteredOnHoldStatus', 
			ISNULL(tr.DateReleasedFromOnHoldStatus, r.ReportDateTime) as 'DateReleasedFromOnHoldStatus'
	FROM #ReportDetails r
	LEFT OUTER JOIN #DateEnteredOnHoldStatus te ON r.APNO = te.APNO
	LEFT OUTER JOIN #DateReleasedFromOnHoldStatus tr ON r.APNO = tr.APNO

	--SELECT * FROM #ReportDetailsWithStatusDate AS R(NOLOCK) WHERE R.APNO = 4188273 ORDER BY 1 DESC
	INSERT INTO #ReportDeatilswithMilitaryTime
	SELECT	r.*, [dbo].[ElapsedBusinessDays_2](DateEnteredOnHoldStatus, DateReleasedFromOnHoldStatus) AS 'ElapsedDaysOnHold',
	CASE WHEN ([ReportEverGoToOnHoldStatus] = 'Y' and [EnteredVia] ='CIC') THEN [dbo].[ElapsedBusinessHours_2](DateReleasedFromOnHoldStatus, ReviewedDateTime) ELSE [dbo].[ElapsedBusinessHours_2](ReportDateTime, ReviewedDateTime) END AS 'AIElapsedHours' 
	FROM #ReportDetailsWithStatusDate r



	SELECT [APNO],[CLNO] ,[ClientName],[Affiliate],[Applicant First],[Applicant Last],[ReviewedBy],
		CONVERT(varchar,[ReportDateTime],121) as [ReportDateTime], 	CONVERT(varchar,[ReviewedDateTime],121) as [ReviewedDateTime], CONVERT(varchar,[ApplCreatedDate], 121) as [ApplCreatedDate],
		[EnteredVia],[ReportEverGoToOnHoldStatus], CONVERT(varchar,[DateEnteredOnHoldStatus], 121) as [DateEnteredOnHoldStatus],
		CONVERT(varchar,[DateReleasedFromOnHoldStatus], 121) as [DateReleasedFromOnHoldStatus], [ElapsedDaysOnHold],[AIElapsedHours]
	INTO #tempDateTime
	FROM #ReportDeatilswithMilitaryTime

	SELECT [APNO],[CLNO] ,[ClientName],[Affiliate],[Applicant First],[Applicant Last],[ReviewedBy], [EnteredVia],[ReportEverGoToOnHoldStatus],
	Convert(varchar(10),[ReportDateTime],120) as [ReportDate], Convert(varchar(8),convert(time,[ReportDateTime])) as [ReportTime],
	Convert(varchar(10),[ReviewedDateTime],120) as [ReviewedDate], Convert(varchar(8),convert(time,[ReviewedDateTime])) as [ReviewedTime],
	Convert(varchar(10),[ApplCreatedDate],120) as [ApplCreatedDate], Convert(varchar(8),convert(time,[ApplCreatedDate])) as [ApplCreatedTime],	
	Convert(varchar(10),[DateEnteredOnHoldStatus],120) as [DateEnteredOnHoldStatusDate], Convert(varchar(8),convert(time,[DateEnteredOnHoldStatus])) as [DateEnteredOnHoldStatusTime],
	Convert(varchar(10),[DateReleasedFromOnHoldStatus],120) as [DateReleasedFromOnHoldStatusDate], Convert(varchar(8),convert(time,[DateReleasedFromOnHoldStatus])) as [DateReleasedFromOnHoldStatusTime],
	[ElapsedDaysOnHold],[AIElapsedHours]
	INTO #tempReviewOffPeakHours
	FROM #tempDateTime


	SELECT [APNO],[CLNO] ,[ClientName],[Affiliate],[Applicant First],[Applicant Last],[ReviewedBy], [EnteredVia],[ReportEverGoToOnHoldStatus],
	CASE WHEN ([ReviewedTime] >= '18:01:00' and [ReviewedTime] <= '5:59:59') THEN 'Y' ELSE 'N' END AS [ReviewOccurredinOffPeakHours],
	[ReportDate],[ReportTime],[ReviewedDate],[ReviewedTime],[ApplCreatedDate],[ApplCreatedTime],
	[DateEnteredOnHoldStatusDate],[DateEnteredOnHoldStatusTime],[DateReleasedFromOnHoldStatusDate],[DateReleasedFromOnHoldStatusTime],
	[ElapsedDaysOnHold],[AIElapsedHours]
	FROM #tempReviewOffPeakHours
	
	
	DROP Table #ReportDetails
	DROP Table #DateEnteredOnHoldStatus
	DROP Table #DateReleasedFromOnHoldStatus
	DROP Table #ReportDetailsWithStatusDate
	DROP TABLE #ReportDeatilswithMilitaryTime
	DROP TABLE #tempDateTime
END

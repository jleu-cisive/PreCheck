

/******************************************************************
Procedure Name : [dbo].[AdverseAction_ReportingAndTAT]
Requested By:Brian Silver
Developer: Prasanna
Description: 10/04/2018 HDT40794:New QReport Needed for HCA Reporting
Execution : EXEC [dbo].[AdverseAction_ReportingAndTAT] 1616,'06/01/2019','07/01/2019',0
			EXEC [dbo].[AdverseAction_ReportingAndTAT] 0,'06/01/2019','06/30/2019',0
******************************************************************/

CREATE PROCEDURE [dbo].[AdverseAction_ReportingAndTAT_CA]
@CLNO int = 0,
@StartDate datetime = null,
@EndDate datetime = null,
@AffiliateID int = 0
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	SELECT *  INTO #tempViewAdverse FROM [dbo].[vwAdverseHistory] vah(nolock) WHERE vah.DateAdverseStarted >= @StartDate AND vah.DateAdverseStarted <= @EndDate

	SELECT	distinct a.apno AS ReportNumber, c.CLNO AS [Client ID], c.Name AS [Client Name],ra.Affiliate AS [Affiliate Name], f.IsOneHR AS [Is OneHR], a.Last AS [Applicant Last Name],
			a.First AS [Applicant First Name],a.Priv_Notes AS [Private Notes],aa.ClientEmail AS [Requested by],aah.StatusID AS AdverseActionStatusID, ras.Status AS [AdverseActionStatus], aah.[Date] AS AdverseActionHistoryDate,
			ras.Status,
			A.APDATE AS [Background Request Date],
			A.CompDate AS [Final Background Report Date],
			a.OrigCompDate AS [Original Completion Date]
	INTO  #TmpReportList 
	FROM appl a (nolock)		
	LEFT OUTER JOIN HEVN.dbo.Facility F (NOLOCK) ON a.clno =FacilityCLNO and ISNULL(A.DeptCode,0) = F.FacilityNum
	LEFT OUTER JOIN client c(nolock) ON a.CLNO = c.CLNO
	LEFT OUTER JOIN dbo.AdverseAction aa(nolock) ON a.APNO = aa.APNO
	LEFT OUTER JOIN AdverseActionHistory aah(nolock) ON aa.AdverseActionID = aah.AdverseActionID
	LEFT OUTER JOIN dbo.refAffiliate ra(nolock) ON c.AffiliateID = ra.AffiliateID
	LEFT OUTER JOIN refAdverseStatus	ras ON aah.StatusID = ras.refAdverseStatusID 
	WHERE c.CLNO = IIF(@CLNO = 0, c.CLNO, @CLNO) AND aah.Date >= @StartDate AND aah.Date <= @EndDate
	AND (ra.AffiliateID= IIF(@AffiliateID = 0,ra.AffiliateID, @AffiliateID)) 
	AND aah.StatusID in(1,8,30,16,31) 

	--SELECT * FROM #TmpReportList

	SELECT X.APNO, X.Reason AS [PreAdverse Reason], X.[Description] AS [Component]
		INTO #tmpPreAdverse
	FROM Enterprise.[dbo].[vwAdverseActionReason] AS X 
	INNER JOIN #TmpReportList D(NOLOCK) ON X.APNO = D.ReportNumber
	WHERE X.RuleGroup = 'PreAdverse' 

	--SELECT * FROM #tmpPreAdverse t where t.APNO = 4685224

	SELECT X.APNO, X.Reason AS [Adverse Reason], X.[Description] AS [Component]
		INTO #tmpAdverse
	FROM Enterprise.[dbo].[vwAdverseActionReason] AS X 
	INNER JOIN #TmpReportList D(NOLOCK) ON X.APNO = D.ReportNumber
	WHERE X.RuleGroup = 'Adverse' 

	--SELECT * FROM #tmpAdverse t where t.APNO = 4685224 1163

	--select * from #tempViewAdverse where apno = 4234127
	--select * from #TmpReportList where ReportNumber = 4234127

	SELECT distinct tva.APNO AS [Report Number], trl.[Client ID],trl.[Client Name], trl.[Affiliate Name], trl.[Is OneHR], 
			trl.[Background Request Date],
			trl.[Original Completion Date],
			trl.[Final Background Report Date],
			trl.[Applicant Last Name], 
			trl.[Applicant First Name],
			tva.City AS [City Of Residence],
			tva.[State] AS [Applicant Resident State], 
			Q.StateEmploymentOccur AS [Job State],
			trl.[Requested by],
			isnull(CONVERT(VARCHAR, trl1.AdverseActionHistoryDate, 120),null)  AS [PreAdverse Requested],
			isnull(CONVERT(VARCHAR,trl3.AdverseActionHistoryDate, 120),null) AS [PreAdverse Emailed],
			(CASE
				WHEN trl1.AdverseActionStatusID = 1 AND trl3.AdverseActionStatusID = 30 THEN 'PreAdverse Requested and Emailed'
				WHEN trl3.AdverseActionStatusID = 30 THEN trl3.AdverseActionStatus  
				WHEN trl1.AdverseActionStatusID = 1 THEN  trl1.AdverseActionStatus
				ELSE NULL
			END) AS [PreAdverseActionStatus],
			X.[Component] AS [PreAdverse Component], 
			X.[PreAdverse Reason],
			isnull(CONVERT(VARCHAR,trl5.AdverseActionHistoryDate, 120),null) AS [Adverse Requested],
			isnull(CONVERT(VARCHAR,trl4.AdverseActionHistoryDate, 120),null) AS [Adverse Emailed],
			(CASE
				WHEN trl5.AdverseActionStatusID = 16 AND trl4.AdverseActionStatusID = 31 THEN 'Adverse Requested and Emailed'   
				WHEN trl4.AdverseActionStatusID = 31 THEN trl4.AdverseActionStatus   
				WHEN trl5.AdverseActionStatusID = 16 THEN trl5.AdverseActionStatus 
				ELSE NULL
			END) AS [AdverseActionStatus],
			Y.[Component] AS [Adverse Component],
			Y.[Adverse Reason],
			isnull(CONVERT(VARCHAR,trl2.AdverseActionHistoryDate, 120),null) AS  [Applicant Dispute Date],
			trl.[Private Notes] AS [Private Notes]
	FROM #tempViewAdverse tva
	LEFT OUTER JOIN #tmpPreAdverse AS X ON tva.APNO = X.APNO
	LEFT OUTER JOIN #tmpAdverse AS Y ON tva.APNO = Y.APNO
	LEFT OUTER JOIN PRECHECK.dbo.ApplAdditionalData Q(NOLOCK) ON tva.APNO = Q.APNO AND Q.StateEmploymentOccur IS NOT NULL
	INNER JOIN  #TmpReportList trl ON tva.APNO =trl.ReportNumber 
	LEFT JOIN (select * from #TmpReportList where AdverseActionStatusID = 1) trl1 ON tva.APNO =trl1.ReportNumber 
	LEFT JOIN (select * from #TmpReportList where AdverseActionStatusID = 8) trl2 ON tva.APNO =trl2.ReportNumber 
	LEFT JOIN (select * from #TmpReportList where AdverseActionStatusID = 30) trl3 ON tva.APNO =trl3.ReportNumber 
	LEFT JOIN (select * from #TmpReportList where AdverseActionStatusID = 31) trl4 ON tva.APNO =trl4.ReportNumber 
	LEFT JOIN (select * from #TmpReportList where AdverseActionStatusID = 16) trl5 ON tva.APNO =trl5.ReportNumber 		
		
	SET NOCOUNT OFF
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED

END

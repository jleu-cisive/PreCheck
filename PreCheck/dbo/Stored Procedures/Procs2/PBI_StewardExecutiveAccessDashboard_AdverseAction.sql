-- =============================================
/*
-- Author      : Vairavan  A
-- Create date : 11/22/2022
-- Description : To get data for Applications dataset of StewardExecutiveAccessDashboard Power Bi report
EXEC [PBI_StewardExecutiveAccessDashboard_AdverseAction] 2019,228,15382 --30sec
*/
-- =============================================
CREATE PROCEDURE dbo.PBI_StewardExecutiveAccessDashboard_AdverseAction
-- Add the parameters for the stored procedure here
@Year int,
@AffiliateID int,
@weborderparentclno smallint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	SET NOCOUNT ON;
	
WITH cteAdverseHistory AS
(
	SELECT va.*   
	FROM [dbo].[vwAdverseHistory] va with(nolock)
	INNER JOIN APPl a  with(nolock) on va.APNO = a.APNO
	INNER JOIN Client c  with(nolock) on a.CLNO = c.CLNO
	WHERE c.AffiliateID IN (@AffiliateID)--(228)
	AND c.weborderparentclno = @weborderparentclno--15382 
	and Year(a.OrigCompDate) >= @Year--2019
), 
cteReportList AS
(
	SELECT	distinct a.apno, c.CLNO AS [ClientID], c.Name AS [ClientName],ra.Affiliate AS [AffiliateName], f.IsOneHR AS [IsOneHR], a.Last AS [Applicant LastName],
			a.First AS [Applicant FirstName],aa.ClientEmail AS [RequestedBy], aah.StatusID AS AdverseActionStatusID, 
			ras.Status AS [AdverseActionStatus], aah.[Date] AS AdverseActionHistoryDate,
			ras.Status, A.APDATE, A.CompDate, a.OrigCompDate 
	FROM appl a with(nolock)		
	LEFT OUTER JOIN HEVN.dbo.Facility F with(NOLOCK) ON a.clno =FacilityCLNO and ISNULL(A.DeptCode,0) = F.FacilityNum
	LEFT OUTER JOIN client c with(nolock) ON a.CLNO = c.CLNO
	LEFT OUTER JOIN AdverseAction aa with(nolock) ON a.APNO = aa.APNO
	LEFT OUTER JOIN AdverseActionHistory aah with(nolock) ON aa.AdverseActionID = aah.AdverseActionID
	LEFT OUTER JOIN refAffiliate ra with(nolock) ON c.AffiliateID = ra.AffiliateID
	LEFT OUTER JOIN refAdverseStatus ras  with(nolock) ON aah.StatusID = ras.refAdverseStatusID 
	WHERE c.weborderparentclno = @weborderparentclno--15382
	AND aah.StatusID in(1,8,30,16,31)
), 
ctePreAdverse AS
(
	SELECT X.APNO, X.Reason AS [PreAdverse Reason], X.[Description] AS [Component]		
	FROM Enterprise.[dbo].[vwAdverseActionReason]  AS X  with(NOLOCK)
	INNER JOIN cteReportList D  ON X.APNO = D.APNO
	WHERE X.RuleGroup = 'PreAdverse' 
),
cteAdverse AS
(
	SELECT X.APNO, X.Reason AS [Adverse Reason], X.[Description] AS [Component]
	FROM Enterprise.[dbo].[vwAdverseActionReason] AS X  with(NOLOCK)
	INNER JOIN cteReportList D ON X.APNO = D.APNO
	WHERE X.RuleGroup = 'Adverse' 
),
cteAdverseActivity AS	
(
	SELECT distinct tva.APNO, trl.[ClientID],trl.[ClientName], trl.[AffiliateName], trl.[IsOneHR], 
			trl.Apdate,
			trl.OrigCompDate,
			trl.CompDate,
			trl.[Applicant LastName], 
			trl.[Applicant FirstName],
			tva.City AS [CityofResidence],
			tva.[State] AS [ApplicantResidentState], 
			Q.StateEmploymentOccur AS [JobState],
			trl.[RequestedBy],
			trl1.AdverseActionHistoryDate  AS [PreAdverse Requested],
			trl3.AdverseActionHistoryDate AS [PreAdverse Emailed],
			(CASE
				WHEN trl1.AdverseActionStatusID = 1 AND trl3.AdverseActionStatusID = 30 THEN 'PreAdverse Requested and Emailed'
				WHEN trl3.AdverseActionStatusID = 30 THEN trl3.AdverseActionStatus  
				WHEN trl1.AdverseActionStatusID = 1 THEN  trl1.AdverseActionStatus
				ELSE NULL
			END) AS [PreAdverseActionStatus],
			X.[Component] AS [PreAdverse Component], 
			X.[PreAdverse Reason],
			trl5.AdverseActionHistoryDate AS [Adverse Requested],
			trl4.AdverseActionHistoryDate AS [Adverse Emailed],
			(CASE
				WHEN trl5.AdverseActionStatusID = 16 AND trl4.AdverseActionStatusID = 31 THEN 'Adverse Requested and Emailed'   
				WHEN trl4.AdverseActionStatusID = 31 THEN trl4.AdverseActionStatus   
				WHEN trl5.AdverseActionStatusID = 16 THEN trl5.AdverseActionStatus 
				ELSE NULL
			END) AS [AdverseActionStatus],
			Y.[Component] AS [Adverse Component],
			Y.[Adverse Reason],
			trl2.AdverseActionHistoryDate AS  [Applicant Dispute Date]
	FROM cteAdverseHistory tva
	LEFT OUTER JOIN ctePreAdverse AS X ON tva.APNO = X.APNO
	LEFT OUTER JOIN cteAdverse AS Y ON tva.APNO = Y.APNO
	LEFT OUTER JOIN PRECHECK.dbo.ApplAdditionalData Q with(NOLOCK) ON tva.APNO = Q.APNO AND Q.StateEmploymentOccur IS NOT NULL
	INNER JOIN  cteReportList trl ON tva.APNO =trl.APNO 
	LEFT JOIN (select * from cteReportList where AdverseActionStatusID = 1) trl1 ON tva.APNO =trl1.APNO 
	LEFT JOIN (select * from cteReportList where AdverseActionStatusID = 8) trl2 ON tva.APNO =trl2.APNO 
	LEFT JOIN (select * from cteReportList where AdverseActionStatusID = 30) trl3 ON tva.APNO =trl3.APNO 
	LEFT JOIN (select * from cteReportList where AdverseActionStatusID = 31) trl4 ON tva.APNO =trl4.APNO 
	LEFT JOIN (select * from cteReportList where AdverseActionStatusID = 16) trl5 ON tva.APNO =trl5.APNO
)
SELECT * FROM cteAdverseActivity
    

    
END


-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 04/21/2020
-- Description:	CIC Client Experience TAT Detail with HR Review
-- EXEC CIC_ClientExperience_TATDetail_with_HR_Review '01/01/2020', '06/10/2020',0,4,0
-- Modified by Radhika on 09/01/2020 to add refAffiliate table and Client table.
--- Modified by Sahithi on 09/01/2020  for HDT :76964 to add new columns RequisitionNumber,[Last Request for Info Sent]
 /* Modified By: Vairavan A
-- Modified Date: 07/06/2022
-- Description: Ticketno-53763 
Modify existing q-reports that have affiliate ids in their search parameters
Details: 
Change search parameters for the Affiliate Id field
     * search by multiple affiliate ids (ex 4:297)
     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates
     * multiple affiliates to be separated by a colon  
Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0)

Child ticket id -54481 Update AffiliateID Parameters 971-1053
*/
---Testing
/*
EXEC [dbo].[CIC_ClientExperience_TATDetail_with_HR_Review]  '01/01/2020', '06/10/2020',0,'4',0
EXEC [dbo].[CIC_ClientExperience_TATDetail_with_HR_Review]  '01/01/2020', '06/10/2020',0,'0',0
EXEC [dbo].[CIC_ClientExperience_TATDetail_with_HR_Review]  '01/01/2020', '06/10/2020',0,'4:8',0
*/
-- =============================================
CREATE PROCEDURE [dbo].[CIC_ClientExperience_TATDetail_with_HR_Review]
@StartDate DATE,
@EndDate DATE,
@CLNO int,
--@AffiliateID int,--code commented by vairavan for ticket id -53763(54481)
@AffiliateIDs varchar(MAX) = '0',--code added by vairavan for ticket id -53763(54481)
@IsOneHR bit

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		--code added by vairavan for ticket id -53763 starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END
	--code added by vairavan for ticket id -53763 ends

	SELECT DISTINCT vc.ClientId AS [Client Number], vc.ClientName AS [Client Name],rf.Affiliate AS [Affiliate Name],
			a.APNO AS [Report Number], a.First as [Applicant First Name], a.Last as [Applicant Last Name],
			ISNULL(IAR.PartnerReferenceNumber, '') as RequisitionNumber,-- added for HDT :76964
			a.Attn as [Recruiter Name], o.BatchOrderDetailId,
			(CASE WHEN ISNULL(F.IsOneHR,0) = 0 THEN 'False' ELSE 'True' END) AS IsOneHR,
			FORMAT(Ag.CreateDate,'MM/dd/yyyy hh:mm:ss tt')  AS [Invite Sent],
			FORMAT(RRF.RequestDate,'MM/dd/yyyy hh:mm:ss tt')  AS [Invite Completed/HR Review Initiated],
			--FORMAT(RRF.RequestDate,'MM/dd/yyyy hh:mm:ss tt')  AS [HR Review Initiated],
			FORMAT(a.CreatedDate,'MM/dd/yyyy hh:mm:ss tt')  AS [HR Review Completed],
			FORMAT(cc.ClientCertUpdated ,'MM/dd/yyyy hh:mm:ss tt') AS [Certification Completed], 
			--FORMAT(a.CreatedDate,'MM/dd/yyyy hh:mm:ss tt')  AS [Received Date],
			FORMAT(a.OrigCompDate,'MM/dd/yyyy hh:mm:ss tt')  AS [Original Close Date],
			FORMAT(a.ReopenDate,'MM/dd/yyyy hh:mm:ss tt')  AS [ReOpen Date],
			FORMAT(a.CompDate,'MM/dd/yyyy hh:mm:ss tt')  AS [Completed Date],
			[dbo].[ElapsedBusinessDaysInDecimal](a.CreatedDate,a.OrigCompDate) AS [Report TAT],			
			[dbo].[ElapsedBusinessDaysInDecimal](Ag.CreateDate,a.OrigCompDate) AS [Invite to Original Close TAT – Without Reopen],
			[dbo].[ElapsedBusinessDaysInDecimal](Ag.CreateDate,a.CompDate) AS [Total Client TAT (Invite to Last Close Date)],
			[dbo].[ElapsedBusinessDaysInDecimal](Ag.CreateDate, RRF.RequestDate)AS [Candidate TAT for Consent Completion],
			--[dbo].[ElapsedBusinessDaysInDecimal](RRF.RequestDate,  RRF.RequestDate) AS[HR Review Initiation TAT],
			[dbo].[ElapsedBusinessDaysInDecimal](RRF.RequestDate, a.CreatedDate) AS [HR Review TAT],
			[dbo].[ElapsedBusinessDaysInDecimal](a.CreatedDate,cc.ClientCertUpdated)AS [Certification TAT],
			RRF.RequestCount AS [# of HR Review Cycles],
		   (case when RRF.RequestCount > 1 then rr.ModifyDate else null end)  as [Last Request for Info Sent]-- added for HDT :76964
	FROM Enterprise.PreCheck.vwClient AS vc  with(nolock) 
	INNER JOIN PreCheck.dbo.Appl AS a  with(nolock)  ON vc.ClientId = a.CLNO
	INNER JOIN Precheck.dbo.Client AS c  with(nolock) ON a.CLNO = c.CLNO
	INNER JOIN Precheck.dbo.refaffiliate AS rf  with(nolock) oN c.AffiliateId = rf.AffiliateId
	LEFT OUTER JOIN PreCheck.dbo.ClientCertification AS cc  with(nolock) ON a.APNO = cc.APNO AND CC.ClientCertReceived = 'Yes'
	INNER JOIN Enterprise.Staging.ApplicantStage Ag  with(nolock) ON a.APNO = Ag.ApplicantNumber
	INNER JOIN Enterprise.staging.Orderstage o  with(nolock) ON Ag.ApplicantNumber = o.OrderNumber and O.IsReviewRequired = 1
	LEFT OUTER JOIN Enterprise.dbo.vwReviewRequestFirst RRF  with(nolock) ON Ag.StagingApplicantId = RRF.StagingApplicantID
    LEFT JOIN HEVN.dbo.Facility F with(NOLOCK) ON ISNULL(A.DeptCode,0) = F.FacilityNum  and ISNULL(A.CLNO,0)=F.FacilityCLNO 
	LEFT JOIN Enterprise.PreCheck.[vwIntegrationApplicantReport]  IAR with(nolock) on IAR.RequestID = O.IntegrationRequestId -- added for HDT 76964
	LEFT OUTER JOIN Enterprise.Staging.ReviewRequest  RR with(nolock) ON RR.StagingApplicantId = Ag.StagingApplicantId-- added for HDT :76964
    LEFT OUTER JOIN Enterprise.Lookup.ReviewStatus RS with(nolock) ON RS.ReviewStatusId = RR.ClosingReviewStatusId -- added for HDT :76964
	WHERE CAST(a.CreatedDate as Date) BETWEEN @StartDate AND DATEADD(d,1,@EndDate)
              AND vc.ClientId = IIF(@CLNO=0, vc.ClientId, @CLNO) 
              --AND c.AffiliateId = IIF(@AffiliateID=0, c.AffiliateId, @AffiliateID) --code commented by vairavan for ticket id -53763(54481)
			  and (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763(54481)
			  AND o.BatchOrderDetailId IS NULL 
			  --AND a.APNO =5037904
			 -- AND a.APNO =5107733
			 --AND a.apno = 5105215
			 


END

-- =============================================
-- Author: Humera Ahmed
-- Create date: 08/11/2020
-- Description: Please schedule delivery of the CIC_Client_Experience_TAT_Detail_with_HR_Review Qreport for HCA.
-- The report should be delivered monthly on the 3rd of each month for the period of the First Date of the Prior Month to the Last Day of the Prior Month for Affiliate ID 4 with Is OneHR marked 1
---- Modified by Radhika on 09/01/2020 to add refAffiliate table and Client table.
--- Modified by Sahithi on 09/01/2020  for HDT :76964 to add new columns RequisitionNumber,[Last Request for Info Sent]
-- Modified by Humera Ahmed on 9/25/2020 for HDT: 77887 to replace , with a space to avoid data to move to a new column in CSV file.
--=============================================
CREATE PROCEDURE [dbo].[CIC_HCA_TAT_Detail_with_HR_Review_ClientSchedule]

AS
BEGIN
       -- SET NOCOUNT ON added to prevent extra result sets from
       -- interfering with SELECT statements.
       SET NOCOUNT ON;

  
       DECLARE
              @StartDate DATE= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0), --First day of previous month
              @EndDate DATE = DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-1, -1), --Last Day of previous month
              @CLNO int =7519,
              @AffiliateID int = 4,
              @IsOneHR bit = 1

       SELECT DISTINCT vc.ClientId AS [Client Number], vc.ClientName AS [Client Name],rf.Affiliate AS [Affiliate Name],
                     a.APNO AS [Report Number], a.First as [Applicant First Name], a.Last as [Applicant Last Name],
                                        ISNULL(IAR.PartnerReferenceNumber, '') as RequisitionNumber,-- added for HDT :76964
                     replace(a.Attn,',', '') as [Recruiter Name], o.BatchOrderDetailId,
                     (CASE WHEN ISNULL(F.IsOneHR,0) = 0 THEN 'False' ELSE 'True' END) AS IsOneHR,
                     FORMAT(Ag.CreateDate,'MM/dd/yyyy hh:mm:ss tt')  AS [Invite Sent],
                     FORMAT(RRF.RequestDate,'MM/dd/yyyy hh:mm:ss tt')  AS [Invite Completed/HR Review Initiated],
                     FORMAT(a.CreatedDate,'MM/dd/yyyy hh:mm:ss tt')  AS [HR Review Completed],
                     FORMAT(cc.ClientCertUpdated ,'MM/dd/yyyy hh:mm:ss tt') AS [Certification Completed], 
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
              FROM Enterprise.PreCheck.vwClient AS vc 
              INNER JOIN PreCheck.dbo.Appl AS a ON vc.ClientId = a.CLNO
              INNER JOIN Precheck.dbo.Client AS c ON a.CLNO = c.CLNO
              INNER JOIN Precheck.dbo.refaffiliate AS rf oN c.AffiliateId = rf.AffiliateId
              LEFT OUTER JOIN PreCheck.dbo.ClientCertification AS cc ON a.APNO = cc.APNO AND CC.ClientCertReceived = 'Yes'
              INNER JOIN Enterprise.Staging.ApplicantStage Ag ON a.APNO = Ag.ApplicantNumber
              INNER JOIN Enterprise.staging.Orderstage o ON Ag.ApplicantNumber = o.OrderNumber and O.IsReviewRequired = 1
              LEFT OUTER JOIN Enterprise.dbo.vwReviewRequestFirst RRF ON Ag.StagingApplicantId = RRF.StagingApplicantID
              LEFT JOIN HEVN.dbo.Facility F (NOLOCK) ON ISNULL(A.DeptCode,0) = F.FacilityNum  and ISNULL(A.CLNO,0)=F.FacilityCLNO 
              LEFT JOIN Enterprise.PreCheck.[vwIntegrationApplicantReport]  IAR with(nolock) on IAR.RequestID = O.IntegrationRequestId -- added for HDT 76964
              LEFT OUTER JOIN Enterprise.Staging.ReviewRequest  RR with(nolock) ON RR.StagingApplicantId = Ag.StagingApplicantId-- added for HDT :76964
              LEFT OUTER JOIN Enterprise.Lookup.ReviewStatus RS with(nolock) ON RS.ReviewStatusId = RR.ClosingReviewStatusId -- added for HDT :76964 
              WHERE CAST(a.CreatedDate as Date) BETWEEN @StartDate AND @EndDate
                       AND vc.ParentId = @CLNO  
                       AND vc.AffiliateId = @AffiliateID
                       AND o.BatchOrderDetailId IS NULL 
       ORDER BY [HR Review Completed]

END

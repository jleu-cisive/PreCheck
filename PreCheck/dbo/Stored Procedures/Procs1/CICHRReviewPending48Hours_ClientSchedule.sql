-- =============================================
-- Author:           Humera Ahmed
-- Create date: 8/14/2020
-- Description:      Please create a new sceduled report Called CIC HR Review Pending 48 Hours and schedule for morning and evening delivery to HCA.
-- This report should be based on the structure of the CIC Pending Invitations QReport but will only include the items that are Pending HR Review from the client for more than 48 hours.

-- Modified By Humera Ahmed on 8/31/2020 for HDT#76021 
--                  1. Not join the view - vwTokenStagingApplicantId in line #53. 
--                  2. Join token id with Applicant Stage table in line #55.
--                  3. In the Where condition add additional logic to check if Review process is not completed - line #73

 
-- Exec [dbo].[CICHRReviewPending48Hours_ClientSchedule] 
-- =============================================
CREATE PROCEDURE [dbo].[CICHRReviewPending48Hours_ClientSchedule] 
       -- Add the parameters for the stored procedure here
       @CLNO int = 7519     
AS
BEGIN
       -- SET NOCOUNT ON added to prevent extra result sets from
       -- interfering with SELECT statements.
       SET NOCOUNT ON;

    -- Insert statements for procedure here
       DECLARE
       @StartDate DATETIME = dateadd(day, -30, getdate()),
       @EndDate DATETIME = dateadd(day, +30, getdate())


       SELECT  
       A.StagingApplicantId,
       ParentCLNO=O.ClientId,
       FacilityCLNO=O.FacilityId,
       ApplicantId = ISNULL(A.ClientCandidateId,'0'),
       RequisitionNumber = ISNULL(IAR.PartnerReferenceNumber, ''),
       A.LastName,
       A.FirstName, 
       a.Email AS ApplicantEmail,
       A.Phone, 
       InviteSentOn=O.CreateDate, 
       T.[ExpireDate] AS [Link Expiration Date],
       LastActivity=a.ModifyDate, 
       Requestor =O.Attention,
       O.ReviewerEmail as [HR Review Email Address],
       O.IsReviewRequired AS [ReviewProcessEnabled],
       RS.DisplayName AS [ReviewStatus],
       RR.CreateDate [ReviewStartDate],
       Case when RS.ReviewStatusID = 2 THEN RRA.CreateDate ELSE Cast(NULL as datetime) END AS [RequestforInfoSent] 
       FROM Enterprise.Staging.OrderStage O with(nolock)
       INNER JOIN Enterprise.Staging.ApplicantStage A with(nolock) ON O.StagingOrderId=A.StagingOrderId
       --Left join Enterprise.[Security].[vwTokenStagingApplicantId] v on a.StagingApplicantId=v.StagingApplicantId 
       LEFT JOIN Enterprise.PreCheck.[vwIntegrationApplicantReport]  IAR with(nolock) on IAR.RequestID = O.IntegrationRequestId
       inner   JOIN SecureBridge.DBO.Token AS T ON A.SecurityTokenId = T.TokenId
       LEFT OUTER JOIN Enterprise.Staging.ReviewRequest  RR with(nolock) ON RR.StagingApplicantId = A.StagingApplicantId
       LEFT OUTER JOIN Enterprise.Lookup.ReviewStatus RS with(nolock) ON RS.ReviewStatusId = rr.ClosingReviewStatusId
       LEFT OUTER JOIN Enterprise.Staging.ReviewResponseAction RRA with(nolock) on RS.ReviewStatusId = RRA.ReviewStatusID and RR.ReviewRequestId  = RRA.ReviewRequestID
       WHERE 
              (((O.IsReviewRequired = 0 OR O.IsReviewRequired IS NULL) AND ISNULL(T.IsActive,1)=1)   OR O.IsReviewRequired = 1)
              AND ISNULL(A.IsConfirmed,0)=0
              and  O.DASourceId=2 
              AND O.Attention NOT LIKE '%precheck.com%' 
              AND A.Email NOT LIKE '%precheck.com%'
              AND o.ClientID  =  IIF(@CLNO=0,o.ClientID,@CLNO)  
              AND ISNULL(A.IsActive,1)=1 
              AND O.CreateDate>= @StartDate AND O.CreateDate<= DATEADD(d,1,@EndDate)
              AND O.IsReviewRequired = 1
              AND RR.ClosingReviewStatusId = 1
              AND RR.IsComplete = 0
              AND DATEDIFF(HOUR, RR.CreateDate, GETDATE()) > 48
              ORDER BY o.CreateDate DESC
END


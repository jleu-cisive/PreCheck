-- =============================================
-- Author:		Sahithi
-- Create date: 3/16/2020
-- Description:	HDT :69996, Creating Automated report for HCA , for CIC daily Candidate invitation requests.
-- The report displays all the CIC requests for the previous day .
-- =============================================
CREATE PROCEDURE [dbo].[CIC_DailyCandidate_InvitationRequest] 
	-- Add the parameters for the stored procedure here
 @CLNO Int 
AS
BEGIN
	
declare	@StartDate DATETIME =DATEADD(dd, DATEDIFF(dd, 0, GETDATE()) - 1, 0),
	@EndDate DATETIME = DATEADD(MINUTE, -1, DATEADD(dd, 0, DATEDIFF(dd, 0, GETDATE()))),
	@ExcludeMCIC BIT = 1
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   SELECT 
	ParentCLNO=O.ClientId,
	FacilityCLNO=O.FacilityId,
	ApplicantId = ISNULL(A.ClientCandidateId,0),
	RequisitionNumber = ISNULL(IAR.PartnerReferenceNumber, ''),
	A.LastName,
	A.FirstName, 
	a.Email AS ApplicantEmail,
	InviteSentOn=O.CreateDate, 
	T.[ExpireDate] AS [Link Expiration Date],
	LastActivity=a.ModifyDate, 
	Requestor =O.Attention
FROM Enterprise.Staging.OrderStage O with(nolock)
INNER JOIN Enterprise.Staging.ApplicantStage A with(nolock) ON O.StagingOrderId=A.StagingOrderId
LEFT JOIN Enterprise.PreCheck.[vwIntegrationApplicantReport]  IAR with(nolock) on IAR.RequestID = O.IntegrationRequestId
LEFT outer JOIN SecureBridge.DBO.Token AS T ON a.SecurityTokenId = T.TokenId
LEFT OUTER JOIN Enterprise.Staging.ReviewRequest  RR with(nolock) ON RR.StagingApplicantId = A.StagingApplicantId
LEFT OUTER JOIN Enterprise.Lookup.ReviewStatus RS with(nolock) ON RS.ReviewStatusId = rr.ClosingReviewStatusId
LEFT OUTER JOIN Enterprise.Staging.ReviewResponseAction RRA with(nolock) on RS.ReviewStatusId = RRA.ReviewStatusID and RR.ReviewRequestId  = RRA.ReviewRequestID
WHERE 	
	(((O.IsReviewRequired = 0 OR O.IsReviewRequired IS NULL) AND ISNULL(T.IsActive,1)=1)   OR O.IsReviewRequired = 1)
	AND ISNULL(A.IsConfirmed,0)=0 
	AND O.Attention NOT LIKE '%precheck.com%' 
	AND A.Email NOT LIKE '%precheck.com%'
	AND o.ClientID  = IIF(@CLNO=0,o.ClientID,@CLNO)  -- Added by Radhika Dereddy on 08/20/2019
	AND ISNULL(A.IsActive,1)=1	
	AND O.CreateDate>=@StartDate AND O.CreateDate<= @EndDate
	AND ISNULL(O.BatchOrderDetailId,0) = CASE WHEN @ExcludeMCIC=1 THEN 0 ELSE ISNULL(O.BatchOrderDetailId,0) END

	ORDER BY o.CreateDate desc
END

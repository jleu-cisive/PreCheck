-- =============================================
-- Author:		Humera Ahmed
-- Create date: 10/6/2020
-- Description:	For HDT #75956 CIC Peninding Invitations Report- 16296, 16368, 16369
-- EXEC [dbo].[CIC_PendingInvitations_ScheduledReport] 
-- =============================================
CREATE PROCEDURE [dbo].[CIC_PendingInvitations_ScheduledReport] 
-- Add the parameters for the stored procedure here
	 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
	declare @PreviousDay DATETIME = cast(getdate()-1 AS date)
	SELECT  
		FacilityCLNO=O.FacilityId,
		A.LastName,
		A.FirstName, 
		a.Email AS ApplicantEmail,
		InviteSentOn=O.CreateDate, 
		T.[ExpireDate] AS [Link Expiration Date],
		LastActivity=a.ModifyDate, 
		Requestor =O.Attention
	FROM Enterprise.Staging.OrderStage O with(nolock)
	INNER JOIN Enterprise.Staging.ApplicantStage A with(nolock) ON O.StagingOrderId=A.StagingOrderId
	Left join Enterprise.[Security].[vwTokenStagingApplicantId] v on a.StagingApplicantId=v.StagingApplicantId --- added by sahithi
	LEFT JOIN Enterprise.PreCheck.[vwIntegrationApplicantReport]  IAR with(nolock) on IAR.RequestID = O.IntegrationRequestId
	inner   JOIN SecureBridge.DBO.Token AS T ON v.tokenid = T.TokenId
	LEFT OUTER JOIN Enterprise.Staging.ReviewRequest  RR with(nolock) ON RR.StagingApplicantId = A.StagingApplicantId
	LEFT OUTER JOIN Enterprise.Lookup.ReviewStatus RS with(nolock) ON RS.ReviewStatusId = rr.ClosingReviewStatusId
	LEFT OUTER JOIN Enterprise.Staging.ReviewResponseAction RRA with(nolock) on RS.ReviewStatusId = RRA.ReviewStatusID and RR.ReviewRequestId  = RRA.ReviewRequestID
	WHERE 	
		(((O.IsReviewRequired = 0 OR O.IsReviewRequired IS NULL) AND ISNULL(T.IsActive,1)=1)   OR O.IsReviewRequired = 1)
		AND ISNULL(A.IsConfirmed,0)=0
		and  O.DASourceId=2 
		AND O.Attention NOT LIKE '%precheck.com%' 
		AND A.Email NOT LIKE '%precheck.com%'
		AND o.ClientID  = 15256 
		AND O.FacilityId IN (16296,16368,16369)
		AND ISNULL(A.IsActive,1)=1
		AND cast(O.CreateDate AS date)=@PreviousDay	
	ORDER BY o.CreateDate desc

End

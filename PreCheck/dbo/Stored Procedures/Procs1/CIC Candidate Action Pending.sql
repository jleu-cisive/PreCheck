-- =============================================
-- Author:		Humera Ahmed
-- Create date: 2/19/2020                                                                                                                                                                                                           
-- Description: Moved From Precheck database to Enterprise	HDT# - 67659 Please add the following fields from the CIC Order information QReport to the the CIC Pending Invitations QReport:Job Title, Job State, Salary Range, Service Package Instructions, Additional Components
-- EXEC [dbo].[CIC_Pending_CandidateInvitations] 7519,'03/01/2020','04/06/2020',0
-- Modified by Radhika Dereddy on 02/25/2020 to add RequestforInfoSent.
-- Author:		Sahithi
-- Create date: 3/30/2020
-- Description: Moved From Precheck database to Enterprise	HDT# - 67659 Please add the following fields from the CIC Order information QReport to the the CIC Pending Invitations QReport:Job Title, Job State, Salary Range, Service Package Instructions, Additional Components
-- EXEC [dbo].[CIC_Pending_CandidateInvitations] 7519,'02/01/2020','03/28/2020',0
-- EXEC [dbo].[CIC Candidate Action Pending] 7519,'04/20/2020'
-- Modified by Radhika Dereddy on 02/25/2020 to add RequestforInfoSent.
-- =============================================
CREATE PROCEDURE [dbo].[CIC Candidate Action Pending]
	-- Add the parameters for the stored procedure here
	@CLNO Int = 0,
	@StartDate DATETIME=null,
	@EndDate DATETIME = NULL,
	@ExcludeMCIC BIT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF(@EndDate IS NULL)
		SET @EndDate = GETDATE()

    -- Insert statements for procedure here
	SELECT  
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
	--CandidateLink=CASE WHEN t.ExpireDate>GETDATE() then CONCAT('https://candidate.precheck.com/CIC/Authenticate?token=',CONVERT(VARCHAR(100),ISNULL(v.TokenId,''))) ELSE '' end,
	CandidateLink=CONCAT('https://candidate.precheck.com/CIC/Authenticate?token=',CONVERT(VARCHAR(100),ISNULL(v.TokenId,''))),
	O.IsReviewRequired AS [ReviewProcessEnabled],
	ISNull(RS.DisplayName,'Pending Invitation') AS [ReviewStatus],
	Case when RS.ReviewStatusID = 2 THEN RRA.CreateDate ELSE Cast(NULL as datetime) END AS [RequestforInfoSent]
	--RS.ReviewStatusId
	--rs.SystemName as [Action],
	--a.StagingApplicantId 
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
	and  O.DASourceId=2 -- added by sahithi 
	--and a.ClientCandidateId <>'0'
	AND O.Attention NOT LIKE '%precheck.com%' 
	AND A.Email NOT LIKE '%precheck.com%'
	AND o.ClientID  = IIF(@CLNO=0,o.ClientID,@CLNO)  -- Added by Radhika Dereddy on 08/20/2019
	AND ISNULL(A.IsActive,1)=1	
	and cast(T.[ExpireDate] as date) > DATEADD(d,-7,GETDATE()) -- within 7 days of expiration date
	--AND O.CreateDate>=@StartDate AND O.CreateDate<= DATEADD(d,1,@EndDate)
	AND ISNULL(O.BatchOrderDetailId,0) = CASE WHEN @ExcludeMCIC=1 THEN 0 ELSE ISNULL(O.BatchOrderDetailId,0) END
	and IsNull(RS.ReviewStatusId,0) not in (1,3,4,5)
	--AND o.BatchOrderDetailId IS null
	
	ORDER BY o.CreateDate desc
END

--select * from Enterprise.Lookup.ReviewStatus
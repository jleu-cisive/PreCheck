
-- =============================================
-- Author: Arshan Gouri
-- Create date: 01-25-2024
-- Description:	 Gets HR Review link for the client when searched by Client Candidate Id or Name
-- EXEC [ClientAccess_Get_HRReviewList] 7519,'','arshantest','gouritest'
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_Get_HRReviewList]
	@CLNO INT=NULL,
	@ClientCandidateId varchar(9)=NULL,
	@FirstName varchar(20)=NULL,
	@LastName varchar(20)=NULL
	
As
Begin
IF @ClientCandidateId IS NOT NULL AND @ClientCandidateId<>''
	BEGIN
		SELECT  ParentCLNO=O.ClientId,
		FacilityCLNO=O.FacilityId,
		ClientCandidateId = ISNULL(A.ClientCandidateId,'0'),
		A.LastName,
		A.FirstName, 
		a.Email AS ApplicantEmail,
		A.Phone, 
		InviteSentOn=O.CreateDate, 
		T.[ExpireDate] AS [Link Expiration Date],
		LastActivity=a.ModifyDate, 
		Requestor =O.Attention,
		O.ReviewerEmail as [HR Review Email Address],
        HRReviewLink = CONCAT('https://candidate.precheck.com/ReviewProcess/Authenticate?token=',ISNULL(CAST(RR.SecurityTokenID AS NVARCHAR(50)),'')),
		O.IsReviewRequired AS [ReviewProcessEnabled],
		RS.DisplayName AS [ReviewStatus],
		Case when RS.ReviewStatusID = 2 THEN RRA.CreateDate ELSE Cast(NULL as datetime) END AS [RequestforInfoSent]	,
		RR.SecurityTokenID, RR.StagingApplicantId
FROM Enterprise.Staging.OrderStage O with(nolock)
	INNER JOIN Enterprise.Staging.ApplicantStage A with(nolock) ON O.StagingOrderId=A.StagingOrderId
	Left join Enterprise.[Security].[vwTokenStagingApplicantId] v on a.StagingApplicantId=v.StagingApplicantId
	LEFT OUTER JOIN Enterprise.Staging.ReviewRequest  RR with(nolock) ON RR.StagingApplicantId = A.StagingApplicantId
	LEFT OUTER JOIN Enterprise.Lookup.ReviewStatus RS with(nolock) ON RS.ReviewStatusId = rr.ClosingReviewStatusId
	LEFT OUTER JOIN Enterprise.Staging.ReviewResponseAction RRA with(nolock) on RS.ReviewStatusId = RRA.ReviewStatusID and RR.ReviewRequestId  = RRA.ReviewRequestID
	INNER  JOIN SecureBridge.DBO.Token AS T ON RR.SecurityTokenId = T.TokenId
	WHERE 	
	ISNULL(A.IsConfirmed,0)=0
	AND  O.DASourceId=2
	AND ClientCandidateId =@ClientCandidateId
	--AND O.Attention NOT LIKE '%precheck.com%' 
	--AND A.Email NOT LIKE '%precheck.com%'
	AND O.ClientId=@CLNO
	AND ISNULL(A.IsActive,1)=1	
	AND RR.StagingApplicantId IS NOT NULL
	ORDER BY o.CreateDate desc
   END
  ELSE
  	BEGIN
		SELECT  ParentCLNO=O.ClientId,
		FacilityCLNO=O.FacilityId,
		ClientCandidateId = ISNULL(A.ClientCandidateId,'0'),
		A.LastName,
		A.FirstName, 
		a.Email AS ApplicantEmail,
		A.Phone, 
		InviteSentOn=O.CreateDate, 
		T.[ExpireDate] AS [Link Expiration Date],
		LastActivity=a.ModifyDate, 
		Requestor =O.Attention,
		O.ReviewerEmail as [HR Review Email Address],
		HRReviewLink = CONCAT('https://candidate.precheck.com/ReviewProcess/Authenticate?token=',ISNULL(CAST(RR.SecurityTokenID AS NVARCHAR(50)),'')),
		O.IsReviewRequired AS [ReviewProcessEnabled],
		RS.DisplayName AS [ReviewStatus],
		Case when RS.ReviewStatusID = 2 THEN RRA.CreateDate ELSE Cast(NULL as datetime) END AS [RequestforInfoSent]	
FROM Enterprise.Staging.OrderStage O with(nolock)
	INNER JOIN Enterprise.Staging.ApplicantStage A with(nolock) ON O.StagingOrderId=A.StagingOrderId
	Left join Enterprise.[Security].[vwTokenStagingApplicantId] v on a.StagingApplicantId=v.StagingApplicantId
	LEFT OUTER JOIN Enterprise.Staging.ReviewRequest  RR with(nolock) ON RR.StagingApplicantId = A.StagingApplicantId
	LEFT OUTER JOIN Enterprise.Lookup.ReviewStatus RS with(nolock) ON RS.ReviewStatusId = rr.ClosingReviewStatusId
	LEFT OUTER JOIN Enterprise.Staging.ReviewResponseAction RRA with(nolock) on RS.ReviewStatusId = RRA.ReviewStatusID and RR.ReviewRequestId  = RRA.ReviewRequestID
	INNER  JOIN SecureBridge.DBO.Token AS T ON RR.SecurityTokenId = T.TokenId

	WHERE 	 
	ISNULL(A.IsConfirmed,0)=0
	AND  O.DASourceId=2
	AND A.LastName =@LastName
	AND A.FirstName=@FirstName
	--AND O.Attention NOT LIKE '%precheck.com%' 
	--AND A.Email NOT LIKE '%precheck.com%'
	AND O.ClientId=@CLNO
	AND ISNULL(A.IsActive,1)=1	
	AND RR.StagingApplicantId IS NOT NULL
	ORDER BY o.CreateDate desc
   END
SET ANSI_NULLS ON



END

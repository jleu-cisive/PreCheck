
-- =============================================
-- Author: Arshan Gouri
-- Create date: 01-25-2024
-- Description:	 Gets candidate info when searched by Client Candidate ID or Name
-- EXEC [ClientAccess_Get_CandidateNotificationList] 2135,'80010893'
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_Get_CandidateNotificationList]
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
		RequisitionNumber = ISNULL(IAR.PartnerReferenceNumber, ''),
		A.LastName,
		A.FirstName, 
		C.ClientName,
		a.Email AS ApplicantEmail,
		A.Phone, 
		InviteSentOn=O.CreateDate, 
		T.[ExpireDate] AS LinkExpirationDate,
		LastActivity=a.ModifyDate, 
		Requestor =O.Attention,
		O.ReviewerEmail as [HR Review Email Address],
		CandidateLink=--CASE WHEN t.ExpireDate>GETDATE() then 
		CONCAT('https://candidate.precheck.com/CIC/Authenticate?token=',CONVERT (VARCHAR(100),ISNULL(v.TokenId,'')))-- ELSE '' end
		,
		O.IsReviewRequired AS [ReviewProcessEnabled],
		RS.DisplayName AS [ReviewStatus],
		Case when RS.ReviewStatusID = 2 THEN RRA.CreateDate ELSE Cast(NULL as datetime) END AS [RequestforInfoSent]	
FROM Enterprise.Staging.OrderStage O with(nolock)
	INNER JOIN Enterprise.Staging.ApplicantStage A with(nolock) ON O.StagingOrderId=A.StagingOrderId
	Left join Enterprise.[Security].[vwTokenStagingApplicantId] v on a.StagingApplicantId=v.StagingApplicantId
	LEFT JOIN Enterprise.PreCheck.[vwIntegrationApplicantReport]  IAR with(nolock) on IAR.RequestID = O.IntegrationRequestId
	INNER   JOIN SecureBridge.DBO.Token AS T ON v.tokenid = T.TokenId
	LEFT OUTER JOIN Enterprise.Staging.ReviewRequest  RR with(nolock) ON RR.StagingApplicantId = A.StagingApplicantId
	LEFT OUTER JOIN Enterprise.Lookup.ReviewStatus RS with(nolock) ON RS.ReviewStatusId = rr.ClosingReviewStatusId
	LEFT OUTER JOIN Enterprise.Staging.ReviewResponseAction RRA with(nolock) on RS.ReviewStatusId = RRA.ReviewStatusID and RR.ReviewRequestId  = RRA.ReviewRequestID
	INNER JOIN [Precheck]..vwClient	C
	ON O.FacilityId=C.ClientId
	WHERE 	
	(((O.IsReviewRequired = 0 OR O.IsReviewRequired IS NULL) AND ISNULL(T.IsActive,1)=1)   OR O.IsReviewRequired = 1)
	AND ISNULL(A.IsConfirmed,0)=0
	and  O.DASourceId=2
	--and a.ClientCandidateId <>'0'
	AND ClientCandidateId =@ClientCandidateId
	--AND O.Attention NOT LIKE '%precheck.com%' 
	--AND A.Email NOT LIKE '%precheck.com%'
	AND O.ClientId=@CLNO
	AND ISNULL(A.IsActive,1)=1	
	ORDER BY o.CreateDate desc
   END
  ELSE
  	BEGIN
		SELECT  ParentCLNO=O.ClientId,
		FacilityCLNO=O.FacilityId,
		ClientCandidateId = ISNULL(A.ClientCandidateId,'0'),
		RequisitionNumber = ISNULL(IAR.PartnerReferenceNumber, ''),
		A.LastName,
		A.FirstName, 
		C.ClientName,
		a.Email AS ApplicantEmail,
		A.Phone, 
		InviteSentOn=O.CreateDate, 
		T.[ExpireDate] AS LinkExpirationDate,
		LastActivity=a.ModifyDate, 
		Requestor =O.Attention,
		O.ReviewerEmail as [HR Review Email Address],
		CandidateLink=--CASE WHEN t.ExpireDate>GETDATE() then
		CONCAT('https://candidate.precheck.com/CIC/Authenticate?token=',CONVERT (VARCHAR(100),ISNULL(v.TokenId,''))) --ELSE '' end
		,
		O.IsReviewRequired AS [ReviewProcessEnabled],
		RS.DisplayName AS [ReviewStatus],
		Case when RS.ReviewStatusID = 2 THEN RRA.CreateDate ELSE Cast(NULL as datetime) END AS [RequestforInfoSent]	
FROM Enterprise.Staging.OrderStage O with(nolock)
	INNER JOIN Enterprise.Staging.ApplicantStage A with(nolock) ON O.StagingOrderId=A.StagingOrderId
	Left join Enterprise.[Security].[vwTokenStagingApplicantId] v on a.StagingApplicantId=v.StagingApplicantId
	LEFT JOIN Enterprise.PreCheck.[vwIntegrationApplicantReport]  IAR with(nolock) on IAR.RequestID = O.IntegrationRequestId
	INNER   JOIN SecureBridge.DBO.Token AS T ON v.tokenid = T.TokenId
	LEFT OUTER JOIN Enterprise.Staging.ReviewRequest  RR with(nolock) ON RR.StagingApplicantId = A.StagingApplicantId
	LEFT OUTER JOIN Enterprise.Lookup.ReviewStatus RS with(nolock) ON RS.ReviewStatusId = rr.ClosingReviewStatusId
	LEFT OUTER JOIN Enterprise.Staging.ReviewResponseAction RRA with(nolock) on RS.ReviewStatusId = RRA.ReviewStatusID and RR.ReviewRequestId  = RRA.ReviewRequestID
	INNER JOIN [Precheck]..vwClient	C
	ON O.FacilityId=C.ClientId
	WHERE 	
	(((O.IsReviewRequired = 0 OR O.IsReviewRequired IS NULL) AND ISNULL(T.IsActive,1)=1)   OR O.IsReviewRequired = 1)
	AND ISNULL(A.IsConfirmed,0)=0
	and  O.DASourceId=2
	--and a.ClientCandidateId <>'0'
	AND A.LastName =@LastName
	AND A.FirstName=@FirstName
	--AND O.Attention NOT LIKE '%precheck.com%' 
	--AND A.Email NOT LIKE '%precheck.com%'
	AND O.ClientId=@CLNO
	AND ISNULL(A.IsActive,1)=1	
	ORDER BY o.CreateDate desc
   END
SET ANSI_NULLS ON



END

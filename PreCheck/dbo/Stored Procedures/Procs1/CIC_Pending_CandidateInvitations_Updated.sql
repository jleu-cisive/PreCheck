-- =============================================  
-- Author:  Sahithi  
-- Create date: 3/30/2020  
-- Description: Moved From Precheck database to Enterprise HDT# - 67659 Please add the following fields from the CIC Order information QReport to the the CIC Pending Invitations QReport:Job Title, Job State, Salary Range, Service Package Instructions, Additional Components  
-- EXEC [dbo].[CIC_Pending_CandidateInvitations] 1814,'02/01/2020','03/28/2020',0  
-- Modified by Radhika Dereddy on 02/25/2020 to add RequestforInfoSent.  
-- Modified by Humera Ahmed on 07/24/2020 for HDT#75171 - Add HR Review Email Address as a field. It should be inserted between the Requestor and Candidate Link fields.  
-- Modified by Mainak Bhadra on 10/12/2022 to add AffiliateId for ticket #67224
-- EXEC [dbo].[CIC_Pending_CandidateInvitations_Updated] 0,'01/01/2019','06/02/2022',0 ,'10:4' 
-- =============================================  
CREATE PROCEDURE [dbo].[CIC_Pending_CandidateInvitations_Updated]  
 -- Add the parameters for the stored procedure here  
 @CLNO Int = 0,  
 @StartDate DATETIME ,  
 @EndDate DATETIME = NULL,  
 @ExcludeMCIC BIT = 1 ,
 @AffiliateId varchar(MAX) = '0'--code added by Mainak for ticket id -67224
AS  

BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
 IF(@EndDate IS NULL)  
  SET @EndDate = GETDATE()  
  
  --code added by Mainak for ticket id -67224 starts
	IF @AffiliateId = '0' 
	BEGIN  
		SET @AffiliateId = NULL  
	END
	--code added by Mainak for ticket id -67224 ends

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
 O.ReviewerEmail as [HR Review Email Address],  
 CONCAT('https://candidate.precheck.com/CIC/Authenticate?token=',a.SecurityTokenId) AS CandidateLink,  
 --a.SecurityTokenId as CandidateLink,  
 O.IsReviewRequired AS [ReviewProcessEnabled],  
 RS.DisplayName AS [ReviewStatus],  
 Case when RS.ReviewStatusID = 2 THEN RRA.CreateDate ELSE Cast(NULL as datetime) END AS [RequestforInfoSent]   
FROM Enterprise.Staging.OrderStage O with(nolock)  
inner JOIN Enterprise.Staging.ApplicantStage A with(nolock) ON O.StagingOrderId=A.StagingOrderId  
Left join Enterprise.[Security].[vwTokenStagingApplicantId] v on a.StagingApplicantId=v.StagingApplicantId  
LEFT JOIN Enterprise.PreCheck.[vwIntegrationApplicantReport]  IAR with(nolock) on IAR.RequestID = O.IntegrationRequestId  
inner   JOIN SecureBridge.DBO.Token AS T ON v.tokenid = T.TokenId  
LEFT OUTER JOIN Enterprise.Staging.ReviewRequest  RR with(nolock) ON RR.StagingApplicantId = A.StagingApplicantId  
LEFT OUTER JOIN Enterprise.Lookup.ReviewStatus RS with(nolock) ON RS.ReviewStatusId = rr.ClosingReviewStatusId  
LEFT OUTER JOIN Enterprise.Staging.ReviewResponseAction RRA with(nolock) on RS.ReviewStatusId = RRA.ReviewStatusID and RR.ReviewRequestId  = RRA.ReviewRequestID
INNER JOIN dbo.Client C(NOLOCK) on C.CLNO = o.ClientID   --code added by Mainak for ticket id -67224
INNER JOIN refAffiliate RA(NOLOCK) on RA.AffiliateID = C.AffiliateID --code added by Mainak for ticket id -67224
WHERE    
 (((O.IsReviewRequired = 0 OR O.IsReviewRequired IS NULL) AND ISNULL(T.IsActive,1)=1)   OR O.IsReviewRequired = 1)  
 AND ISNULL(A.IsConfirmed,0)=0  
 and  O.DASourceId=2   
 --and a.ClientCandidateId <>'0'  
 AND O.Attention NOT LIKE '%precheck.com%'   
 AND A.Email NOT LIKE '%precheck.com%'  
 AND o.ClientID  = IIF(@CLNO=0,o.ClientID,@CLNO)  -- Added by Radhika Dereddy on 08/20/2019  
 AND ISNULL(A.IsActive,1)=1   
 and cast(T.[ExpireDate] as date) > cast (getdate() as date)  
 AND O.CreateDate>=@StartDate AND O.CreateDate<= DATEADD(d,1,@EndDate)  
 AND ISNULL(O.BatchOrderDetailId,0) = CASE WHEN @ExcludeMCIC=1 THEN 0 ELSE ISNULL(O.BatchOrderDetailId,0) END  
 --AND o.BatchOrderDetailId IS null  
 AND (@AffiliateId IS NULL OR RA.AffiliateId IN (SELECT value FROM fn_Split(@AffiliateId,':')))--code added by Mainak for ticket id -67224
 ORDER BY o.CreateDate desc  
END
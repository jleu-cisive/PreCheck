--Use Precheck;
-- =============================================  
-- Author:  Humera Ahmed  
-- Create date: 2/19/2020                                                                                                                                                                                                             
-- Description: Moved From Precheck database to Enterprise HDT# - 67659 Please add the following fields from the CIC Order information QReport to the the CIC Pending Invitations QReport:Job Title, Job State, Salary Range, Service Package Instructions, Additional Components  
-- EXEC [dbo].[CIC_Pending_CandidateInvitations] 7519,'03/01/2020','04/06/2020',0  
-- Modified by Radhika Dereddy on 02/25/2020 to add RequestforInfoSent.  
-- Author:  Sahithi  
-- Create date: 3/30/2020  
-- Description: Moved From Precheck database to Enterprise HDT# - 67659 Please add the following fields from the CIC Order information QReport to the the CIC Pending Invitations QReport:Job Title, Job State, Salary Range, Service Package Instructions, Additional Components  
-- EXEC [dbo].[CIC_Pending_CandidateInvitations] 1814,'02/01/2020','03/28/2020',0  
-- Modified by Radhika Dereddy on 02/25/2020 to add RequestforInfoSent.  
-- Modified by Humera Ahmed for HDT#75171 - Add HR Review Email Address as a field. It should be inserted between the Requestor and Candidate Link fields.  
-- =============================================  
-- Modify By : YSharma
-- Modify Date: 14- Feb- 2024
-- Description : As per HDT 125756, Need to optimize script. 
-- ==============================================

CREATE PROCEDURE [dbo].[CIC_Pending_CandidateInvitations]  
 -- Add the parameters for the stored procedure here  
 @CLNO Int = 0,  
 @StartDate DATETIME ,  
 @EndDate DATETIME = NULL,  
 @ExcludeMCIC BIT = 1  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
 IF(@EndDate IS NULL)  
  SET @EndDate = GETDATE() ;
   SET @EndDate=DATEADD(d,1,@EndDate);

 IF @CLNO=0 
	SET @CLNO =NULL;
  
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
	 CandidateLink=CASE WHEN t.ExpireDate>GETDATE() then CONCAT('https://candidate.precheck.com/CIC/Authenticate?token=',CONVERT(VARCHAR(100),ISNULL(v.TokenId,''))) ELSE '' end,  
	 O.IsReviewRequired AS [ReviewProcessEnabled],  
	 RS.DisplayName AS [ReviewStatus],  
	 CASE WHEN RS.ReviewStatusID = 2 THEN RRA.CreateDate ELSE '' END AS [RequestforInfoSent]   

FROM Enterprise.Staging.OrderStage O WITH(INDEX(PK_Staging_orderId),NOLOCK) 
	INNER JOIN Enterprise.Staging.ApplicantStage A WITH(NOLOCK)  ON O.StagingOrderId=A.StagingOrderId  
	LEFT JOIN Enterprise.[Security].[vwTokenStagingApplicantId] v WITH(NOLOCK) ON a.StagingApplicantId=v.StagingApplicantId --- added by sahithi  
	LEFT JOIN Enterprise.PreCheck.[vwIntegrationApplicantReport]  IAR WITH(NOLOCK) ON IAR.RequestID = O.IntegrationRequestId  
	INNER JOIN SecureBridge.DBO.Token AS T WITH(NOLOCK) ON v.tokenid = T.TokenId 
	LEFT OUTER JOIN Enterprise.Staging.ReviewRequest  RR WITH(NOLOCK) ON RR.StagingApplicantId = A.StagingApplicantId  
	LEFT OUTER JOIN Enterprise.Lookup.ReviewStatus RS WITH(NOLOCK) ON RS.ReviewStatusId = rr.ClosingReviewStatusId  
	LEFT OUTER JOIN Enterprise.Staging.ReviewResponseAction RRA WITH(NOLOCK) ON RS.ReviewStatusId = RRA.ReviewStatusID and RR.ReviewRequestId  = RRA.ReviewRequestID  
WHERE    
	 (((O.IsReviewRequired = 0 OR O.IsReviewRequired IS NULL) AND ISNULL(T.IsActive,1)=1)   OR O.IsReviewRequired = 1)  
	 AND (A.IsConfirmed IS NULL OR A.IsConfirmed=0) 
	 AND O.DASourceId=2   
	 AND O.Attention NOT LIKE '%precheck.com%'   
	 AND A.Email NOT LIKE '%precheck.com%'  
	 AND (@CLNO IS NULL OR O.ClientID=@CLNO)
	 And (A.IsActive is null or A.isactive =1)
	 AND O.CreateDate>=@StartDate AND O.CreateDate<= @EndDate  
	 AND (@ExcludeMCIC<>1 OR (O.BatchOrderDetailId IS NULL OR O.BatchOrderDetailId=0))
ORDER BY O.CreateDate DESC  
END
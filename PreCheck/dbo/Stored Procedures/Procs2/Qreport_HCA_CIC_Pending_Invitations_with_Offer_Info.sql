/*--------------------------------------------------------------------------------- 
-- Author:  Humera Ahmed  
-- Create date: 10/11/2022  
-- Description: HDT #50162 - To create a new Q-report and mirror from CIC_Pending_Invitations_with_Offer_Info - Rename "HCA CIC Pending Invitations with Offer Info"  
-- EXEC [dbo].[Qreport_HCA_CIC_Pending_Invitations_with_Offer_Info] '09/10/2022','09/15/2022'

ModifiedBy		ModifiedDate	TicketNo	Description
Shashank Bhoi	11/16/2022		72018		#72018  include both affiliate 4 (HCA) & 294 (HCA Velocity). 
											EXEC dbo.Qreport_HCA_CIC_Pending_Invitations_with_Offer_Info '11/01/2022','11/11/2022'
*/--------------------------------------------------------------------------------- 
CREATE PROCEDURE [dbo].[Qreport_HCA_CIC_Pending_Invitations_with_Offer_Info]  
 -- Add the parameters for the stored procedure here  
 @StartDate DATETIME,  
 @EndDate DATETIME,  
 @ExcludeMCIC BIT = 1,  
 @PendingItemsOnly BIT = 1  
AS  
BEGIN  
  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
    -- Insert statements for procedure here  
 SET @EndDate = DATEADD(d,1,@EndDate)    
  
 DROP TABLE IF EXISTS #tmpCOffer  
 DROP TABLE IF EXISTS #tmpCOffer1  
 DROP TABLE IF EXISTS #tmpCOffer2  
 DROP TABLE IF EXISTS #tmpCOffer3  
 DROP TABLE IF EXISTS #vwIntegrationApplicantReport  
 DROP TABLE IF EXISTS #vwIntegrationOrderCurrent  
  
 CREATE TABLE #vwIntegrationApplicantReport (  
 RequestID INT,  
 OrderNumber VARCHAR(20),  
 PartnerReferenceNumber VARCHAR(100),  
 Partner_TransactionID varchar(50),  
 ActionCode varchar(10),  
 PackageID varchar(20),  
 CLNO int,  
 RequestDate datetime  
 )  
 CREATE NONCLUSTERED INDEX [IX_Temp1]  
 ON [dbo].[#vwIntegrationApplicantReport] ([RequestID])  
 INCLUDE ([OrderNumber],[PartnerReferenceNumber],[Partner_TransactionID], [ActionCode], [PackageID], [CLNO],[RequestDate])  
  
  
 SELECT  
 CTE.OrderId,  
 CTE.OrderNumber,  
 CTE.IntegrationRequestId,  
 CTE.ModifyDate   
 INTO #vwIntegrationOrderCurrent  
 FROM   
 Enterprise.dbo.[Order] CTE  
 INNER JOIN  
 (  
  SELECT  
  R.IntegrationRequestId,  
  LastUpdate=MAX(R.ModifyDate)  
  FROM Enterprise.dbo.[Order] R  
  GROUP BY R.IntegrationRequestId  
 ) L   
 ON CTE.IntegrationRequestId=L.IntegrationRequestId  AND CTE.ModifyDate=L.LastUpdate  
  
  
 INSERT INTO #vwIntegrationApplicantReport  
 (  
     RequestID,  
     OrderNumber,  
     PartnerReferenceNumber,  
     Partner_TransactionID,  
  ActionCode,  
  PackageID,  
  CLNO,  
  RequestDate  
 )  
 SELECT  
 ir.RequestID,  
 o.OrderNumber,  
 '' AS PartnerReferenceNumber,  -- leave this blank for now.  Update this field after final result set is returned.  
 --PartnerReferenceNumber = ISNULL([PreCheck].[dbo].[GetIntegrationRequestNodeValue](Ir.RequestId, O.OrderNumber,'RequisitionNumber'),''),  
 Partner_TransactionID = IR.Partner_Reference,  
 ISNULL([PreCheck].[dbo].[GetIntegrationRequestNodeValue](IR.RequestID, NULL,'ActionCode'),''),  
 PackageID=ISNULL([PreCheck].[dbo].[GetIntegrationRequestNodeValue](IR.RequestID, NULL,'PackageID'),''),  
 IR.CLNO,  
 IR.RequestDate  
 FROM    
  Precheck.dbo.Integration_OrderMgmt_Request IR  
  LEFT OUTER JOIN #vwIntegrationOrderCurrent O ON IR.RequestID=O.IntegrationRequestId  
  LEFT JOIN Enterprise.dbo.Applicant A ON O.OrderId=A.OrderId  
  INNER JOIN dbo.Client c WITH(nolock) ON c.CLNO = IR.CLNO  
 where   
 IR.CLNO IN (7519,15163)  
 --AND C.AffiliateID = 4			--Code commenetd by Shashank for ticket id -72018
 AND C.AffiliateID IN (4, 294)	--Code added by Shashank for ticket id -72018  
 AND IR.RequestDate between @StartDate AND @EndDate  
  
    --Insert into #tmpCOffer  
 SELECT   
 co.OfferTokenId,  
 a.SecurityTokenId AS AsSecurityTokenID,  
 rr.SecurityTokenId AS RRSecurityTokenID,  
 IAR.RequestID,  
 CO.IntegrationRequestId [CO_IntegrationRequestId],  
 IAR.CLNO,  
 ParentCLNO=O.ClientId,  
 FacilityCLNO=O.FacilityId,  
 APNO=A.ApplicantNumber,  
 ApplicantId = ISNULL(A.ClientCandidateId,'0'),  
 iar.OrderNumber,  
 RequisitionNumber = ISNULL(IAR.PartnerReferenceNumber, ''),  
 A.Phone,   
 IAR.ActionCode,  
 IAR.PackageID,  
 CASE WHEN isnumeric(IAR.PackageID) = 1 THEN pm.PackageDesc   
   WHEN isnumeric(IAR.PackageID) = 0 THEN cbp.PackageDescription END AS [Package Requested],  
 CASE WHEN IAR.CLNO = 7519 THEN replace(CO.LastName,',',' ')   
   WHEN IAR.CLNO = 15163 THEN replace(A.LastName,',',' ') END AS [Last Name],  
 CASE WHEN IAR.CLNO = 7519 THEN  CO.FirstName    
   WHEN IAR.CLNO = 15163 THEN A.FirstName END AS [First Name],  
 CASE WHEN IAR.CLNO = 7519 THEN CO.CandidateEmail    
   WHEN IAR.CLNO = 15163 THEN A.Email END AS [Applicant Email],   
 [OfferCreatedOn] = CO.CreateDate,  
 [RequestDate] = IAR.RequestDate,  
 [OfferLinkSentOn] = PCB.CallbackDate,  
 [OfferResponseDate] = CO.ResponseDate,  
 [OfferResponse] = DA.ItemName,  
 --'' AS OfferCandidateLink, --OfferCandidateLink=CASE WHEN t1.ExpireDate>GETDATE() then  CONCAT('https://candidate.precheck.com/Offer/Authentication?token=',CONVERT(VARCHAR(100),ISNULL(CO.OfferTokenId,''))) else '' end,  
 --'' AS OfferLinkExpiration, --t1.ExpireDate as OfferLinkExpiration,  
 ConsentLinkCreatedOn=O.CreateDate,   
 --'' AS CandidateLinkExpirationDate, --T.[ExpireDate] AS CandidateLinkExpirationDate,  
 LastActivity=a.ModifyDate,   
 Requestor =O.Attention,  
 O.ReviewerEmail as [HR Review Email Address],  
 --CandidateLink=CASE WHEN t.ExpireDate>GETDATE() then CONCAT('https://candidate.precheck.com/CIC/Authenticate?token=',CONVERT(VARCHAR(100),ISNULL(v.TokenId,''))) ELSE '' end,  
 --'' AS ConsentCandidateLink, --ConsentCandidateLink=CASE WHEN t.ExpireDate>GETDATE() then CONCAT('https://candidate.precheck.com/CIC/Authenticate?token=',CONVERT(VARCHAR(100),ISNULL(A.SecurityTokenId,''))) ELSE '' end,  
 O.IsReviewRequired AS [ReviewProcessEnabled],  
 --[HRReview/CertificationLink] = RR.SecurityTokenId,  
 [HR Review/Certification Link] = CASE WHEN RR.SecurityTokenId is not null then CONCAT('https://hrservices.precheck.com/ReviewProcess/Authenticate?token=',CONVERT(VARCHAR(100),ISNULL(RR.SecurityTokenId,''))) ELSE '' end,  
 Case  when DAOfferStatusId is NULL then 'Pending Offer'  
    when DAOfferStatusId = 4885 then 'Offer Refusal'   
    when enableorder = 0 then 'Offer-No Background'  
    when RS.DisplayName is not null then RS.DisplayName   
    else 'Pending CIC' end AS [ReviewStatus],  
 Case when RS.ReviewStatusID = 2 THEN RRA.CreateDate ELSE Cast(NULL as datetime) END AS [RequestforInfoSent]   
 INTO #tmpCOffer1  
 FROM  #vwIntegrationApplicantReport IAR with(nolock)  
 LEFT OUTER JOIN [Enterprise].Staging.CandidateOffer CO with(nolock) on IAR.RequestID = CO.IntegrationRequestID  --replaced view with temp table 6/30/2022  
 LEFT OUTER JOIN DBO.Integration_OfferLink_Callback(@StartDate,@EndDate) PCB ON IAR.Partner_TransactionID = PCB.Partner_reference  
 --LEFT OUTER JOIN SecureBridge.DBO.Token AS T1 with(nolock) ON CO.OfferTokenId = T1.TokenId AND T1.IsActive = 1  
 LEFT OUTER JOIN [Enterprise].dbo.DynamicAttribute DA with(nolock) on CO.DAOfferStatusId = DA.DynamicAttributeId  
 LEFT OUTER JOIN [Enterprise].Staging.OrderStage O with(nolock) ON IAR.RequestID = O.IntegrationRequestId  
 LEFT JOIN [Enterprise].Staging.ApplicantStage A with(nolock) ON A.StagingOrderId=O.StagingOrderId  
 --LEFT OUTER JOIN SecureBridge.DBO.Token AS T with(nolock) ON A.SecurityTokenId = T.TokenId AND T.IsActive=1  
 LEFT OUTER JOIN [Enterprise].Staging.ReviewRequest  RR with(nolock) ON RR.StagingApplicantId = A.StagingApplicantId  
 LEFT OUTER JOIN [Enterprise].Lookup.ReviewStatus RS with(nolock) ON RS.ReviewStatusId = rr.ClosingReviewStatusId  
 LEFT OUTER JOIN [Enterprise].Staging.ReviewResponseAction RRA with(nolock) on RS.ReviewStatusId = RRA.ReviewStatusID and RR.ReviewRequestId  = RRA.ReviewRequestID  
 --LEFT OUTER JOIN SecureBridge.DBO.Token AS T3 with(nolock) ON RR.SecurityTokenId = T.TokenId AND T.IsActive=1  
 LEFT OUTER JOIN [ClientBusinessPackage] cbp on IAR.PackageID = cbp.PackageCode and IAR.CLNO = cbp.ClientID  
 LEFT OUTER JOIN PackageMain pm on cast(pm.PackageID as varchar(10)) = IAR.PackageID  
 WHERE    
 (O.IsReviewRequired IS NULL OR O.IsReviewRequired IN (0,1))  
 AND (a.IsConfirmed IS NULL OR a.IsConfirmed = 0)   
 and (o.DASourceId IS NULL OR o.DASourceId = 2)   
 AND (o.Attention IS NULL OR O.Attention NOT LIKE '%precheck.com%' )  
 AND (A.Email IS NULL OR A.Email NOT LIKE '%precheck.com%' )  
 AND (A.IsActive IS NULL OR A.IsActive = 1)    
 AND ISNULL(O.BatchOrderDetailId,0) = CASE WHEN @ExcludeMCIC=1 THEN 0 ELSE ISNULL(O.BatchOrderDetailId,0) END  
 AND (co.IntegrationRequestId IS NOT NULL OR IAR.CLNO = 15163)  
  
   
 SELECT t.*,  
 OfferCandidateLink=CASE WHEN t1.ExpireDate>GETDATE() then  CONCAT('https://candidate.precheck.com/Offer/Authentication?token=',CONVERT(VARCHAR(100),ISNULL(t.OfferTokenId,''))) else '' end,  
 t1.ExpireDate as OfferLinkExpiration  
 INTO #tmpCOffer2   
 FROM #tmpCOffer1 t  
 LEFT OUTER JOIN SecureBridge.DBO.Token AS T1 with(nolock) ON t.OfferTokenId = T1.TokenId AND T1.IsActive = 1  
  
 SELECT t.*,  
 t1.[ExpireDate] AS CandidateLinkExpirationDate,  
 ConsentCandidateLink=CASE WHEN t1.ExpireDate>GETDATE() then CONCAT('https://candidate.precheck.com/CIC/Authenticate?token=',CONVERT(VARCHAR(100),ISNULL(t.AsSecurityTokenID,''))) ELSE '' end  
 INTO #tmpCOffer3  
 FROM #tmpCOffer2 t  
 LEFT OUTER JOIN SecureBridge.DBO.Token AS t1 with(nolock) ON t.AsSecurityTokenID = t1.TokenId AND t1.IsActive=1  
  
  
 SELECT t.*  
 INTO #tmpCOffer  
 FROM #tmpCOffer3 t  
 LEFT OUTER JOIN SecureBridge.DBO.Token AS T3 with(nolock) ON t.RRSecurityTokenID = t3.TokenId AND t3.IsActive=1  
  
  
  
 --  Wait until final result set to update the RequisitionNumber.  Doing this in the temp table creation of #vwIntegrationApplicantReport  
 --  causes bad performance due to the number of records and the function call [GetIntegrationRequestNodeValue]  
 UPDATE #tmpCOffer SET RequisitionNumber = ISNULL([PreCheck].[dbo].[GetIntegrationRequestNodeValue](RequestID, OrderNumber,'RequisitionNumber'),'')  
  
 --select * from #tmpCOffer --where [HR Review/Certification Link] = 'A474E3D8-4664-49EA-BEBC-4CD4E1C81BD7'  
   
 IF @PendingItemsOnly = 1  
  Select    
    [Entered Via] = CASE WHEN #tmpCOffer.CLNO = 7519 THEN 'Taleo' WHEN #tmpCOffer.CLNO = 15163 THEN 'GHR/Infor' END,  
    ParentCLNO,  
                FacilityCLNO,  
                ApplicantId,  
    APNO,  
    RequisitionNumber,  
                [Last Name],  
                [First Name],  
                [Applicant Email],  
                Phone,  
    ActionCode,  
    PackageID,  
    [Package Requested],  
                OfferCreatedOn,  
                OfferLinkSentOn,  
                OfferResponseDate,  
                OfferResponse,  
                OfferCandidateLink,  
                OfferLinkExpiration,  
                ConsentLinkCreatedOn,  
                CandidateLinkExpirationDate,  
                LastActivity,  
                Requestor,  
                [HR Review Email Address],  
                ConsentCandidateLink,  
                ReviewProcessEnabled,  
    [HR Review/Certification Link],  
                ReviewStatus,  
                RequestforInfoSent from #tmpCOffer   
  where  ReviewStatus not in ('Offer Refusal','Offer-No Background')  
  ORDER BY [Entered Via] asc, [OfferCreatedOn] desc  
 ELSE  
  Select    
    [Entered Via] = CASE WHEN #tmpCOffer.CLNO = 7519 THEN 'Taleo' WHEN #tmpCOffer.CLNO = 15163 THEN 'GHR/Infor' END,  
    ParentCLNO,  
                FacilityCLNO,   
    ParentCLNO,  
                FacilityCLNO,  
                ApplicantId,  
    APNO,  
    RequisitionNumber,  
                [Last Name],  
                [First Name],  
                [Applicant Email],  
                Phone,  
    ActionCode,  
    PackageID,  
    [Package Requested],  
                OfferCreatedOn,  
                OfferLinkSentOn,  
                OfferResponseDate,  
                OfferResponse,  
                OfferCandidateLink,  
                OfferLinkExpiration,  
                ConsentLinkCreatedOn,  
                CandidateLinkExpirationDate,  
                LastActivity,  
                Requestor,  
                [HR Review Email Address],  
                ConsentCandidateLink,  
                ReviewProcessEnabled,  
    [HR Review/Certification Link],  
                ReviewStatus,  
                RequestforInfoSent  
    FROM #tmpCOffer   
  ORDER BY [Entered Via] asc, [OfferCreatedOn] desc  
  
END

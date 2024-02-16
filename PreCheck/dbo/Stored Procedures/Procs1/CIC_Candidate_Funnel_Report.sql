
-- =============================================  
-- Author:  Santosh CHapyala 12/09/2021  
-- [dbo].[CIC_Candidate_Funnel_Report] 7519  
-- Modified By:Amy Liu on 12/10/2021 HDT29166  
-- Modified By:sChapyala on 12/22/2021 - HDT 30485 or 30492   
-- Modified By: Jeff Simenc on 06/30/2022   
-- Description : Replaced join on the view #vwIntegrationApplicantReport with the code.  Replaced all "IsNull" functions in   
--     the where clause.  
-- =============================================  
/*
ModifiedBy		ModifiedDate	TicketNo	Description
Shashank Bhoi	10/21/2022		67226		#67226 Update Affiliate ID Parameter Parent HDT#56320
											Modify existing q-reports that have affiliate ids in their search parameters  
											Details:   
											Change search parameters for the Affiliate Id field  
											     * search by multiple affiliate ids (ex 4:297)  
											     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates  
											     * multiple affiliates to be separated by a colon    
											Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0) 
											EXEC [dbo].[CIC_Candidate_Funnel_Report] @CLNO=7519

*/
CREATE PROCEDURE [dbo].[CIC_Candidate_Funnel_Report]  
 -- Add the parameters for the stored procedure here  
 @CLNO Int = 0,  
 @StartDate DATETIME =NULL,  
 @EndDate DATETIME = NULL,  
 @ExcludeMCIC BIT = 1,  
 @PendingItemsOnly BIT = 1,
 @AffiliateIDs varchar(MAX) = '0'	--Code added by Shashank for ticket id -67226
AS  
BEGIN  
  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
 IF(@StartDate IS NULL)  
  set @StartDate = DATEADD(d,-30,GETDATE())  ---1 month in the past  
 IF(@EndDate IS NULL)  
  SET @EndDate = DATEADD(d,1,GETDATE())  ---1 day in the future  
  
 --Code added by Shashank for ticket id -67226 starts
IF(@AffiliateIDs = '' OR LOWER(@AffiliateIDs) = 'null' OR @AffiliateIDs = '0')   
	SET @AffiliateIDs = NULL;  
--Code added by Shashank for ticket id -67226 ends

 -- Section to replace the join to the view #vwIntegrationApplicantReport.  This adds 2 temp tables for use in the  
 -- main query.    
  
 CREATE TABLE #vwIntegrationApplicantReport (  
 RequestID INT,  
 OrderNumber VARCHAR(20),  
 PartnerReferenceNumber VARCHAR(100),  
 Partner_TransactionID varchar(50)  
 )  
 CREATE NONCLUSTERED INDEX [IX_Temp1]  
 ON [dbo].[#vwIntegrationApplicantReport] ([RequestID])  
 INCLUDE ([OrderNumber],[PartnerReferenceNumber],[Partner_TransactionID])  
  
  
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
     Partner_TransactionID  
 )  
 SELECT  
 ir.RequestID,  
 o.OrderNumber,  
 '' AS PartnerReferenceNumber,  -- leave this blank for now.  Update this field after final result set is returned.  
 --PartnerReferenceNumber = ISNULL([PreCheck].[dbo].[GetIntegrationRequestNodeValue](Ir.RequestId, O.OrderNumber,'RequisitionNumber'),''),  
 Partner_TransactionID = IR.Partner_Reference   
 FROM    
  Precheck.dbo.Integration_OrderMgmt_Request IR  
  LEFT OUTER JOIN #vwIntegrationOrderCurrent O ON IR.RequestID=O.IntegrationRequestId  
  LEFT JOIN Enterprise.dbo.Applicant A ON O.OrderId=A.OrderId  
  
  
    --Insert into #tmpCOffer  
 SELECT   
 ParentCLNO=O.ClientId,  
 FacilityCLNO=O.FacilityId,  
 ApplicantId = ISNULL(A.ClientCandidateId,'0'),  
 iar.RequestID,  
 iar.OrderNumber,  
 RequisitionNumber = ISNULL(IAR.PartnerReferenceNumber, ''),  
 replace(CO.LastName,',',' ') LastName,  
 CO.FirstName,   
 CO.CandidateEmail AS ApplicantEmail,  
 A.Phone,   
 [OfferCreatedOn] = CO.CreateDate,  
 [OfferLinkSentOn] = PCB.CallbackDate,  
 [OfferResponseDate] = CO.ResponseDate,  
 [OfferResponse] = DA.ItemName,  
 OfferCandidateLink=CASE WHEN t1.ExpireDate>GETDATE() then  CONCAT('https://candidate.precheck.com/Offer/Authentication?token=',CONVERT(VARCHAR(100),ISNULL(CO.OfferTokenId,''))) else '' end,  
 t1.ExpireDate as OfferLinkExpiration,  
 ConsentLinkCreatedOn=O.CreateDate,   
 T.[ExpireDate] AS CandidateLinkExpirationDate,  
 LastActivity=a.ModifyDate,   
 Requestor =O.Attention,  
 O.ReviewerEmail as [HR Review Email Address],  
 --CandidateLink=CASE WHEN t.ExpireDate>GETDATE() then CONCAT('https://candidate.precheck.com/CIC/Authenticate?token=',CONVERT(VARCHAR(100),ISNULL(v.TokenId,''))) ELSE '' end,  
 ConsentCandidateLink=CASE WHEN t.ExpireDate>GETDATE() then CONCAT('https://candidate.precheck.com/CIC/Authenticate?token=',CONVERT(VARCHAR(100),ISNULL(CO.InviteTokenId,''))) ELSE '' end,  
 O.IsReviewRequired AS [ReviewProcessEnabled],  
 Case  when DAOfferStatusId is NULL then 'Pending Offer'  
    when DAOfferStatusId = 4885 then 'Offer Refusal'   
    when enableorder = 0 then 'Offer-No Background'  
    when RS.DisplayName is not null then RS.DisplayName   
    else 'Pending CIC' end AS [ReviewStatus],  
 Case when RS.ReviewStatusID = 2 THEN RRA.CreateDate ELSE Cast(NULL as datetime) END AS [RequestforInfoSent]   
 INTO #tmpCOffer  
 FROM  [Enterprise].Staging.CandidateOffer CO   
 LEFT OUTER JOIN #vwIntegrationApplicantReport IAR with(nolock) on IAR.RequestID = CO.IntegrationRequestID  --replaced view with temp table 6/30/2022  
 LEFT OUTER JOIN DBO.Integration_OfferLink_Callback(@StartDate,@EndDate) PCB ON IAR.Partner_TransactionID = PCB.Partner_reference  
 LEFT  JOIN SecureBridge.DBO.Token AS T1 ON CO.OfferTokenId = T1.TokenId AND T1.IsActive = 1  
 LEFT OUTER JOIN SecureBridge.DBO.Token AS T ON CO.InviteTokenId = T.TokenId AND T.IsActive=1  
 LEFT OUTER JOIN [Enterprise].dbo.DynamicAttribute DA on CO.DAOfferStatusId = DA.DynamicAttributeId  
 LEFT OUTER JOIN [Enterprise].Staging.OrderStage O with(nolock) ON CO.StagingOrderId = O.StagingOrderId  
 LEFT JOIN [Enterprise].Staging.ApplicantStage A with(nolock) ON O.StagingOrderId=A.StagingOrderId  
 LEFT OUTER JOIN [Enterprise].Staging.ReviewRequest  RR with(nolock) ON RR.StagingApplicantId = A.StagingApplicantId  
 LEFT OUTER JOIN [Enterprise].Lookup.ReviewStatus RS with(nolock) ON RS.ReviewStatusId = rr.ClosingReviewStatusId  
 LEFT OUTER JOIN [Enterprise].Staging.ReviewResponseAction RRA with(nolock) on RS.ReviewStatusId = RRA.ReviewStatusID and RR.ReviewRequestId  = RRA.ReviewRequestID  
 LEFT OUTER JOIN PRECHECK.dbo.Client AS C ON O.ClientId = C.CLNO	--Code added by Shashank for ticket id -67226
 WHERE    
 (O.IsReviewRequired IS NULL OR O.IsReviewRequired IN (0,1))  
 --(((isnull(O.IsReviewRequired,0) = 0 OR O.IsReviewRequired IS NULL) )   OR isnull(O.IsReviewRequired,1) = 1)  
 AND (a.IsConfirmed IS NULL OR a.IsConfirmed = 0)   
 --AND ISNULL(A.IsConfirmed,0)=0   
 AND (o.DASourceId IS NULL OR o.DASourceId = 2)   
 --and isnull(O.DASourceId,2)=2 -- added by sahithi   
 AND (o.Attention IS NULL OR O.Attention NOT LIKE '%precheck.com%' )  
 --AND isnull(O.Attention,'') NOT LIKE '%precheck.com%'   
 AND (a.Email IS NULL OR A.Email NOT LIKE '%precheck.com%' )  
 --AND isnull(A.Email,'') NOT LIKE '%precheck.com%'  
 AND (CO.ClientID=@CLNO OR @CLNO=0)   
 AND (a.IsActive IS NULL OR a.IsActive = 1)   
 --AND ISNULL(A.IsActive,1)=1   
 AND CO.CreateDate>=@StartDate AND CO.CreateDate<= @EndDate  
 AND ISNULL(O.BatchOrderDetailId,0) = CASE WHEN @ExcludeMCIC=1 THEN 0 ELSE ISNULL(O.BatchOrderDetailId,0) END  
 AND (@AffiliateIDs IS NULL OR C.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':'))) --Code added by Shashank for ticket id -67226 
  
  
 --  Wait until final result set to update the RequisitionNumber.  Doing this in the temp table creation of #vwIntegrationApplicantReport  
 --  causes bad performance due to the number of records and the function call [GetIntegrationRequestNodeValue]  
 UPDATE #tmpCOffer SET RequisitionNumber = ISNULL([PreCheck].[dbo].[GetIntegrationRequestNodeValue](RequestID, OrderNumber,'RequisitionNumber'),'')  
  
   
  
 IF @PendingItemsOnly = 1  
  Select  ParentCLNO,  
                FacilityCLNO,  
                ApplicantId,  
    RequisitionNumber,  
                LastName,  
                FirstName,  
                ApplicantEmail,  
                Phone,  
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
                ReviewStatus,  
                RequestforInfoSent from #tmpCOffer   
  where  ReviewStatus not in ('Offer Refusal','Offer-No Background')  
  ORDER BY [OfferCreatedOn] desc  
 ELSE  
  Select ParentCLNO,  
                FacilityCLNO,  
                ApplicantId,  
    RequisitionNumber,  
                LastName,  
                FirstName,  
                ApplicantEmail,  
                Phone,  
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
                ReviewStatus,  
                RequestforInfoSent  
    FROM #tmpCOffer   
  ORDER  BY [OfferCreatedOn] desc  
  
 Drop table #tmpCOffer  
 DROP TABLE #vwIntegrationApplicantReport  
 DROP TABLE #vwIntegrationOrderCurrent  
  
  
 SET TRANSACTION ISOLATION LEVEL READ COMMITTED  
 SET NOCOUNT OFF;  
  
END  

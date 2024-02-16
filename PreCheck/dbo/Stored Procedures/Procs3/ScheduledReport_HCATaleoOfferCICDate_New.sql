-- =============================================
-- Author:		Humera Ahmed
-- Create date: 12/15/2021 
-- Description:	Scheduled report for HCA - Data should be limited to orders received via HCA’s Taleo integration.
-- EXEC [dbo].[ScheduledReport_HCATaleoOfferCICDate] 7519,NULL,NULL, 1 
--Modified by Schapyala - 12/22/2021 - HDT  30485 or 30492 
-- Modified by Sahithi -1/5/2022 HDT:30993 ,added ApplicantemailId in select list
-- =============================================
CREATE PROCEDURE [dbo].[ScheduledReport_HCATaleoOfferCICDate_New] 
	-- Add the parameters for the stored procedure here
    @CLNO Int = 0,
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL,
	@ExcludeMCIC BIT = 1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(@StartDate IS NULL)
		set @StartDate ='2021-12-08 19:00:00.000' --DATEADD(d,-30,GETDATE())  ---30 days in the past
	IF(@EndDate IS NULL)
		SET @EndDate = getdate()  --DATEADD(d,1,GETDATE())  ---1 day in the future
	
	SELECT  
		ParentCLNO=O.ClientId,
		[Client Number]=O.FacilityId,
		[Client Name] = c.Name,
		[Report Number] = A.ApplicantNumber,
		replace(CO.LastName,',',' ') LastName,
		replace(CO.FirstName,',',' ') FirstName, 
		ApplicantId = ISNULL(A.ClientCandidateId,'0'),
	    A.email  as [ApplicantEmail],
		RequisitionNumber = ISNULL(IAR.PartnerReferenceNumber, ''),
		[Action Code] =IAR.ActionCode,
		[Last Update] = format(A.ModifyDate,'MM/dd/yyyy hh:mm:ss tt'),
		[Offer Created] = format(CO.CreateDate,'MM/dd/yyyy hh:mm tt'),
		[Offer Link Sent] = format(PCB.CallbackDate,'MM/dd/yyyy hh:mm tt'),
		[Offer Response Date] = format(CO.ResponseDate,'MM/dd/yyyy hh:mm tt'),
		[Offer Response] = DA.ItemName,
		[Consent Link Created]=format(O.CreateDate,'MM/dd/yyyy hh:mm tt'), 
		[Consent Completed] = format(RR.CreateDate,'MM/dd/yyyy hh:mm:ss tt'),
		[BG Auth Consent Sent] = format(RR.CreateDate,'MM/dd/yyyy hh:mm:ss tt'),
		[HR Review Completed] =format(Case when RS.ReviewStatusID = 4 THEN RRA.CreateDate ELSE Cast(NULL as datetime) END,'MM/dd/yyy hh:mm:ss tt'),
		[Certification Completed] = format(cc.ClientCertUpdated,'MM/dd/yyyy hh:mm:ss tt'),
		[Original Close Date] = format(a2.OrigCompDate,'MM/dd/yyyy hh:mm:ss tt'),
		[ReOpen Date] = format(a2.ReopenDate,'MM/dd/yyyy hh:mm:ss tt'),
		[Completed Date] = format(a2.CompDate,'MM/dd/yyyy hh:mm:ss tt'),
		[Offer Created/Sent TAT] = [dbo].[ElapsedBusinessDaysInDecimal] (CO.CreateDate, PCB.CallbackDate),
		[Offer TAT] = [dbo].[ElapsedBusinessDaysInDecimal] (PCB.CallbackDate,CO.ResponseDate),
		[Consent TAT] = [dbo].[ElapsedBusinessDaysInDecimal] (O.CreateDate,RR.CreateDate),
		[Candidate Offer and CIC TAT] = [dbo].[ElapsedBusinessDaysInDecimal] (PCB.CallbackDate,RR.CreateDate),
		[HR Review TAT] = [dbo].[ElapsedBusinessDaysInDecimal] (RR.CreateDate, a2.CreatedDate),
		[HR Review to Certification TAT] = [dbo].[ElapsedBusinessDaysInDecimal] (a2.CreatedDate,cc.ClientCertUpdated),
		[Offer to BG Report Created TAT] = [dbo].[ElapsedBusinessDaysInDecimal] (PCB.CallbackDate,cc.ClientCertUpdated),
		[Report TAT] = [dbo].[ElapsedBusinessDaysInDecimal] (a2.CreatedDate,a2.OrigCompDate),
		[Offer Invite to First Close TAT] = [dbo].[ElapsedBusinessDaysInDecimal] (PCB.CallbackDate,a2.OrigCompDate),
		[Total Client TAT] = [dbo].[ElapsedBusinessDaysInDecimal](A.CreateDate,a2.CompDate),
		[# of HR Review Cycles] = RRF.RequestCount,
		[Last Request for Info Sent] =format(Case when RS.ReviewStatusID = 2 THEN RRA.CreateDate ELSE Cast(NULL as datetime) END,'MM/dd/yyy hh:mm:ss tt')	
	FROM  [Enterprise].Staging.CandidateOffer CO 
		LEFT OUTER JOIN [Enterprise].PreCheck.[vwIntegrationApplicantReport]  IAR with(nolock) on IAR.RequestID = CO.IntegrationRequestID
		LEFT OUTER JOIN DBO.Integration_OfferLink_Callback_new(@StartDate,@EndDate) PCB ON IAR.RequestID = PCB.RequestID
		LEFT  JOIN SecureBridge.DBO.Token AS T1 ON CO.OfferTokenId = T1.TokenId AND T1.IsActive = 1
		LEFT OUTER JOIN SecureBridge.DBO.Token AS T ON CO.InviteTokenId = T.TokenId AND T.IsActive=1
		LEFT OUTER JOIN [Enterprise]..DynamicAttribute DA on CO.DAOfferStatusId = DA.DynamicAttributeId
		LEFT OUTER JOIN [Enterprise].Staging.OrderStage O with(nolock) ON CO.StagingOrderId = O.StagingOrderId
		LEFT JOIN [Enterprise].Staging.ApplicantStage A with(nolock) ON O.StagingOrderId=A.StagingOrderId
		LEFT join client c with(nolock) on O.FacilityId = c.CLNO
		LEFT OUTER JOIN [Enterprise].Staging.ReviewRequest  RR with(nolock) ON RR.StagingApplicantId = A.StagingApplicantId
		LEFT OUTER JOIN [Enterprise].Lookup.ReviewStatus RS with(nolock) ON RS.ReviewStatusId = rr.ClosingReviewStatusId
		LEFT OUTER JOIN [Enterprise].Staging.ReviewResponseAction RRA with(nolock) on RS.ReviewStatusId = RRA.ReviewStatusID and RR.ReviewRequestId  = RRA.ReviewRequestID
		LEFT OUTER JOIN dbo.Appl a2 with(nolock) ON A.ApplicantNumber = a2.APNO
		LEFT OUTER JOIN dbo.ClientCertification cc ON a2.APNO = cc.APNO
		LEFT OUTER JOIN Enterprise.dbo.vwReviewRequestFirst RRF ON A.StagingApplicantId = RRF.StagingApplicantID
	WHERE 	
		(((isnull(O.IsReviewRequired,0) = 0 OR O.IsReviewRequired IS NULL) )   OR isnull(O.IsReviewRequired,1) = 1)
	 and isnull(O.DASourceId,2)=2 
	AND isnull(O.Attention,'') NOT LIKE '%precheck.com%' 
	AND isnull(A.Email,'') NOT LIKE '%precheck.com%'
	AND (CO.ClientID=@CLNO OR @CLNO=0) 
	AND ISNULL(A.IsActive,1)=1	
	AND CO.CreateDate>=@StartDate AND CO.CreateDate<= @EndDate
	AND ISNULL(O.BatchOrderDetailId,0) = CASE WHEN @ExcludeMCIC=1 THEN 0 ELSE ISNULL(O.BatchOrderDetailId,0) END
	ORDER BY o.CreateDate desc
END

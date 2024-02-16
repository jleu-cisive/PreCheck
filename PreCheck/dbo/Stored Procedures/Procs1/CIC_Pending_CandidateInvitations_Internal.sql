
-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 2/24/2020
-- Description: Create a new Qreport from CIC Pending Invitations for Internal purpose and add DOB and SSN 
-- EXEC [dbo].[CIC_Pending_CandidateInvitations_Internal] 0,'03/15/2020','04/13/2020',0
---- Modified by Radhika Dereddy on 02/25/2020 to add RequestforInfoSent.
-- Modified by Humera Ahmed on 07/24/2020 for HDT#75171 - Add HR Review Email Address as a field. It should be inserted between the Requestor and Candidate Link fields.
-- Modified by Arindam Mitra on 10/26/2023 for HDT#114889 - Added new column DrugScreeningOrdered in the report with Yes/No value.
-- =============================================
CREATE PROCEDURE [dbo].[CIC_Pending_CandidateInvitations_Internal]
    @CLNO INT = 0,
    @StartDate DATETIME,
    @EndDate DATETIME,
    @ExcludeMCIC BIT = 1
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    IF @CLNO = 0
    BEGIN
        SELECT ParentCLNO = O.ClientId,
               FacilityCLNO = O.FacilityId,
               ApplicantId = ISNULL(A.ClientCandidateId, 0),
               RequisitionNumber = ISNULL(IAR.PartnerReferenceNumber, ''),
               A.LastName,
               A.FirstName,
               A.DateOfBirth,
               A.SocialNumber AS SSN,
               A.Email AS ApplicantEmail,
               A.Phone,
               InviteSentOn = O.CreateDate,
               T.[ExpireDate] AS [Link Expiration Date],
               LastActivity = A.ModifyDate,
               Requestor = O.Attention,
               O.ReviewerEmail AS [HR Review Email Address],
               CandidateLink = CASE
                                   WHEN T.ExpireDate > GETDATE() THEN
                                       CONCAT(
                                                 'https://candidate.precheck.com/CIC/Authenticate?token=',
                                                 CONVERT(VARCHAR(100), ISNULL(A.SecurityTokenId, ''))
                                             )
                                   ELSE
                                       ''
                               END,
               O.IsReviewRequired AS [ReviewProcessEnabled],
               RS.DisplayName AS [ReviewStatus],
               CASE
                   WHEN RS.ReviewStatusId = 2 THEN
                       RRA.CreateDate
                   ELSE
                       CAST(NULL AS DATETIME)
               END AS [Request for Info Sent],
               CASE
                   WHEN bs.BusinessServiceId = 2 THEN
                       'Yes'
                   ELSE
                       'No'
               END AS DrugScreeningOrdered --Code added to show DrugScreeningOrdered column against ticket #114889
        FROM Enterprise.Staging.OrderStage O WITH (NOLOCK)
            INNER JOIN Enterprise.Staging.ApplicantStage A WITH (NOLOCK)
                ON O.StagingOrderId = A.StagingOrderId
            LEFT JOIN Enterprise.PreCheck.[vwIntegrationApplicantReport] IAR WITH (NOLOCK)
                ON IAR.RequestID = O.IntegrationRequestId
            LEFT OUTER JOIN SecureBridge.dbo.Token AS T
                ON T.TokenId = A.SecurityTokenId
            LEFT OUTER JOIN Enterprise.Staging.ReviewRequest RR WITH (NOLOCK)
                ON RR.StagingApplicantId = A.StagingApplicantId
            LEFT OUTER JOIN Enterprise.Lookup.ReviewStatus RS WITH (NOLOCK)
                ON RS.ReviewStatusId = RR.ClosingReviewStatusId
            LEFT OUTER JOIN Enterprise.Staging.ReviewResponseAction RRA WITH (NOLOCK)
                ON RS.ReviewStatusId = RRA.ReviewStatusId
                   AND RR.ReviewRequestId = RRA.ReviewRequestId
            LEFT JOIN Enterprise.dbo.[OrderService] OS WITH (NOLOCK)
                ON O.OrderId = OS.OrderId --Code added to show DrugScreeningOrdered column against ticket #114889
            LEFT JOIN Enterprise.dbo.BusinessService bs WITH (NOLOCK)
                ON OS.BusinessServiceId = bs.BusinessServiceId --Code added to show DrugScreeningOrdered column against ticket #114889
        WHERE (
                  (
                      (
                          O.IsReviewRequired = 0
                          OR O.IsReviewRequired IS NULL
                      )
                      AND ISNULL(T.IsActive, 1) = 1
                  )
                  OR O.IsReviewRequired = 1
              )
              AND ISNULL(A.IsConfirmed, 0) = 0
              AND O.Attention NOT LIKE '%precheck.com%'
              AND A.Email NOT LIKE '%precheck.com%'
              AND ISNULL(A.IsActive, 1) = 1
              AND O.CreateDate >= @StartDate
              AND O.CreateDate <= DATEADD(d, 1, @EndDate)
              AND ISNULL(O.BatchOrderDetailId, 0) = CASE
                                                        WHEN @ExcludeMCIC = 1 THEN
                                                            0
                                                        ELSE
                                                            ISNULL(O.BatchOrderDetailId, 0)
                                                    END;
    END;
    ELSE
    BEGIN


        -- Insert statements for procedure here
        SELECT ParentCLNO = O.ClientId,
               FacilityCLNO = O.FacilityId,
               ApplicantId = ISNULL(A.ClientCandidateId, 0),
               RequisitionNumber = ISNULL(IAR.PartnerReferenceNumber, ''),
               A.LastName,
               A.FirstName,
               A.DateOfBirth,
               A.SocialNumber AS SSN,
               A.Email AS ApplicantEmail,
               A.Phone,
               InviteSentOn = O.CreateDate,
               T.[ExpireDate] AS [Link Expiration Date],
               LastActivity = A.ModifyDate,
               Requestor = O.Attention,
               O.ReviewerEmail AS [HR Review Email Address],
               CandidateLink = CASE
                                   WHEN T.ExpireDate > GETDATE() THEN
                                       CONCAT(
                                                 'https://candidate.precheck.com/CIC/Authenticate?token=',
                                                 CONVERT(VARCHAR(100), ISNULL(A.SecurityTokenId, ''))
                                             )
                                   ELSE
                                       ''
                               END,
               O.IsReviewRequired AS [ReviewProcessEnabled],
               RS.DisplayName AS [ReviewStatus],
               CASE
                   WHEN RS.ReviewStatusId = 2 THEN
                       RRA.CreateDate
                   ELSE
                       CAST(NULL AS DATETIME)
               END AS [Request for Info Sent],
               CASE
                   WHEN bs.BusinessServiceId = 2 THEN
                       'Yes'
                   ELSE
                       'No'
               END AS DrugScreeningOrdered --Code added to show DrugScreeningOrdered column against ticket #114889
        FROM Enterprise.Staging.OrderStage O WITH (NOLOCK)
            INNER JOIN Enterprise.Staging.ApplicantStage A WITH (NOLOCK)
                ON O.StagingOrderId = A.StagingOrderId
            LEFT JOIN Enterprise.PreCheck.[vwIntegrationApplicantReport] IAR WITH (NOLOCK)
                ON IAR.RequestID = O.IntegrationRequestId
            LEFT OUTER JOIN SecureBridge.dbo.Token AS T
                ON T.TokenId = A.SecurityTokenId
            LEFT OUTER JOIN Enterprise.Staging.ReviewRequest RR WITH (NOLOCK)
                ON RR.StagingApplicantId = A.StagingApplicantId
            LEFT OUTER JOIN Enterprise.Lookup.ReviewStatus RS WITH (NOLOCK)
                ON RS.ReviewStatusId = RR.ClosingReviewStatusId
            LEFT OUTER JOIN Enterprise.Staging.ReviewResponseAction RRA WITH (NOLOCK)
                ON RS.ReviewStatusId = RRA.ReviewStatusId
                   AND RR.ReviewRequestId = RRA.ReviewRequestId
            LEFT JOIN Enterprise.dbo.[OrderService] OS WITH (NOLOCK)
                ON O.OrderId = OS.OrderId --Code added to show DrugScreeningOrdered column against ticket #114889
            LEFT JOIN Enterprise.dbo.BusinessService bs WITH (NOLOCK)
                ON OS.BusinessServiceId = bs.BusinessServiceId --Code added to show DrugScreeningOrdered column against ticket #114889
        WHERE (
                  (
                      (
                          O.IsReviewRequired = 0
                          OR O.IsReviewRequired IS NULL
                      )
                      AND ISNULL(T.IsActive, 1) = 1
                  )
                  OR O.IsReviewRequired = 1
              )
              AND ISNULL(A.IsConfirmed, 0) = 0
              AND O.Attention NOT LIKE '%precheck.com%'
              AND A.Email NOT LIKE '%precheck.com%'
              AND O.ClientId = @CLNO
              AND ISNULL(A.IsActive, 1) = 1
              AND O.CreateDate >= @StartDate
              AND O.CreateDate <= DATEADD(d, 1, @EndDate)
              AND ISNULL(O.BatchOrderDetailId, 0) = CASE
                                                        WHEN @ExcludeMCIC = 1 THEN
                                                            0
                                                        ELSE
                                                            ISNULL(O.BatchOrderDetailId, 0)
                                                    END;
    END;
END;

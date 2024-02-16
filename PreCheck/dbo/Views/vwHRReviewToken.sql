
CREATE VIEW [dbo].[vwHRReviewToken]
AS
SELECT IntegrationRequestId,TokenId,ISNULL(ROW_NUMBER() OVER(ORDER BY ReviewRequestID DESC), -1) AS RowID
FROM
(
SELECT        MAX(rr.ReviewRequestId) as ReviewRequestId,MAX(os.IntegrationRequestId) as IntegrationRequestId , MAX(rr.SecurityTokenId) AS TokenId
FROM            Enterprise.Staging.ReviewRequest AS rr INNER JOIN
                         Enterprise.Staging.ApplicantStage AS apps ON rr.StagingApplicantId = apps.StagingApplicantId INNER JOIN
                         Enterprise.Staging.OrderStage AS os ON apps.StagingOrderId = os.StagingOrderId
)x

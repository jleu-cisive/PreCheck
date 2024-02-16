


-- =============================================
-- Author:		Doug DeGenaro/Santosh Chapyala
-- Create date: 07/04/2020
-- Description:	Retrieves the HR Review Link to use in the Callbacks to Infor/HCA
-- =============================================
CREATE FUNCTION [Enterprise].[GetHRReviewTokenByIntegrationRequestId]
(	
	-- Add the parameters for the function here
	@requestId int
	
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	WITH Integration AS
(
 SELECT        IntegrationRequestId, TokenId,
    ROW_NUMBER() OVER (PARTITION BY IntegrationRequestId ORDER BY ReviewRequestID DESC) AS RowNumber
 FROM   (SELECT (rr.ReviewRequestId) AS ReviewRequestId, (os.IntegrationRequestId) AS IntegrationRequestId, (rr.SecurityTokenId) AS TokenId
   FROM Enterprise.Staging.ReviewRequest AS rr INNER JOIN
    Enterprise.Staging.ApplicantStage AS apps ON rr.StagingApplicantId = apps.StagingApplicantId INNER JOIN
    Enterprise.Staging.OrderStage AS os ON apps.StagingOrderId = os.StagingOrderId) x
 where IntegrationRequestId is not null
)
SELECT I.IntegrationRequestId, I.TokenId, ISNULL(ROW_NUMBER() OVER (ORDER BY IntegrationRequestId DESC), - 1) AS RowID FROM Integration AS I  WHERE RowNumber = 1
and IntegrationRequestId = @requestId

)

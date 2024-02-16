/***************************************************************************************************
Procedure:          [dbo].[CICActivityReportWithLinks]
Create Date:        2024-02-09
Author:             Cameron DeCook
Description:        Orders entered via CIC or web order for Client Schedule (217 affiliate). Ticket #123508
****************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author              Comments
------------------- ------------------- ------------------------------------------------------------
2024-02-09          Cameron DeCook      Initial Creation
***************************************************************************************************/
CREATE PROCEDURE [dbo].[CICActivityReportWithLinks]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT S.ClientId AS [ClientID],
           S.FacilityId AS FacilityCLNO,
           ISNULL(REPLACE(LTRIM(RTRIM(sas.FirstName)), ',', ' '), ' ') AS [Applicant First Name],
           ISNULL(REPLACE(LTRIM(RTRIM(sas.LastName)), ',', ' '), ' ') AS [Applicant Last Name],
           ISNULL(REPLACE(LTRIM(RTRIM(sas.Email)), ',', ' '), ' ') AS [Applicant Email],
           ISNULL(FORMAT(S.CreateDate, 'yyyy-MM-dd hh:mm:ss tt'), ' ') AS [Invite Sent On],
           ISNULL(FORMAT(cc.ClientCertUpdated, 'yyyy-MM-dd hh:mm:ss tt'), ' ') AS [Certification Completed],
           ISNULL(REPLACE(LTRIM(RTRIM(S.Attention)), ',', ' '), ' ') AS [Ordered by],
           [Order Status] = CASE
                                WHEN A.ApStatus = 'M' THEN
                                    'OnHold'
                                WHEN A.ApStatus = 'P' THEN
                                    'In Progress'
                                WHEN A.ApStatus = 'F' THEN
                                    'Investigation Concluded'
                            END,
           ISNULL(REPLACE(LTRIM(RTRIM(S.OrderNumber)), ',', ' '), ' ') AS [Report Number],
           CandidateLink = CASE
                               WHEN T.TokenId IS NOT NULL
                                    AND S.OrderNumber IS NULL THEN
                                   CONCAT(
                                             'https://candidate.precheck.com/CIC/Authenticate?token=',
                                             CONVERT(
                                                        VARCHAR(100),
                                                        ISNULL(REPLACE(LTRIM(RTRIM(T.TokenId)), ',', ' '), '')
                                                    )
                                         )
                               ELSE
                                   ''
                           END
    FROM Enterprise.Staging.OrderStage S (NOLOCK)
        INNER JOIN Enterprise.PreCheck.vwClient c
            ON S.FacilityId = c.ClientId
        LEFT OUTER JOIN [Enterprise].Staging.ApplicantStage sas WITH (NOLOCK)
            ON S.StagingOrderId = sas.StagingOrderId
        LEFT OUTER JOIN PRECHECK.dbo.Appl A WITH (NOLOCK)
            ON A.APNO = S.OrderNumber
        LEFT JOIN Enterprise.[Security].[vwTokenStagingApplicantId] AS T WITH (NOLOCK)
            ON sas.StagingApplicantId = T.StagingApplicantId
        LEFT OUTER JOIN
        (
            SELECT MAX(ClientCertificationId) AS ClientCertificationId,
                   APNO,
                   ClientCertUpdated,
                   ClientCertReceived,
                   ClientCertBy
            FROM PRECHECK.dbo.ClientCertification WITH (NOLOCK)
            GROUP BY APNO,
                     ClientCertUpdated,
                     ClientCertReceived,
                     ClientCertBy
        ) AS cc
            ON A.APNO = cc.APNO
               AND cc.ClientCertReceived = 'Yes'
    WHERE CAST(S.CreateDate AS DATE)
          BETWEEN DATEADD(DAY, -30, CAST(GETDATE() AS DATE)) AND CAST(GETDATE() AS DATE)
          AND ISNULL(sas.IsActive, 1) = 1
          AND S.DASourceId = 2
          AND c.AffiliateId = 217;
    SET NOCOUNT OFF;
END;


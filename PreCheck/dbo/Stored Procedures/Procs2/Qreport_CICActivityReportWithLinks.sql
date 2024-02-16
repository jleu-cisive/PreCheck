/***************************************************************************************************
Procedure:          [dbo].[Qreport_CICActivityReportWithLinks]
Create Date:        2024-02-09
Author:             Cameron DeCook
Description:        Orders entered via CIC or web order. Ticket #123508
****************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author              Comments
------------------- ------------------- ------------------------------------------------------------
2024-02-09          Cameron DeCook      Initial Creation
***************************************************************************************************/
CREATE PROCEDURE [dbo].[Qreport_CICActivityReportWithLinks]
    @StartDate DATE,
    @EndDate DATE,
    @ClientID VARCHAR(MAX) = '0',
    @FacilityID VARCHAR(MAX) = '0',
    @AffiliateID VARCHAR(MAX) = '0'
AS
BEGIN
    SET NOCOUNT ON;

    IF (@ClientID = '0' OR @ClientID IS NULL OR @ClientID = 'null')
    BEGIN
        SET @ClientID = '';
    END;

    IF (@FacilityID = '0' OR @FacilityID IS NULL OR @FacilityID = 'null')
    BEGIN
        SET @FacilityID = '';
    END;

    IF (@AffiliateID = '0' OR @AffiliateID IS NULL OR @AffiliateID = 'null')
    BEGIN
        SET @AffiliateID = '';
    END;


    SELECT S.ClientId AS [ClientID],
           S.FacilityId AS FacilityCLNO,
           sas.FirstName AS [Applicant First Name],
           sas.LastName AS [Applicant Last Name],
           sas.Email AS [Applicant Email],
           FORMAT(S.CreateDate, 'yyyy-MM-dd hh:mm:ss tt') AS [Invite Sent On],
           FORMAT(cc.ClientCertUpdated, 'yyyy-MM-dd hh:mm:ss tt') AS [Certification Completed],
           S.Attention AS [Ordered by],
           [Order Status] = CASE
                                WHEN A.ApStatus = 'M' THEN
                                    'OnHold'
                                WHEN A.ApStatus = 'P' THEN
                                    'In Progress'
                                WHEN A.ApStatus = 'F' THEN
                                    'Investigation Concluded'
                            END,
           S.OrderNumber AS [Report Number],
           CandidateLink = CASE
                               WHEN T.TokenId IS NOT NULL
                                    AND S.OrderNumber IS NULL THEN
                                   CONCAT(
                                             'https://candidate.precheck.com/CIC/Authenticate?token=',
                                             CONVERT(VARCHAR(100), ISNULL(T.TokenId, ''))
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
          BETWEEN @StartDate AND @EndDate
          AND ISNULL(sas.IsActive, 1) = 1
          AND S.DASourceId = 2
          AND c.ClientId NOT IN ( 3468, 2135, 15250 )
          AND
          (
              ISNULL(@ClientID, '') = ''
              OR c.ClientId IN
                 (
                     SELECT splitdata FROM dbo.fnSplitString(@ClientID, ':')
                 )
          )
          AND
          (
              ISNULL(@AffiliateID, '') = ''
              OR c.AffiliateId IN
                 (
                     SELECT value FROM dbo.fn_Split(@AffiliateID, ':')
                 )
          )
          AND
          (
              ISNULL(@FacilityID, '') = ''
              OR S.FacilityId IN
                 (
                     SELECT splitdata FROM dbo.fnSplitString(@FacilityID, ':')
                 )
          );
    SET NOCOUNT OFF;
END;
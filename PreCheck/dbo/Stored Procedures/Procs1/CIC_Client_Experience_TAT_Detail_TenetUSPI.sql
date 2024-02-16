-- ===============================================================================
-- Author:		Cameron DeCook
-- Create date: 05/3/2023
-- Description:	Scheduled Report to Calculate Experience and TAT for Tenet & USPI.
--			    Sent every 1st of the month for the prior month.
-- Execution: EXEC CIC_Client_Experience_TAT_Detail_TenetUSPI
-- ===============================================================================
CREATE PROC [dbo].[CIC_Client_Experience_TAT_Detail_TenetUSPI]
AS
BEGIN
    DECLARE @StartDate DATE = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0),
            @EndDate DATE = DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE()) - 1, -1);

    SET NOCOUNT ON;


    SELECT DISTINCT
           isnull(CAST(c.CLNO AS VARCHAR(50)),' ') AS [Client Number],
           isnull(REPLACE(LTRIM(RTRIM(c.Name)), ',', ' '),' ') AS [Client Name],
           isnull(REPLACE(LTRIM(RTRIM(REPLACE(A.ClientApplicantNO,'/',''))), ',', ' '),' ') AS [Candidate ID],
           isnull(REPLACE(LTRIM(RTRIM(RA.Affiliate)), ',', ' '),' ') AS [Affiliate Name],
           isnull(A.APNO,' ') AS [Report Number],
           isnull(REPLACE(LTRIM(RTRIM(A.First)), ',', ' '),' ') AS [Applicant First Name],
           isnull(REPLACE(LTRIM(RTRIM(A.Last)), ',', ' '),' ') AS [Applicant Last Name],
           isnull(REPLACE(LTRIM(RTRIM(A.Email)), ',', ' '),' ') AS [Applicant Email],
           isnull(FORMAT(S.CreateDate, 'yyyy-MM-dd hh:mm:ss tt'),' ') AS [Invite Sent],
           isnull(FORMAT(RR.CreateDate, 'yyyy-MM-dd hh:mm:ss tt'),' ') AS [Invite Completed],
           isnull(REPLACE(LTRIM(RTRIM(Replace(Replace(A.Attn,CHAR(10),''),CHAR(13),''))), ',', ' '),' ') AS [Recruiter Name],
           isnull(FORMAT(cc.ClientCertUpdated, 'yyyy-MM-dd hh:mm:ss tt'),' ') AS [Certification Completed],
           isnull(FORMAT(A.ApDate, 'yyyy-MM-dd hh:mm:ss tt'),' ') AS [Received Date],
           isnull(FORMAT(A.OrigCompDate, 'yyyy-MM-dd hh:mm:ss tt'),' ') AS [Original Close Date],
           isnull(FORMAT(A.ReopenDate, 'yyyy-MM-dd hh:mm:ss tt'),' ') AS [ReOpen Date],
           isnull(FORMAT(A.CompDate, 'yyyy-MM-dd hh:mm:ss tt'),' ') AS [Completed Date],
           isnull([dbo].[ElapsedBusinessDays_2](A.ApDate, A.OrigCompDate),0) AS [Report TAT],
           isnull([dbo].[ElapsedBusinessDaysInDecimal](O.CreateDate, RR.CreateDate),0) AS [Invite TAT],
           isnull(ISNULL(F.IsOneHR, 0),0) AS [IsOneHR],
           isnull([dbo].[ElapsedBusinessDays_2](S.CreateDate, A.OrigCompDate),0) AS [Invite to Original Close TAT – Without Reopen],
           isnull([dbo].[ElapsedBusinessDays_2](S.CreateDate, A.CompDate),0) AS [Total Client TAT (Invite to Last Close Date)],
           ISNULL(CASE
               WHEN
               (
                   X.RuleGroup IS NOT NULL
                   OR LEN(X.RuleGroup) > 0
               ) THEN
                   'True'
               ELSE
                   'False'
           END,' ') AS [Adverse/Dispute],
           ISNULL(CASE
               WHEN CONVERT(   BIT,
                               CASE
                                   WHEN O.BatchOrderDetailId IS NULL THEN
                                       0
                                   ELSE
                                       1
                               END
                           ) = 0 THEN
                   'False'
               ELSE
                   'True'
           END,' ') AS MCIC
    FROM PRECHECK.dbo.Appl AS A (NOLOCK)
        INNER JOIN PRECHECK.dbo.Client AS c (NOLOCK)
            ON A.CLNO = c.CLNO
        INNER JOIN PRECHECK.dbo.refAffiliate AS RA WITH (NOLOCK)
            ON c.AffiliateID = RA.AffiliateID
        LEFT JOIN Enterprise.dbo.[Order] AS O (NOLOCK)
            ON A.APNO = O.OrderNumber
        LEFT JOIN Enterprise.Staging.OrderStage S (NOLOCK)
            ON O.OrderId = S.OrderId
               AND O.DASourceId = 2
        LEFT JOIN [Enterprise].Staging.ApplicantStage sas WITH (NOLOCK)
            ON S.StagingOrderId = sas.StagingOrderId
        LEFT OUTER JOIN [Enterprise].Staging.ReviewRequest RR WITH (NOLOCK)
            ON RR.StagingApplicantId = sas.StagingApplicantId
               AND RR.IsComplete = 1
        LEFT OUTER JOIN PRECHECK.dbo.ClientCertification AS cc (NOLOCK)
            ON A.APNO = cc.APNO
               AND cc.ClientCertReceived = 'Yes'
        LEFT OUTER JOIN HEVN.dbo.Facility F (NOLOCK)
            ON (
                   ISNULL(A.DeptCode, 0) = F.FacilityNum
                   OR A.CLNO = F.FacilityCLNO
               )
        LEFT OUTER JOIN Enterprise.[dbo].[vwAdverseActionReason] AS X
            ON A.APNO = X.APNO
    WHERE A.OrigCompDate
          BETWEEN @StartDate AND @EndDate
          AND c.WebOrderParentCLNO IN ( 12444, 14756 ) 
		  
		  
END;

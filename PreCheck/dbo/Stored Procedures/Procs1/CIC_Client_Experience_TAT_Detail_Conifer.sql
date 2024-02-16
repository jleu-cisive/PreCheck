-- ===============================================================================
-- Author:		Cameron DeCook
-- Create date: 05/3/2023
-- Description:	Scheduled Report to Calculate Experience and TAT for Conifer Only.
--			    Sent every 1st of the month for the prior month.
-- Execution: EXEC CIC_Client_Experience_TAT_Detail_Conifer
-- ===============================================================================
CREATE PROC dbo.CIC_Client_Experience_TAT_Detail_Conifer
AS
BEGIN
    DECLARE @StartDate DATE = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0),
            @EndDate DATE = DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE()) - 1, -1);

    SET NOCOUNT ON;


    SELECT DISTINCT
           c.CLNO AS [Client Number],
           REPLACE(c.Name, ',', ' ') AS [Client Name],
           REPLACE(A.ClientApplicantNO, ',',' ') AS [Candidate ID],
           REPLACE(RA.Affiliate, ',',' ') AS [Affiliate Name],
           A.APNO AS [Report Number],
           REPLACE(A.First, ',',' ') AS [Applicant First Name],
           REPLACE(A.Last, ',',' ') AS [Applicant Last Name],
		   REPLACE(A.Email, ',',' ') AS [Applicant Email],
           FORMAT(S.CreateDate, 'MM/dd/yyyy hh:mm') AS [Invite Sent],
           FORMAT(A.CreatedDate, 'MM/dd/yyyy hh:mm') AS [Invite Completed],
           REPLACE(A.Attn, ',', ' ') AS [Recruiter Name],
           FORMAT(cc.ClientCertUpdated, 'MM/dd/yyyy hh:mm') AS [Certification Completed],
           FORMAT(A.ApDate, 'MM/dd/yyyy hh:mm') AS [Received Date],
           FORMAT(A.OrigCompDate, 'MM/dd/yyyy hh:mm') AS [Original Close Date],
           FORMAT(A.ReopenDate, 'MM/dd/yyyy hh:mm') AS [ReOpen Date],
           FORMAT(A.CompDate, 'MM/dd/yyyy hh:mm') AS [Completed Date],
           [dbo].[ElapsedBusinessDays_2](A.ApDate, A.OrigCompDate) AS [Report TAT],
           ISNULL(F.IsOneHR, 0) AS [IsOneHR],
           [dbo].[ElapsedBusinessDays_2](S.CreateDate, A.OrigCompDate) AS [Invite to Original Close TAT Without Reopen],
           [dbo].[ElapsedBusinessDays_2](S.CreateDate, A.CompDate) AS [Total Client TAT (Invite to Last Close Date)],
           CASE
               WHEN
               (
                   X.RuleGroup IS NOT NULL
                   OR LEN(X.RuleGroup) > 0
               ) THEN
                   'True'
               ELSE
                   'False'
           END AS [Adverse/Dispute],
           CASE
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
           END AS MCIC
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
          AND c.CLNO IN ( 12579, 12580, 17558, 12486, 17556, 12449, 17519, 17551, 17590, 17550, 17537, 17563 )

END

-- ==========================================================================================
-- Author:		Deepak Vodethela
-- Create date: 09/25/2018
-- Description:	Report to Calculate Client Experience and TAT
-- Execution: EXEC CIC_Client_Experience_TAT_Detail '09/01/2018', '09/30/2018', 0, 0, 0
-- Modified By: Deepak Vodethela
-- Modified Date: 07/31/2019
-- Description: Req#55742 - Add the following new columns
--									1.) [Invite to Original Close TAT – Without Reopen] - Business Days elapsed from Date of Invite to Date of Original Close Date i,e. OrigCompDate
--									2.) [Total Client TAT (Invite to Last Close Date)] - Business Days elapsed from Date of Invite to Last Close Date i.e. CompDate
--									3.) [Adverse/Dispute] - If PreAdverse / Adverse has ever  happened for a Report -  True / False
-- Execution: EXEC [CIC_Client_Experience_TAT_Detail] '01/01/2020', '01/05/2020', 0, 4, 
--			  EXEC [CIC_Client_Experience_TAT_Detail] '08/01/2021', '08/05/2021', 0, 4 
-- Modified By Doug DeGenaro 10/22/2018 - Please add columns for "Applicant First Name" and "Applicant Last Name" in between the "Report Number" and "Invite Sent" columns.  Please also add a "Recruiter Name" (should be the name of the person who ordered the background or at least who is recorded as the Attn: To in OASIS) column in between the "Invite Completed" and "Certification Completed" columns.  Thank you!
-- Modified by Radhika Dereddy 02/21/2020 To exclude MCIC batches.
-- Modified by Radhika Dereddy on 02/27/2020 to Include MCIC as a Column
-- Modified by radhika Dereddy on 08/19/2021 to change the logic of how the Enterprise tables are utilized along with the precheck.vwclient.
-- Modified by Cameron DeCook on 5/18/2023 HDT#93017 Updating Received Date and TAT to use Apdate. Also changing date format and allowing
--										   for multi-client selection. Candidate ID & Email added as well
-- ============================================================================================
CREATE PROCEDURE [dbo].[CIC_Client_Experience_TAT_Detail]
    @StartDate DATE,
    @EndDate DATE,
    @CLNO VARCHAR(MAX) = '',
    @Affiliate INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    IF @CLNO = ''
    BEGIN
        SET @CLNO = NULL;
    END;


    -- Insert statements for procedure here
    SELECT DISTINCT
           c.CLNO AS [Client Number],
           c.Name AS [Client Name],
           A.ClientApplicantNO AS [Candidate ID],
           RA.Affiliate AS [Affiliate Name],
           A.APNO AS [Report Number],
           A.First AS [Applicant First Name],
           A.Last AS [Applicant Last Name],
           A.Email AS [Applicant Email],
           FORMAT(S.CreateDate, 'MM/dd/yyyy hh:mm') AS [Invite Sent],
           FORMAT(A.CreatedDate, 'MM/dd/yyyy hh:mm') AS [Invite Completed],
           A.Attn AS [Recruiter Name],
           FORMAT(cc.ClientCertUpdated, 'MM/dd/yyyy hh:mm') AS [Certification Completed],
           FORMAT(A.ApDate, 'MM/dd/yyyy hh:mm') AS [Received Date],
           FORMAT(A.OrigCompDate, 'MM/dd/yyyy hh:mm') AS [Original Close Date],
           FORMAT(A.ReopenDate, 'MM/dd/yyyy hh:mm') AS [ReOpen Date],
           FORMAT(A.CompDate, 'MM/dd/yyyy hh:mm') AS [Completed Date],
           [dbo].[ElapsedBusinessDays_2](A.ApDate, A.OrigCompDate) AS [Report TAT],
           ISNULL(F.IsOneHR, 0) AS [IsOneHR],
           [dbo].[ElapsedBusinessDays_2](S.CreateDate, A.OrigCompDate) AS [Invite to Original Close TAT – Without Reopen],
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
          BETWEEN @StartDate AND DATEADD(d, 1, @EndDate)
          AND
          (
              @CLNO IS NULL
              OR c.CLNO IN
                 (
                     SELECT value FROM fn_Split(@CLNO, ':')
                 )
          )
          AND c.AffiliateID = IIF(@Affiliate = 0, c.AffiliateID, @Affiliate);

END;

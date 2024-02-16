-- =============================================
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
-- Execution: EXEC CIC_Client_Experience_TAT_Detail '01/01/2020', '01/05/2020', 0, 4, 0
--			  EXEC CIC_Client_Experience_TAT_Detail '03/01/2019', '08/05/2019', 0, 4, 0
-- Modified By Doug DeGenaro 10/22/2018 - Please add columns for "Applicant First Name" and "Applicant Last Name" in between the "Report Number" and "Invite Sent" columns.  Please also add a "Recruiter Name" (should be the name of the person who ordered the background or at least who is recorded as the Attn: To in OASIS) column in between the "Invite Completed" and "Certification Completed" columns.  Thank you!
-- Modified by Radhika Dereddy 02/21/2020 To exclude MCIC batches.
-- Modified by Radhika Dereddy on 02/27/2020 to Include MCIC as a Column
-- =============================================
CREATE PROCEDURE [dbo].[CIC_Client_Experience_TAT_Detail_08192021]
--DECLARE
@StartDate DATE,
@EndDate DATE,
@clno int,
@Affiliate int,
@IsOneHR bit --HAhmed 10/22/2018 Add new parameter IsOneHR
--@ExcludeMCIC bit =1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT DISTINCT vc.ClientId AS [Client Number], vc.ClientName AS [Client Name],RA.Affiliate AS [Affiliate Name],it.OrderNumber AS [Report Number]
			 ,a.First as [Applicant First Name],
			 a.Last as [Applicant Last Name]
			 --HAhmed 10/22/2018 display Military time
			,(SELECT CONVERT(VARCHAR, it.InvitationDate, 101) + ' ' + CONVERT(CHAR(5),it.InvitationDate, 108)) AS [Invite Sent]--,it.InvitationDate AS [Invite Sent]
			,(SELECT CONVERT(VARCHAR, a.CreatedDate, 101) + ' ' + CONVERT(CHAR(5),a.CreatedDate, 108)) AS [Invite Completed]--, a.CreatedDate AS [Invite Completed]
			,a.Attn as [Recruiter Name]
			,(SELECT CONVERT(VARCHAR, cc.ClientCertUpdated, 101) + ' ' + CONVERT(CHAR(5),cc.ClientCertUpdated, 108)) AS [Certification Completed]--, cc.ClientCertUpdated AS [Certification Completed], 
			,(SELECT CONVERT(VARCHAR, a.CreatedDate, 101) + ' ' + CONVERT(CHAR(5),a.CreatedDate, 108)) AS [Received Date]--,a.CreatedDate AS [Recived Date]
			,(SELECT CONVERT(VARCHAR, a.OrigCompDate, 101) + ' ' + CONVERT(CHAR(5),a.OrigCompDate, 108)) AS [Original Close Date]--,a.OrigCompDate AS [Original Close Date]
			,(SELECT CONVERT(VARCHAR, a.ReopenDate, 101) + ' ' + CONVERT(CHAR(5),a.ReopenDate, 108)) AS [ReOpen Date]--,a.ReopenDate AS [ReOpen Date]
			,(SELECT CONVERT(VARCHAR, a.CompDate, 101) + ' ' + CONVERT(CHAR(5),a.CompDate, 108)) AS [Completed Date]--, a.CompDate AS [Completed Date]
			,[dbo].[ElapsedBusinessDays_2](a.CreatedDate,a.OrigCompDate) AS [Report TAT]
			--HAhmed 10/22/2018 Add new column IsOneHR
			,ISNULL(F.IsOneHR,0) AS [IsOneHR],
			[dbo].[ElapsedBusinessDays_2](it.InvitationDate,a.OrigCompDate) AS [Invite to Original Close TAT – Without Reopen],
			[dbo].[ElapsedBusinessDays_2](it.InvitationDate,a.CompDate) AS [Total Client TAT (Invite to Last Close Date)],
			CASE WHEN (X.RuleGroup IS NOT NULL OR LEN(X.RuleGroup) > 0) THEN 'True' ELSE 'False' END AS [Adverse/Dispute],
			CASE WHEN ISNULL(it.IsMCICOrder ,0) = 0 THEN 'False' ELSE 'True' END as MCIC
       FROM Enterprise.Report.InvitationTurnaround AS it(NOLOCK) 
       INNER JOIN Enterprise.PreCheck.vwClient AS vc(NOLOCK) ON it.facilityID = vc.ClientId
       INNER JOIN dbo.refAffiliate AS RA WITH (NOLOCK) ON vc.AffiliateId = RA.AffiliateID
       INNER JOIN PreCheck.dbo.Appl AS a(NOLOCK) ON it.OrderNumber = a.APNO
       LEFT OUTER JOIN PreCheck.dbo.ClientCertification AS cc(NOLOCK) ON a.APNO = cc.APNO AND CC.ClientCertReceived = 'Yes'
       LEFT JOIN HEVN.dbo.Facility F (NOLOCK) ON (ISNULL(A.DeptCode,0) = F.FacilityNum  OR A.CLNO = F.FacilityCLNO)
       LEFT OUTER JOIN Enterprise.[dbo].[vwAdverseActionReason] AS X ON A.APNO = X.APNO
       WHERE CAST(OrigCompDate as Date) BETWEEN @StartDate AND DATEADD(d,1,@EndDate)
              AND vc.ClientId = IIF(@CLNO=0, vc.ClientId, @CLNO) 
              AND vc.AffiliateId = IIF(@Affiliate=0, vc.AffiliateId, @Affiliate) 
              --AND F.IsOneHR = IIF(@IsOneHR=0, ISNULL(F.IsOneHR,0), @IsOneHR)
              AND ISNULL(F.IsOneHR,0) = ISNULL(@IsOneHR, 0)
			 -- AND ISNULL(it.IsMCICOrder ,0) = CASE WHEN @ExcludeMCIC=1 THEN 0 ELSE it.IsMCICOrder  END

END

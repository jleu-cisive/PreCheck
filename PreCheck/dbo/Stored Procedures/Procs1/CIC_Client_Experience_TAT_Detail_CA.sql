
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
-- Execution: EXEC [CIC_Client_Experience_TAT_Detail] '01/01/2020', '01/05/2020', 0, 4, 
--			  EXEC [CIC_Client_Experience_TAT_Detail] '08/01/2021', '08/05/2021', 0, 4 
-- Modified By Doug DeGenaro 10/22/2018 - Please add columns for "Applicant First Name" and "Applicant Last Name" in between the "Report Number" and "Invite Sent" columns.  Please also add a "Recruiter Name" (should be the name of the person who ordered the background or at least who is recorded as the Attn: To in OASIS) column in between the "Invite Completed" and "Certification Completed" columns.  Thank you!
-- Modified by Radhika Dereddy 02/21/2020 To exclude MCIC batches.
-- Modified by Radhika Dereddy on 02/27/2020 to Include MCIC as a Column
-- Modified by radhika Dereddy on 08/19/2021 to change the logic of how the Enterprise tables are utilized along with the precheck.vwclient.
-- =============================================
CREATE PROCEDURE [dbo].[CIC_Client_Experience_TAT_Detail_CA]
@StartDate DATE,
@EndDate DATE,
@clno int,
@Affiliate int
--,@IsOneHR bit 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT DISTINCT c.CLNO AS [Client Number]
			,c.Name AS [Client Name]
			,RA.Affiliate AS [Affiliate Name]
			,a.APNO AS [Report Number]
			,a.First as [Applicant First Name]
			,a.Last as [Applicant Last Name]
			,FORMAT(s.CreateDate,			'MM/dd/yyyy hh:mm tt') AS [Invite Sent]
			,FORMAT(a.CreatedDate,			'MM/dd/yyyy hh:mm tt') AS [Invite Completed]
			,a.Attn as [Recruiter Name]
	        ,FORMAT(cc.ClientCertUpdated,	'MM/dd/yyyy hh:mm tt') AS [Certification Completed]
			,FORMAT(a.CreatedDate,			'MM/dd/yyyy hh:mm tt') AS [Recived Date]
			,FORMAT(a.OrigCompDate,			'MM/dd/yyyy hh:mm tt') AS [Original Close Date]
			,FORMAT(a.ReopenDate,			'MM/dd/yyyy hh:mm tt') AS [ReOpen Date]
			,FORMAT(a.CompDate,				'MM/dd/yyyy hh:mm tt') AS [Completed Date]
			,[dbo].[ElapsedDaysInDecimal](s.CreateDate,a.CreatedDate) AS [Invitation TAT]
			,[dbo].[ElapsedDaysInDecimal](a.CreatedDate,cc.ClientCertUpdated) AS [Certification TAT]
			,[dbo].[ElapsedBusinessDaysInDecimal](a.CreatedDate,a.OrigCompDate) AS [Report TAT]
			,[dbo].[ElapsedDaysInDecimal](
			      (select  min(date)  from dbo.AdverseAction aa(nolock)
				    join AdverseActionHistory aah ON aa.AdverseActionID = aah.AdverseActionID and aah.statusId in( 14,30) 
					where  a.APNO = aa.APNO
					 )
			  	,a.CompDate) AS [Adverse TAT]
			,[dbo].[ElapsedDaysInDecimal](s.CreateDate,a.CreatedDate) +
			[dbo].[ElapsedDaysInDecimal](a.CreatedDate,cc.ClientCertUpdated) +
			[dbo].[ElapsedBusinessDaysInDecimal](a.CreatedDate,a.OrigCompDate)+
			[dbo].[ElapsedDaysInDecimal](
			      (select  min(date)  from dbo.AdverseAction aa(nolock)
				    join AdverseActionHistory aah ON aa.AdverseActionID = aah.AdverseActionID and aah.statusId in( 14,30) 
					where  a.APNO = aa.APNO
					 )
			  	,a.CompDate) AS [Agregated TAT]
			,ISNULL(F.IsOneHR,0) AS [IsOneHR],
			[dbo].[ElapsedDaysInDecimal](s.CreateDate,a.OrigCompDate) AS [Invite to Original Close TAT – Without Reopen],
			[dbo].[ElapsedDaysInDecimal](s.CreateDate,a.CompDate) AS [Total Client TAT (Invite to Last Close Date)],
			CASE WHEN (X.RuleGroup IS NOT NULL OR LEN(X.RuleGroup) > 0) THEN 'True' ELSE 'False' END AS [Adverse/Dispute],
			CASE WHEN CONVERT(BIT,CASE WHEN o.BatchOrderDetailId IS NULL THEN 0 ELSE 1 END) = 0 THEN 'False' ELSE 'True' END as MCIC
       FROM  PreCheck.dbo.Appl AS A(NOLOCK) 
       INNER JOIN PreCheck.dbo.Client AS c(NOLOCK) ON a.CLNO = c.CLNO		
       INNER JOIN Precheck.dbo.refAffiliate AS RA WITH (NOLOCK) ON c.AffiliateId = RA.AffiliateID
       LEFT JOIN Enterprise.dbo.[Order] AS O(NOLOCK) ON a.APNO = o.OrderNumber
	   LEFT JOIN Enterprise.Staging.OrderStage S(nolock) on O.OrderId = S.OrderId and O.DASourceId=2
       LEFT OUTER JOIN PreCheck.dbo.ClientCertification AS cc(NOLOCK) ON a.APNO = cc.APNO AND CC.ClientCertReceived = 'Yes'
       LEFT OUTER JOIN HEVN.dbo.Facility F (NOLOCK) ON (ISNULL(A.DeptCode,0) = F.FacilityNum  AND IsNULL(A.CLNO,0) = F.FacilityCLNO)
       LEFT OUTER JOIN Enterprise.[dbo].[vwAdverseActionReason] AS X ON A.APNO = X.APNO
       WHERE a.OrigCompDate BETWEEN @StartDate AND DATEADD(d,1,@EndDate)
              AND c.CLNO = IIF(@CLNO=0, C.CLNO, @CLNO) 
              AND c.AffiliateId = IIF(@Affiliate=0, c.AffiliateId, @Affiliate) 
              --AND ISNULL(F.IsOneHR,0) = ISNULL(@IsOneHR, 0)

END


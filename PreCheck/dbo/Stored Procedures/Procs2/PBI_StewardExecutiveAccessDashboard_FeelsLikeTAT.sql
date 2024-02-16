-- =============================================
/*
-- Author      : Vairavan  A
-- Create date : 11/22/2022
-- Description : To get data for Applications dataset of StewardExecutiveAccessDashboard Power Bi report
EXEC [PBI_StewardExecutiveAccessDashboard_FeelsLikeTAT] 2019,228,15382 --30sec
*/
-- =============================================
CREATE PROCEDURE dbo.PBI_StewardExecutiveAccessDashboard_FeelsLikeTAT
-- Add the parameters for the stored procedure here
@Year int,
@AffiliateID int,
@weborderparentclno smallint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	SET NOCOUNT ON;
	
;SELECT distinct a.APNO, vc.ClientId AS [Client Number], vc.ClientName AS [Client Name],RA.Affiliate AS [Affiliate Name],
			(SELECT CONVERT(VARCHAR, it.InvitationDate, 101) + ' ' + CONVERT(CHAR(5),it.InvitationDate, 108)) AS [Invite Sent]
			,(SELECT CONVERT(VARCHAR, a.CreatedDate, 101) + ' ' + CONVERT(CHAR(5),a.CreatedDate, 108)) AS [Invite Completed]		
			,(SELECT CONVERT(VARCHAR, cc.ClientCertUpdated, 101) + ' ' + CONVERT(CHAR(5),cc.ClientCertUpdated, 108)) AS [Certification Completed]			
			,(SELECT CONVERT(VARCHAR, a.CreatedDate, 101) + ' ' + CONVERT(CHAR(5),a.CreatedDate, 108)) AS [Received Date]
			,(SELECT CONVERT(VARCHAR, a.OrigCompDate, 101) + ' ' + CONVERT(CHAR(5),a.OrigCompDate, 108)) AS [Original Close Date]			
			,(SELECT CONVERT(VARCHAR, a.ReopenDate, 101) + ' ' + CONVERT(CHAR(5),a.ReopenDate, 108)) AS [ReOpen Date]
			,(SELECT CONVERT(VARCHAR, a.CompDate, 101) + ' ' + CONVERT(CHAR(5),a.CompDate, 108)) AS [Completed Date]
			,(DATEDIFF(dd, it.invitationdate, a.CreatedDate) + 1)  -(DATEDIFF(wk, it.invitationdate, a.CreatedDate) * 2)   AS [INVITE TAT]
			,(DATEDIFF(dd, a.CreatedDate, cc.ClientcertUpdated) + 1)  -(DATEDIFF(wk, a.CreatedDate, cc.ClientcertUpdated) * 2) AS [CERTIFICATION TAT]
			,(DATEDIFF(dd, cc.ClientCertUpdated, a.OrigCompDate) + 1)  -(DATEDIFF(wk, cc.ClientCertUpdated, a.OrigCompDate) * 2)  -(CASE WHEN DATENAME(dw, cc.ClientCertUpdated) = 'Sunday' THEN 1 ELSE 0 END)  -(CASE WHEN DATENAME(dw, a.OrigCompDate) = 'Saturday' THEN 1 ELSE 0 END) AS [PRECHECK TAT]
			,[dbo].[ElapsedBusinessDays_2](a.CreatedDate,a.OrigCompDate) AS [Report TAT]
			,[dbo].[ElapsedBusinessDays_2](it.InvitationDate,a.OrigCompDate) AS [Invite to Original Close TAT – Without Reopen],
			[dbo].[ElapsedBusinessDays_2](it.InvitationDate,a.CompDate) AS [Total Client TAT (Invite to Last Close Date)],
			CASE WHEN (X.RuleGroup IS NOT NULL OR LEN(X.RuleGroup) > 0) THEN 'True' ELSE 'False' END AS [Adverse/Dispute]
       FROM Enterprise.Report.InvitationTurnaround AS it with (NOLOCK)
       INNER JOIN Enterprise.PreCheck.vwClient AS vc with(NOLOCK) ON it.facilityID = vc.ClientId
       INNER JOIN Precheck.dbo.refAffiliate AS RA WITH (NOLOCK) ON vc.AffiliateId = RA.AffiliateID
       INNER JOIN PreCheck.dbo.Appl AS a with(NOLOCK) ON it.OrderNumber = a.APNO
       LEFT OUTER JOIN PreCheck.dbo.ClientCertification AS cc with(NOLOCK) ON a.APNO = cc.APNO AND CC.ClientCertReceived = 'Yes'
       --LEFT JOIN HEVN.dbo.Facility F (NOLOCK) ON (ISNULL(A.DeptCode,0) = F.FacilityNum  OR A.CLNO = F.FacilityCLNO)
       LEFT OUTER JOIN Enterprise.[dbo].[vwAdverseActionReason] AS X with(NOLOCK) ON A.APNO = X.APNO
       WHERE year(OrigCompDate) >= @Year -- 2019
	   AND vc.AffiliateID IN (@AffiliateID)-- (228)
	   AND vc.parentId = @weborderparentclno--15382
	   AND OrigCompDate IS NOT NULL

    
END


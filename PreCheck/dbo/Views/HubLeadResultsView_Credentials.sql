

/*
Created By: Larry Ouch
Created Date: 7/14/2022
Description: Qualify credential leads that are ready to be sent to ZipCrim
*/

CREATE VIEW [dbo].[HubLeadResultsView_Credentials]
AS
	SELECT  DISTINCT Top 500 pczccm.APNO, zcwo.WorkOrderID, zcwos.PartnerReference, pczccm.ApplSectionID, 
			pczccm.SectionUniqueID, pczccm.ExternalType, pczccm.ExternalID, 
			pczccm.IsSent, pczccm.IsCancelled, pczccm.ResendResult, pczccm.IsActive, pczccm.SendDate, 
			pczccm.SendAttempts, p.[SectStat] AS [LicenseStatus]
	FROM dbo.PreCheckZipCrimComponentMap AS pczccm (NOLOCK)
	INNER JOIN dbo.ZipCrimWorkOrders AS zcwo(NOLOCK) ON pczccm.APNO = zcwo.APNO 
	INNER JOIN dbo.ZipCrimWorkOrdersStaging(NOLOCK) AS zcwos ON zcwo.WorkOrderID = zcwos.WorkOrderID
	INNER JOIN dbo.Appl AS a(NOLOCK) ON pczccm.APNO = a.APNO
	INNER JOIN dbo.ProfLic AS p(NOLOCK) ON pczccm.SectionUniqueID = p.ProfLicID
	INNER JOIN dbo.sectstat  ss(NOLOCK) on p.SectStat = ss.Code-- Added 8/19
	WHERE (pczccm.IsSent = 0 OR pczccm.ResendResult = 1) 
	AND pczccm.IsActive = 1
	AND pczccm.SendAttempts < 6
	AND	P.IsHidden = 0
	AND pczccm.ApplSectionID = 4
	AND pczccm.SendDate IS NULL	
	AND SS.ReportedStatus_Integration = 'Completed'	
	AND (P.SectSubStatusId NOT IN (11, 7, 10) OR P.SectSubStatusId IS NULL)

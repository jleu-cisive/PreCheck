

/*
Created By: Larry Ouch
Created Date: 7/14/2022
Description: Qualify SanctionCheck leads that are ready to be sent to ZipCrim
*/

CREATE VIEW [dbo].[HubLeadResultsView_SanctionCheck]
AS
	SELECT  DISTINCT Top 500 pczccm.APNO, zcwo.WorkOrderID, zcwos.PartnerReference, pczccm.ApplSectionID, 
			pczccm.SectionUniqueID, pczccm.ExternalType, pczccm.ExternalID, 
			pczccm.IsSent, pczccm.IsCancelled, pczccm.ResendResult, pczccm.IsActive, pczccm.SendDate, 
			pczccm.SendAttempts, m.[SectStat] AS [SanctionCheckSectStat], ss.[Description] AS [SanctionCheckSectStatDesc], mil.Status AS [SanctionCheckStatus], m.Report AS [SanctionCheckReport]
	FROM dbo.PreCheckZipCrimComponentMap AS pczccm (NOLOCK)
	INNER JOIN dbo.ZipCrimWorkOrders AS zcwo(NOLOCK) ON pczccm.APNO = zcwo.APNO 
	INNER JOIN dbo.ZipCrimWorkOrdersStaging(NOLOCK) AS zcwos ON zcwo.WorkOrderID = zcwos.WorkOrderID
	INNER JOIN dbo.Appl AS a(NOLOCK) ON pczccm.APNO = a.APNO
	INNER JOIN dbo.MedInteg AS m(NOLOCK) ON a.apno = m.apno
	INNER JOIN dbo.sectstat  ss(NOLOCK) on m.SectStat = ss.Code
	LEFT JOIN [MedIntegLog] mil (NOLOCK) on mil.APNO = m.apno
	WHERE (pczccm.IsSent = 0 OR pczccm.ResendResult = 1) 
	AND pczccm.IsActive = 1
	AND pczccm.SendAttempts < 6
	AND m.IsHidden = 0
	AND pczccm.ApplSectionID = 7
	AND pczccm.SendDate IS NULL
	AND SS.ReportedStatus_Integration = 'Completed'

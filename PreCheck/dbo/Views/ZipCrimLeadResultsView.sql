

/*
Created By: Yves Fernandez
Created Date: 12-12-2019
Description: Qualify leads that are ready to be sent to ZipCrim
Modified by: Deepak Vodethela
Modified Date: 04/05/2020
Description: Modified the view to retun proper results
VD:08/12/2020 - Oasis: Reopened leads from See Attached to Pending not flowing through normal process
VD:10/01/2020 - TP# 95126 - Oasis: Send response to Zipcrim after all searches are complete
VD:12/21/2020 - TP#92767 - PreCheck: Lead sent to ZipCrim before Review Reportability Service Update. Introduced RefCrimStageID = 4 (Review Reportability Service Completed)
Modified By :Sahithi Gangaraju 8/19/2021 , To add top 500 in the select and also added a join with Crimsectstat table to filter for "Completed" status, Bug fix to improve performance
LO:02/15/2023 - Added logic for affiliate 310 - Bon Secours ZC
Execution: SELECT * FROM [ZipCrimLeadResultsView] z
*/

CREATE VIEW [dbo].[ZipCrimLeadResultsView]
AS
	SELECT  DISTINCT Top 500 pczccm.APNO, zcwo.WorkOrderID, zcwos.PartnerReference, pczccm.ApplSectionID, 
			pczccm.SectionUniqueID, pczccm.ExternalType, pczccm.ExternalID, 
			pczccm.IsSent, pczccm.IsCancelled, pczccm.ResendResult, pczccm.IsActive, pczccm.SendDate, 
			pczccm.SendAttempts, c.[Clear] AS [CrimStatus]
	FROM dbo.PreCheckZipCrimComponentMap AS pczccm (NOLOCK)
	INNER JOIN dbo.ZipCrimWorkOrders AS zcwo(NOLOCK) ON pczccm.APNO = zcwo.APNO 
	INNER JOIN dbo.ZipCrimWorkOrdersStaging(NOLOCK) AS zcwos ON zcwo.WorkOrderID = zcwos.WorkOrderID
	INNER JOIN dbo.Appl AS a(NOLOCK) ON pczccm.APNO = a.APNO
	INNER JOIN dbo.Crim AS c(NOLOCK) ON pczccm.SectionUniqueID = c.CrimID
	INNER JOIN dbo.crimsectstat  cr(NOLOCK) on c.Clear=cr.crimsect -- Added 8/19
	INNER JOIN dbo.Client as cl(NOLOCK) on cl.CLNO = a.CLNO --added 2/15/2023
	LEFT JOIN dbo.refAffiliate r(NOLOCK) ON r.AffiliateId  = cl.affiliateid--added 2/15/2023
	WHERE (pczccm.IsSent = 0 OR pczccm.ResendResult = 1) 
	AND pczccm.IsActive = 1
	AND pczccm.SendAttempts < 6
    AND (C.RefCrimStageID = 4 OR (C.RefCrimStageID = 2 AND cl.AffiliateId = 310))--added OR condition 2/15/2023
	AND C.IsHidden = 0
	AND pczccm.ApplSectionID = 5
	AND pczccm.SendDate IS NULL
	AND cr.ReportedStatus_Integration ='Completed'--- Added by 8/19

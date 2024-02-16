






/*
Created BY: Yves Fernandez
Modified by : Deepak Vodethela
Modified Date: 11/19/2020
Description: Send largest ETADates to Completed lead and AS IS ETADate to a pending lead 
Execution: SELECT * FROM [dbo].[vwZipCrimLeadsResultETA]
*/

CREATE VIEW [dbo].[vwZipCrimLeadsResultETA]
AS 

SELECT DISTINCT TOP 100
		pczccm.APNO,
		zcwo.WorkOrderID,
		zcwos.PartnerReference,
		pczccm.ApplSectionID, 
		pczccm.SectionUniqueID, 
		pczccm.ExternalType, 
		pczccm.ExternalID, 
		pczccm.IsSent, 
		pczccm.IsActive,
		pczccm.SendDate,
		pczccm.ETASentDate,
		pczccm.SendAttempts,
		pczccm.CreateDate,
		CASE WHEN s.ReportedStatus_Integration = 'Completed' THEN 
				(SELECT MAX(maxETA.ETADate) FROM dbo.ApplSectionsETA maxETA WHERE maxETA.Apno = ase.Apno)
				ELSE ase.ETADate
			END ETADate,
		ase.UpdateDate AS LastETAUpdate
	FROM dbo.PreCheckZipCrimComponentMap pczccm(NOLOCK)
	INNER JOIN dbo.ZipCrimWorkOrders zcwo(NOLOCK) ON pczccm.APNO = zcwo.APNO
	INNER JOIN dbo.ZipCrimWorkOrdersStaging zcwos(NOLOCK) ON zcwo.WorkOrderID = zcwos.WorkOrderID
	INNER JOIN dbo.ApplSectionsETA ase(NOLOCK) ON ase.apno = pczccm.apno 
					AND ase.ApplSectionID = pczccm.ApplSectionID 
					AND ase.SectionKeyID = pczccm.SectionUniqueID
	INNER JOIN dbo.Crim c(NOLOCK) ON pczccm.SectionUniqueID = c.CrimID AND C.IsHidden = 0
	INNER JOIN dbo.Crimsectstat s(NOLOCK) ON c.[Clear] = s.crimsect
	WHERE pczccm.IsSent = 0 
	  AND pczccm.isactive = 1 
	  AND pczccm.SendAttempts < 6
	  AND pczccm.ETASentDate IS NULL
	 AND zcwos.CreateDate > DATEADD(MONTH,-6,CURRENT_TIMESTAMP)
	  AND C.[CLEAR] != 'A'

/*
	WITH cte AS
(
	SELECT
		pczccm.APNO,
		zcwo.WorkOrderID,
		zcwos.PartnerReference,
		pczccm.ApplSectionID, 
		pczccm.SectionUniqueID, 
		pczccm.ExternalType, 
		pczccm.ExternalID, 
		pczccm.IsSent, 
		pczccm.IsActive,
		pczccm.SendDate,
		pczccm.ETASentDate,
		pczccm.SendAttempts,
		pczccm.CreateDate
	FROM dbo.PreCheckZipCrimComponentMap pczccm
	INNER JOIN dbo.ZipCrimWorkOrders zcwo ON pczccm.APNO = zcwo.APNO
	INNER JOIN dbo.ZipCrimWorkOrdersStaging zcwos ON zcwo.WorkOrderID = zcwos.WorkOrderID
	WHERE pczccm.IsSent = 0 and pczccm.isactive = 1 AND pczccm.SendAttempts < 6
)
SELECT c.*, ase.ETADate, ase.UpdateDate AS LastETAUpdate 
FROM cte c
INNER JOIN dbo.ApplSectionsETA ase ON ase.apno = c.apno 
	AND ase.ApplSectionID = c.ApplSectionID 
	AND ase.SectionKeyID = c.SectionUniqueID
WHERE C.ETASentDate IS NULL	
	--AND ase.UpdateDate > coalesce(c.ETASentDate, c.CreateDate)
	--AND C.CreateDate > '04/01/2020'
	*/

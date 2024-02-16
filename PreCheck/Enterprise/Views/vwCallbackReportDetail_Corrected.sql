
/**********************************************************************************
	Original Author: Doug DeGenaro
	Modify by: Gaurav Bangia
	Modify Date: 11/14/2022
	Modify Reason: The view was taking more than 20 seconds to return single row
	Change: Replaced the usage of vwDrugReportStatus by direct tables 
		'dbo.OCHS_ResultDetails' and 'tblZipCrimStatusMapping'
***********************************************************************************/
CREATE VIEW [Enterprise].[vwCallbackReportDetail_Corrected]
AS

SELECT       
rs.OrderNumber,
rs.ApDate, 
rs.CLNO, 
rs.HasBackground, 
rs.HasDrugScreen, 
rs.HasImmunization, 
BackgroundStatus = CASE [BackgroundStatus] WHEN 'P' THEN 'InProgress' WHEN 'F' THEN 'Completed' ELSE 'OnHold' END, 
DrugScreenStatus = CASE rs.[DrugScreenStatus] 
						 WHEN 'P' THEN 'InProgress' 
						 WHEN 'F' THEN 'Completed' 
						 WHEN 'C' THEN 'Completed' 
						 ELSE 'OnHold' END, 
-- Modified by Gaurav 11/14/2022 - Start
DrugTestBaseStatus = CASE WHEN zds.MappedStatus IS NULL THEN RD.OrderStatus ELSE zds.MappedStatus end,
-- Modified by Gaurav 11/14/2022 - End

CASE [ImmunizationStatus] WHEN 'P' THEN 'InProgress' WHEN 'F' THEN 'Completed' ELSE 'OnHold' END AS ImmunizationStatus, 
CASE RS.OrderStatus WHEN 'P' THEN 'InProgress' WHEN 'F' THEN 'Completed' ELSE 'OnHold' END AS OrderStatus, 
CASE [BackgroundResult] WHEN 'C' THEN 'Clear' ELSE '' END AS BackgroundResult, 

-- Modified by Gaurav 11/14/2022 - Start
DrugScreenLastUpdate = RD.LastUpdate,
DrugScreenResult = RD.TestResult,
-- Modified by Gaurav 11/14/2022 - End

rs.ImmunizationResult, 
oi.SourceLastUpdated AS ImunnizationLastUpdateDate, 
CandidateId = CASE 
				 WHEN ISNULL(ap.ClientCandidateId, ai.VendorProfileId) IS NULL 
				 THEN (SELECT VendorProfileID FROM Enterprise.dbo.ApplicantImmunization WHERE  ApplicantId = 
						(
							SELECT TOP 1 A.ApplicantId 
							FROM Enterprise.dbo.Applicant A
							INNER JOIN  Enterprise.dbo.[Order] O ON O.OrderId = A.Orderid
							INNER JOIN	Enterprise.dbo.ApplicantImmunization AII ON AII.ApplicantId = A.ApplicantId
							WHERE A.ProfileUserId = ap.ProfileUserId 
							AND O.ClientId = ao.ClientId
							AND AII.VendorProfileId IS NOT NULL
							ORDER BY 1 DESC
						)
					) 
				 ELSE ISNULL(ap.ClientCandidateId, ai.VendorProfileId) 
			END 
FROM            Enterprise.vwReportStatus RS  WITH (NOLOCK) 
				INNER JOIN Enterprise.dbo.Applicant AS ap WITH (NOLOCK)  ON rs.OrderNumber = ap.ApplicantNumber 
                LEFT OUTER JOIN Enterprise.dbo.vwApplicantOrder AS ao ON ao.OrderNumber = ap.ApplicantNumber 
                LEFT OUTER JOIN Enterprise.Verify.OrderImmunization AS oi WITH (NOLOCK)  ON ap.OrderId = oi.OrderId AND oi.IsActive = 1 
				LEFT OUTER JOIN Enterprise.dbo.ApplicantImmunization AS ai WITH (NOLOCK)  ON ap.ApplicantId = ai.ApplicantId
				-- Modified by Gaurav 11/14/2022 - Start
				LEFT OUTER JOIN dbo.OCHS_ResultDetails RD WITH (NOLOCK) ON RS.DrugTestReportId=RD.TID
				LEFT OUTER JOIN dbo.tblZipCrimStatusMapping zds WITH (NOLOCK)  ON RD.OrderStatus=zds.[Status]
				-- Modified by Gaurav 11/14/2022 - End

				



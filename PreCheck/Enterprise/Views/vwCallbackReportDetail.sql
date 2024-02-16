

/**********************************************************************************
	Original Author: Doug DeGenaro
	Modify by: Gaurav Bangia
	Modify Date: 11/14/2022
	Modify Reason: The view was taking more than 20 seconds to return single row
	Change: Redesigned and developed - replaced most of the views with direct table queries
	Modify by: Pradip Adhikari for SentryMD SSO
***********************************************************************************/
CREATE VIEW [Enterprise].[vwCallbackReportDetail]
AS

SELECT       
	OrderNumber		= a.APNO,
	ApDate			= a.ApDate, 
	CLNO			= a.CLNO, 
	CompDate		= a.CompDate,
	BackgrounLastUpdateDate		= CASE WHEN A.CompDate is not null THEN A.CompDate Else A.LastModifiedDate END,
	HasBackground	= ISNULL(CAST(
									CASE 
										WHEN AO.HasBackground IS NOT NULL THEN AO.HasBackground
										WHEN FS.FlagStatus IS NULL THEN 0
									END AS BIT),1), 
	HasDrugScreen	= ISNULL(CAST( 
									CASE 
										WHEN DR.TID IS NOT NULL THEN CONVERT(BIT,1) 
										WHEN AO.HasDrugScreen IS NULL AND ci.OCHS_CandidateInfoID IS NOT NULL THEN CONVERT(BIT,1)
										WHEN AO.HasDrugScreen IS NOT NULL THEN AO.HasDrugScreen
									END AS BIT),0),
	HasImmunization	= ISNULL(AO.HasImmunization,CONVERT(BIT,0)), 
	BackgroundStatus= CASE A.ApStatus WHEN 'P' THEN 'InProgress' WHEN 'F' THEN 'Completed' ELSE 'OnHold' END,
	DrugScreenStatus = CASE 
								WHEN (ISNULL(AO.HasDrugScreen, 0) = 0 AND ISNULL(ci.OCHS_CandidateInfoID,DR.TID) IS NULL) THEN 'OnHold' 
								WHEN (M.PreCheckOrderStatus IS NULL AND DR.OrderStatus LIKE 'Completed%') THEN 'Completed'
								WHEN M.PreCheckOrderStatus IS NOT NULL THEN M.PreCheckOrderStatus
								ELSE 'InProgress'
							END, 
	DrugTestBaseStatus = DR.OrderStatus, 
	ImmunizationStatus = CASE WHEN ISNULL(AO.HasImmunization,0)=1 THEN 'Completed' ELSE 'OnHold' END,
	OrderStatus		=	CASE 
							WHEN A.ApStatus<>'F' THEN (CASE WHEN A.ApStatus='P' THEN 'InProgress' WHEN a.ApStatus='M' THEN 'OnHold' END)
							WHEN (A.ApStatus='F' AND ISNULL(AO.HasDrugScreen,(ISNULL(ci.OCHS_CandidateInfoID,ISNULL(DR.TID,0))))=0) THEN 'Completed'
							WHEN (A.ApStatus='F' AND ISNULL(AO.HasDrugScreen,(ISNULL(ci.OCHS_CandidateInfoID,ISNULL(DR.TID,0))))<>0) 
							THEN 
								CASE 
									WHEN (M.PreCheckOrderStatus IS NULL AND DR.OrderStatus LIKE 'Completed%')  THEN 'Completed' 
									WHEN M.PreCheckOrderStatus IS NOT NULL THEN M.PreCheckOrderStatus
									ELSE 'InProgress'
								END
						END,
	BackgroundResult		= CASE WHEN ISNULL(FS.FlagStatus,0)=1 THEN 'Clear' ELSE '' END, 
        AStatus					= CASE WHEN ISNULL(FS.FlagStatus,0)=1 AND A.ApStatus = 'F' THEN 'No Record/Discrepancy Found' 
	                               WHEN ISNULL(FS.FlagStatus,0) <>1 AND A.ApStatus = 'F' THEN 'Discrepancy Found' 
							       ELSE '' END, 
	DrugScreenLastUpdate	= DR.LastUpdate,
	DrugScreenResult		= DR.TestResult,
	DrugTestDateInitiated = CI.CreatedDate,
	DrugTestDateCompleted = CASE WHEN DR.OrderStatus = 'Completed' THEN DR.DateReceived ELSE NULL END,
	ImmunizationResult = CASE 
							WHEN ISNULL(AO.HasImmunization,0)=1 THEN
									CASE
										WHEN oi.IsCompliant = 1  THEN 'Compliant' 
										WHEN oi.IsCompliant = 0  THEN 'NonCompliant'
										ELSE 'Unknown'
									END
							ELSE NULL				 
						END,
	ImunnizationLastUpdateDate = oi.SourceLastUpdated,
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
				END,
	ActualDrugTestStatus
	FROM          
	(
		SELECT APNO, ApDate, ApStatus, CreatedDate=ISNULL(CreatedDate, '1/1/1900'), CLNO, DOB, SSN, I94, FIRST, LAST, CompDate, LastModifiedDate 
		FROM dbo.Appl (NOLOCK) 
		WHERE DATEDIFF(YEAR,ISNULL(CreatedDate,'1/1/1900'),GETDATE())<=7
	) A
	LEFT OUTER JOIN dbo.ApplFlagStatus FS (NOLOCK)
		ON A.APNO=FS.APNO
    LEFT OUTER JOIN Enterprise.dbo.vwApplicantOrder  AS ao ON ao.OrderNumber = a.APNO 
	LEFT OUTER JOIN Enterprise.dbo.Applicant AS ap WITH (NOLOCK)  ON A.APNO = ap.ApplicantNumber 
    LEFT OUTER JOIN Enterprise.Verify.OrderImmunization AS oi WITH (NOLOCK)  ON ao.OrderId = oi.OrderId AND oi.IsActive = 1 
	LEFT OUTER JOIN Enterprise.dbo.ApplicantImmunization AS ai WITH (NOLOCK)  ON ao.ApplicantId = ai.ApplicantId
	OUTER APPLY
	(
		SELECT TOP 1 OCHS_CandidateInfoID, APNO, CreatedDate
		FROM dbo.OCHS_CandidateInfo (NOLOCK)
		WHERE APNO=A.APNO
		ORDER BY CreatedDate DESC
	) CI
	OUTER APPLY
	(
		SELECT TOP 1 TID, OrderStatus = CASE WHEN zds.MappedStatus IS NULL THEN OrderStatus ELSE zds.MappedStatus END, 
		TestResult, ScreeningType, ReasonForTest, ssn, LastUpdate, DateReceived,OrderStatus as ActualDrugTestStatus
		FROM dbo.OCHS_ResultDetails (NOLOCK)
		LEFT OUTER JOIN dbo.tblZipCrimStatusMapping zds WITH (NOLOCK) ON OrderStatus=zds.[Status]
		WHERE OrderIDOrApno=CONVERT(VARCHAR(15),A.APNO) OR OrderIDOrApno=CONVERT(VARCHAR(15),CI.OCHS_CandidateInfoID)
		ORDER BY LastUpdate DESC
	) DR
	LEFT OUTER JOIN [Enterprise].[vwServiceStatusMap]	M
	ON M.VendorTestResult=DR.TestResult AND M.VendorOrderStatus=DR.OrderStatus

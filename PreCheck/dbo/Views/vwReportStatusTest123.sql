




CREATE VIEW [dbo].[vwReportStatusTest123]

AS
WITH Appl AS
(SELECT APNO , ApDate, ApStatus, CreatedDate=ISNULL(CreatedDate, '1/1/1900'), CLNO, DOB, SSN, I94, FIRST, LAST FROM dbo.Appl (NOLOCK) WHERE DATEDIFF(YEAR,ISNULL(CreatedDate,'1/1/1900'),GETDATE())<=7)
SELECT
	OrderNumber=a.APNO,
	a.ApDate,
	A.CLNO,
	--HasBackground = ISNULL(O.HasBackground,1),
	HasBackground = ISNULL(CAST(
				CASE 
					WHEN O.HasBackground IS NOT NULL THEN O.HasBackground
					WHEN FS.FlagStatus IS NULL THEN 0
					END AS BIT),1),
	HasDrugScreen = 
	ISNULL(CAST( 
		CASE 
			WHEN ISNULL(d.TID,D1.TID) IS NOT NULL THEN CONVERT(BIT,1) 
			WHEN o.HasDrugScreen IS NULL AND ci.OCHS_CandidateInfoID IS NOT NULL THEN CONVERT(BIT,1)
			WHEN o.HasDrugScreen IS NOT NULL THEN o.HasDrugScreen
		END AS BIT),0),
	HasImmunization = 
	ISNULL(O.HasImmunization,CONVERT(BIT,0)),
	BackgroundStatus= 
	CASE 
						WHEN ISNULL(O.HasBackground,1)=1 THEN ISNULL(A.ApStatus,'P')  
						ELSE NULL  
					 END,
	DrugScreenStatus=
		CASE WHEN (ISNULL(O.HasDrugScreen, 0) = 0 AND ISNULL(ci.OCHS_CandidateInfoID,D.TID) IS NULL) THEN NULL 
		WHEN (M.PreCheckOrderStatus IS NULL AND (ISNULL(D.OrderStatus,d1.OrderStatus) LIKE 'Completed%')) THEN 'F'
		ELSE ISNULL(M.PreCheckOrderStatus,'P')  
		END,
	DrugScreenResult=
		CASE WHEN (ISNULL(O.HasDrugScreen, 0) = 0 AND ISNULL(D.TID,d1.tid) IS NULL) THEN NULL 
		WHEN (M.PreCheckOrderStatus IS NULL AND (ISNULL(D.OrderStatus,d1.OrderStatus) LIKE 'Completed%')) THEN ISNULL(D.TestResult,d1.TestResult)
		ELSE ISNULL(M.PreCheckTestResult, ISNULL(D.TestResult,d1.TestResult)) 
		END,
	ImmunizationStatus= 
	CASE WHEN ISNULL(O.HasImmunization,0)=1 THEN 'F' ELSE NULL END,
	OrderStatus=
		CASE 
			WHEN A.ApStatus<>'F' THEN A.ApStatus
			WHEN (A.ApStatus='F' AND ISNULL(O.HasDrugScreen,(ISNULL(ci.OCHS_CandidateInfoID,ISNULL(d.TID,ISNULL(d1.TID,0)))))=0) THEN A.ApStatus
			WHEN (A.ApStatus='F' AND ISNULL(O.HasDrugScreen,(ISNULL(ci.OCHS_CandidateInfoID,ISNULL(d.TID,ISNULL(d1.TID,0)))))<>0) 
				THEN 
					CASE 
						WHEN (M.PreCheckOrderStatus IS NULL AND ISNULL(D.OrderStatus,d1.OrderStatus) LIKE 'Completed%')  THEN 'F' 
						ELSE ISNULL(M.PreCheckOrderStatus,'P')  
					END
		END
	,
	BackgroundResult=CASE WHEN ISNULL(FS.FlagStatus,0)=1 THEN 'C' ELSE '' END,
	DrugResult=	CASE WHEN (ISNULL(O.HasDrugScreen,0) = 0 AND ISNULL(D.TID,d1.tid) IS NULL) THEN NULL 
		WHEN (M.PreCheckOrderStatus IS NULL AND (ISNULL(D.OrderStatus,d1.OrderStatus) LIKE 'Completed%')) THEN ISNULL(D.TestResult,d1.TestResult)
		ELSE ISNULL(M.PreCheckTestResult, ISNULL(D.TestResult,d1.TestResult)) 
		END,
	ImmunizationResult= 
		CASE 
			WHEN ISNULL(O.HasImmunization,0)=1 THEN
					CASE
						WHEN oi.IsCompliant = 1  THEN 'Compliant' 
						WHEN oi.IsCompliant = 0  THEN 'NonCompliant'
						ELSE 'Unknown'
					END
			ELSE NULL				 
		END,
	ScreeningType=ISNULL(d.ScreeningType,d1.ScreeningType),
	ReasonForTest=ISNULL(D.ReasonForTest,d1.ReasonForTest),
	CandidateId=ISNULL(ci.OCHS_CandidateInfoID,a.APNO),
	--DateOfBirth = cast(ISNULL(iif(A.DOB='', null, A.DOB), iif(ci.DOB='', null, ci.dob)) as date),
	DateOfBirth = --CASE WHEN a.dob IS NULL THEN ci.dob ELSE a.dob END,
	(CASE WHEN a.dob IS NULL THEN ci.dob ELSE cast(a.dob as date) END ),
	
	SSN = Replace(isnull((isnull(A.SSN, isnull(CI.SSN, isnull(D.SSN,D1.SSN)))),A.I94),'-',''),
	ApplicantName = ltrim(rtrim(isnull(CONCAT(A.LAST, ', ',A.First), concat(ci.LastName, ', ', ci.FirstName)))),
	DrugTestReportId=isnull(d.tid,d1.tid)
FROM Appl A
LEFT OUTER JOIN Enterprise..vwApplicantOrder	O
	ON A.APNO = O.OrderNumber
LEFT OUTER JOIN dbo.OCHS_CandidateInfo CI
	ON A.APNO=CI.APNO AND a.clno=ci.clno
LEFT OUTER JOIN dbo.vwDrugResultCurrent d
	ON CONVERT(VARCHAR(25),a.APNO)=d.OrderIDOrApno
LEFT OUTER JOIN dbo.vwDrugResultCurrent d1
	ON CONVERT(VARCHAR(25),CI.OCHS_CandidateInfoID)=d1.OrderIDOrApno
LEFT OUTER JOIN [Enterprise].[vwServiceStatusMap]	M
		ON M.VendorTestResult=D.TestResult AND M.VendorOrderStatus=D.OrderStatus
LEFT OUTER JOIN dbo.ApplFlagStatus FS 
	ON A.APNO=FS.APNO
LEFT OUTER JOIN Enterprise.Verify.OrderImmunization oi
	ON O.OrderId = oi.OrderId
	AND oi.IsActive = 1









CREATE VIEW [Enterprise].[vwReportStatus_Union]
AS
SELECT
	OrderNumber=a.APNO,
	a.ApDate,
	HasBackground = ISNULL(O.HasBackground,1),
	o.HasDrugScreen,
	O.HasImmunization,
	BackgroundStatus=CASE WHEN O.HasBackground=0 THEN NULL 
		ELSE ISNULL(A.ApStatus,'P')  
		END,
	DrugScreenStatus=
		CASE WHEN O.HasDrugScreen=0 THEN NULL 
		WHEN (M.PreCheckOrderStatus IS NULL AND D.OrderStatus LIKE 'Completed%')  THEN 'F'
		ELSE ISNULL(M.PreCheckOrderStatus,'P')  
		END,
	DrugScreenResult=
		CASE WHEN O.HasDrugScreen=0 THEN NULL 
		--WHEN (M.PreCheckOrderStatus IS NULL AND D.OrderStatus LIKE 'Completed%')  THEN ''
		WHEN (M.PreCheckOrderStatus IS NULL AND D.OrderStatus LIKE 'Completed%')  THEN D.TestResult
		ELSE ISNULL(M.PreCheckTestResult, D.TestResult) 
		END,
	ImmunizationStatus=CASE WHEN O.HasImmunization=1 THEN 'F' ELSE NULL END,
	OrderStatus=
		CASE 
			WHEN A.ApStatus<>'F' THEN A.ApStatus
			WHEN (A.ApStatus='F' AND O.HasDrugScreen=0) THEN A.ApStatus
			WHEN (A.ApStatus='F' AND O.HasDrugScreen=1) THEN 
				CASE WHEN (M.PreCheckOrderStatus IS NULL AND D.OrderStatus LIKE 'Completed%')  THEN 'F' ELSE ISNULL(M.PreCheckOrderStatus,'P')  END
		END
	,
	BackgroundResult='',
	DrugResult=	CASE WHEN O.HasDrugScreen=0 THEN NULL 
		WHEN (M.PreCheckOrderStatus IS NULL AND D.OrderStatus LIKE 'Completed%')  THEN D.TestResult
		ELSE ISNULL(M.PreCheckTestResult, D.TestResult) 
		END,
	ImmunizationResult= ''
FROM Appl						A
INNER JOIN Enterprise..vwApplicantOrder	O
	ON A.APNO = O.OrderNumber
LEFT OUTER JOIN Enterprise.vwDrugOrder			D
		ON A.APNO=D.OrderNumber
LEFT OUTER JOIN [Enterprise].[vwServiceStatusMap]	M
		ON M.VendorTestResult=D.TestResult AND M.VendorOrderStatus=D.OrderStatus

UNION ALL
SELECT
	OrderNumber=a.APNO,
	a.ApDate,
	HasBackground = CONVERT(BIT,1),
	HasDrugScreen = CASE WHEN d.CandidateId = a.APNO THEN CONVERT(BIT,0) ELSE CONVERT(BIT,1) END,
	HasImmunization=CONVERT(BIT,0),
	BackgroundStatus=ISNULL(A.ApStatus,'P'),
	DrugScreenStatus=
		CASE WHEN d.CandidateId = a.APNO THEN NULL 
		WHEN (M.PreCheckOrderStatus IS NULL AND D.OrderStatus LIKE 'Completed%')  THEN 'F'
		ELSE ISNULL(M.PreCheckOrderStatus,'P')  
		END,
	DrugScreenResult=
		CASE WHEN d.CandidateId = a.APNO THEN NULL 
		--WHEN (M.PreCheckOrderStatus IS NULL AND D.OrderStatus LIKE 'Completed%')  THEN ''
		WHEN (M.PreCheckOrderStatus IS NULL AND D.OrderStatus LIKE 'Completed%')  THEN D.TestResult
		ELSE ISNULL(M.PreCheckTestResult, D.TestResult) 
		END,
	ImmunizationStatus='',
	OrderStatus=
		CASE 
			WHEN A.ApStatus<>'F' THEN A.ApStatus
			WHEN (A.ApStatus='F' AND d.CandidateId = a.APNO) THEN A.ApStatus
			WHEN (A.ApStatus='F' AND d.CandidateId <> a.APNO ) THEN 
				CASE WHEN (M.PreCheckOrderStatus IS NULL AND D.OrderStatus LIKE 'Completed%')  THEN 'F' ELSE ISNULL(M.PreCheckOrderStatus,'P')  END
		END
	,
	BackgroundResult='',
	DrugResult=	CASE WHEN d.CandidateId = a.APNO THEN NULL 
		WHEN (M.PreCheckOrderStatus IS NULL AND D.OrderStatus LIKE 'Completed%')  THEN D.TestResult
		ELSE ISNULL(M.PreCheckTestResult, D.TestResult) 
		END,
	ImmunizationResult= ''
FROM Appl												A
LEFT OUTER JOIN  Enterprise.vwEnterpriseReports			O
	ON A.APNO = O.APNO
LEFT OUTER JOIN Enterprise.vwDrugOrder				D
	ON A.APNO=D.OrderNumber
LEFT OUTER JOIN [Enterprise].[vwServiceStatusMap]		M
	ON M.VendorTestResult=D.TestResult AND M.VendorOrderStatus=D.OrderStatus
WHERE o.OrderId IS NULL





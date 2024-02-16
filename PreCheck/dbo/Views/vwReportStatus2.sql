
CREATE  VIEW [dbo].[vwReportStatus2]
AS
WITH Appl AS
(SELECT APNO , ApDate, ApStatus, CreatedDate, CLNO FROM Precheck.dbo.Appl (NOLOCK) WHERE DATEDIFF(YEAR,ISNULL(CreatedDate,CURRENT_TIMESTAMP),CURRENT_TIMESTAMP)<= 7)						
SELECT
	OrderNumber=ISNULL(CONVERT(INT,o.OrderNumber),a.APNO),
	a.CLNO,
	a.ApDate,
	HasBackground = ISNULL(O.HasBackground,1),
	HasDrugScreen = 
		CASE 
			WHEN o.HasDrugScreen IS NOT NULL THEN o.HasDrugScreen
			WHEN o.HasDrugScreen IS NULL AND ci.OCHS_CandidateInfoID IS NOT NULL THEN CONVERT(BIT,1)
			WHEN ISNULL(d.TID,D1.TID) IS NOT NULL THEN CONVERT(BIT,1) ELSE CONVERT(BIT,0) 
		END,
	HasImmunization = ISNULL(O.HasImmunization,CONVERT(BIT,0)),
	BackgroundStatus=CASE 
						WHEN ISNULL(O.HasBackground,1)=1 THEN ISNULL(A.ApStatus,'P')  ELSE NULL  
					 END,
	DrugScreenStatus=
		CASE WHEN (O.HasDrugScreen IS NULL AND ISNULL(D.TID,D1.TID) IS NULL) THEN NULL 
		WHEN (M.PreCheckOrderStatus IS NULL AND (D.OrderStatus LIKE 'Completed%' OR D1.OrderStatus LIKE 'Completed%')) THEN 'F'
		ELSE ISNULL(M.PreCheckOrderStatus,'P')  
		END,
	DrugScreenResult=
		CASE WHEN (O.HasDrugScreen IS NULL AND ISNULL(D.TID,D1.TID) IS NULL) THEN NULL 
		WHEN (M.PreCheckOrderStatus IS NULL AND (ISNULL(D.OrderStatus,D1.OrderStatus) LIKE 'Completed%')) THEN ISNULL(D.TestResult, D1.TestResult)
		ELSE ISNULL(M.PreCheckTestResult, D.TestResult) 
		END,
	ImmunizationStatus=CASE WHEN ISNULL(O.HasImmunization,0)=1 THEN 'F' ELSE NULL END,
	OrderStatus=
		CASE 
			WHEN A.ApStatus<>'F' THEN A.ApStatus
			WHEN (A.ApStatus='F' AND ISNULL(O.HasDrugScreen,(ISNULL(ci.OCHS_CandidateInfoID,ISNULL(d.TID,ISNULL(d1.TID,0)))))=0) THEN A.ApStatus
			WHEN (A.ApStatus='F' AND ISNULL(O.HasDrugScreen,(ISNULL(ci.OCHS_CandidateInfoID,ISNULL(d.TID,ISNULL(d1.TID,0)))))<>0) THEN 
				CASE WHEN (M.PreCheckOrderStatus IS NULL AND ISNULL(D.OrderStatus,d1.OrderStatus) LIKE 'Completed%')  THEN 'F' 
				ELSE ISNULL(M.PreCheckOrderStatus,'P')  END
		END
	,
	BackgroundResult='',
	DrugResult=	CASE WHEN (O.HasDrugScreen IS NULL AND ISNULL(D.TID,D1.TID) IS NULL) THEN NULL 
		WHEN (M.PreCheckOrderStatus IS NULL AND (ISNULL(D.OrderStatus,D1.OrderStatus) LIKE 'Completed%')) THEN ISNULL(D.TestResult, D1.TestResult)
		ELSE ISNULL(M.PreCheckTestResult, D.TestResult) 
		END,
	ImmunizationResult= ''
FROM Appl						A
LEFT OUTER JOIN Enterprise..vwApplicantOrder	O
	ON A.APNO = O.OrderNumber
LEFT OUTER JOIN dbo.OCHS_CandidateInfo CI
	ON A.APNO=CI.APNO
LEFT OUTER JOIN dbo.vwDrugResultCurrent d
	ON CONVERT(VARCHAR(25),a.APNO)=d.OrderIDOrApno
LEFT OUTER JOIN dbo.vwDrugResultCurrent d1
	ON CONVERT(VARCHAR(25),CI.OCHS_CandidateInfoID)=d1.OrderIDOrApno
LEFT OUTER JOIN [Enterprise].[vwServiceStatusMap]	M
		ON M.VendorTestResult=D.TestResult AND M.VendorOrderStatus=D.OrderStatus
		


/*******************************************************
Author: Gaurav Bangia
Date Created: 11/18/2018
Purpose: Centralized view for drug results

Last Modified Date: 11/30/2018
RFM: Bug fix, was depending upon Appl table for CLNO field 

Last Modified By: Deepak Vodethela
Last Modified Date: 11/07/2019
Decription: Task - HCA Drug Testing Case Tickets - Added Coc/ChainOfCustody And CostCenter Columns 
Execution: SELECT * FROM [Enterprise].[vwDrugReportStatus]
********************************************************/
CREATE VIEW [Enterprise].[vwDrugReportStatus]
AS
SELECT
	OrderNumber=ISNULL(a.APNO,0),
	a.ApDate,
	D.CLNO,
	DrugScreenStatus=
		CASE WHEN (D.CandidateId=0 AND ISNULL(D.TID,d1.TID) IS NULL) THEN NULL 
		WHEN (M.PreCheckOrderStatus IS NULL AND (ISNULL(D.OrderStatus,d1.OrderStatus) LIKE 'Completed%')) THEN 'F'
		ELSE ISNULL(M.PreCheckOrderStatus,'P')  
		END,
	DrugScreenResult=
		CASE WHEN (ISNULL(D.TID,d1.tid) IS NULL) THEN NULL 
		WHEN (M.PreCheckOrderStatus IS NULL AND (ISNULL(D.OrderStatus,d1.OrderStatus) LIKE 'Completed%')) THEN ISNULL(D.TestResult,d1.TestResult)
		ELSE ISNULL(M.PreCheckTestResult, ISNULL(D.TestResult,d1.TestResult)) 
		END,
	DrugTestBaseStatus = D.OrderStatus,
	ScreeningType=ISNULL(d.ScreeningType,d1.ScreeningType),
	ReasonForTest=ISNULL(D.ReasonForTest,d1.ReasonForTest),
	CandidateId=d.CandidateId,
	ResultUpdateDate=ISNULL(D.LastUpdate,D1.LastUpdate),
	ApplicantLastName = ISNULL(a.Last,ISNULL(ci.LastName,ISNULL(d.LastName, ISNULL(d1.LastName,'')))),
	ApplicantFirstName = ISNULL(a.First,ISNULL(ci.FirstName,ISNULL(d.FirstName, ISNULL(d1.FirstName,'')))),
	CostCenter = ISNULL(CI.CostCenter,ISNULL(d.CostCenter,ISNULL(d1.CostCenter,''))),
	ChainOfCustody = ISNULL(d.CoC,ISNULL(d1.CoC,''))
FROM dbo.vwDrugResultCurrent d
LEFT OUTER JOIN DBO.Appl A
	ON ISNULL(D.APNO,0)=A.APNO AND a.ApDate > DATEADD(MONTH,-6,GETDATE())
LEFT OUTER JOIN dbo.OCHS_CandidateInfo CI
	ON A.APNO=CI.APNO AND a.clno=ci.clno AND CI.CreatedDate > DATEADD(MONTH,-6,GETDATE())
LEFT OUTER JOIN dbo.vwDrugResultCurrent d1 
	ON CONVERT(VARCHAR(25),CI.OCHS_CandidateInfoID)=d1.CandidateId 
LEFT OUTER JOIN [Enterprise].[vwServiceStatusMap]	M
		ON M.VendorTestResult=D.TestResult AND M.VendorOrderStatus=D.OrderStatus

UNION ALL

SELECT
	OrderNumber=d.OrderIDOrApno,
	d.DateReceived,
	d.clno,
	DrugScreenStatus=
		CASE 
		WHEN (M.PreCheckOrderStatus IS NULL AND (ISNULL(D.OrderStatus,'') LIKE 'Completed%')) THEN 'F'
		ELSE ISNULL(M.PreCheckOrderStatus,'P')  
		END,
	DrugScreenResult=
		CASE 
		WHEN (M.PreCheckOrderStatus IS NULL AND (ISNULL(D.OrderStatus,'') LIKE 'Completed%')) THEN ISNULL(D.TestResult,'')
		ELSE ISNULL(M.PreCheckTestResult, ISNULL(D.TestResult,'')) 
		END,
	DrugTestBaseStatus = D.OrderStatus,
	ScreeningType=ISNULL(d.ScreeningType,''),
	ReasonForTest=ISNULL(D.ReasonForTest,''),
	CandidateId=d.CandidateId,
	ResultUpdateDate=D.LastUpdate,
	ApplicantLastName = d.LastName,
	ApplicantFirstName = d.FirstName,
	'' AS CostCenter,
	ChainOfCustody = ISNULL(d.CoC,'')
FROM dbo.vwIndependentDrugResultCurrent d
LEFT OUTER JOIN [Enterprise].[vwServiceStatusMap]	M
		ON M.VendorTestResult=D.TestResult AND M.VendorOrderStatus=D.OrderStatus

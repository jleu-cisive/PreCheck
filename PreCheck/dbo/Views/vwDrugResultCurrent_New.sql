



CREATE VIEW [dbo].[vwDrugResultCurrent_New]
WITH SCHEMABINDING
AS

SELECT
	TID,
	cte.ProviderID,
	OrderIDOrApno=cte.OrderIDOrApno,
	APNO=ISNULL(ci.APNO,TRY_PARSE(cte.OrderIDOrApno AS INT)),
	CandidateId=ISNULL(ci.OCHS_CandidateInfoID,0),
	SSN = ISNULL(ci.SSN, cte.SSNOrOtherID),
	cte.ScreeningType,
	FirstName=ISNULL(ci.FirstName,cte.FirstName),
	LastName=ISNULL(ci.LastName,cte.LastName),
	cte.FullName,
	cte.OrderStatus,
	cte.DateReceived,
	cte.TestResult,
	cte.TestResultDate,
	cte.LastUpdate,
	cte.CoC,
	cte.ReasonForTest,
	clno=ISNULL(ci.clno,cte.CLNO),
	ci.Address1,
	CI.Address2,
	CI.City,
	CI.State,
	CI.Zip,
	CI.Email,
	CI.Phone,
	CI.TestReason,
	CI.CostCenter,
	CI.CreatedDate,
	CI.IsActive
FROM 
dbo.OCHS_ResultDetails CTE
INNER JOIN
(
	SELECT
	OrderIDOrApno=R.OrderIDOrApno,
	LastUpdate=MAX(R.LastUpdate)
	FROM dbo.OCHS_ResultDetails R
	WHERE ISNUMERIC(R.OrderIDOrApno)=1
	GROUP BY R.OrderIDOrApno
) L 
ON CTE.OrderIDOrApno=L.OrderIDOrApno  AND CTE.LastUpdate=L.LastUpdate
LEFT OUTER JOIN dbo.OCHS_CandidateInfo ci 
	ON CTE.OrderIDOrApno=CONVERT(VARCHAR(25),CI.OCHS_CandidateInfoID)








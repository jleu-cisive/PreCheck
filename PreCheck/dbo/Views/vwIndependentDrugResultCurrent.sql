
CREATE VIEW [dbo].[vwIndependentDrugResultCurrent]
WITH SCHEMABINDING
AS

SELECT
	TID,
	cte.ProviderID,
	OrderIDOrApno='',
	APNO=0,
	CandidateId=0,
	SSN = cte.SSNOrOtherID,
	cte.ScreeningType,
	FirstName=cte.FirstName,
	LastName=cte.LastName,
	cte.FullName,
	cte.OrderStatus,
	cte.DateReceived,
	cte.TestResult,
	cte.TestResultDate,
	cte.LastUpdate,
	cte.CoC,
	cte.ReasonForTest,
	clno=cte.CLNO,
	Address1='',
	Address2='',
	City='',
	State='',
	Zip='',
	Email='',
	Phone='',
	TestReason='',
	CostCenter='',
	CreatedDate=cte.DateReceived,
	IsActive=CONVERT(BIT,1)
FROM 
dbo.OCHS_ResultDetails CTE
INNER JOIN
(
	SELECT
	LastUpdate=MAX(R.LastUpdate),
	R.CLNO,
	R.SSNOrOtherID
	FROM dbo.OCHS_ResultDetails R
	WHERE ISNULL(r.OrderIDOrApno,'')='' OR r.OrderIDOrApno='0'
	GROUP BY r.CLNO, r.SSNOrOtherID
) L 
ON CTE.LastUpdate=L.LastUpdate AND CTE.SSNOrOtherID=L.SSNOrOtherID

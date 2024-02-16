
CREATE VIEW [dbo].[_GK_DELETE_vwDrugResultCurrent]
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
	CI.IsActive,
	CI.ClientConfiguration_DrugScreeningID
FROM 
dbo.OCHS_ResultDetails CTE WITH (NOLOCK)
cross apply (
	Select 
		Max([LastUpdate]) [LastUpdate]
		--,[OrderIDOrApno]
	From 
		[dbo].[OCHS_ResultDetails]
	Where 
		[OrderIDOrApno] = CTE.[OrderIDOrApno]
	)
	 x
--INNER JOIN
--(
---- This is basically causing SQL server to go ahead and evaluate all the data in the table 
---- (as of 2022-09-22 1.6 Million) group the data, get the last update date
---- This all happends before any predicates, thus increasing data size
--	SELECT
--	OrderIDOrApno=R.OrderIDOrApno,
--	LastUpdate=MAX(R.LastUpdate)
--	FROM dbo.OCHS_ResultDetails R WITH (NOLOCK)
--	WHERE ISNUMERIC(R.OrderIDOrApno)=1
--	GROUP BY R.OrderIDOrApno
--) L 
--ON CTE.OrderIDOrApno=L.OrderIDOrApno  AND CTE.LastUpdate=L.LastUpdate
LEFT OUTER JOIN dbo.OCHS_CandidateInfo ci  WITH (NOLOCK)
	ON CTE.OrderIDOrApno=CONVERT(VARCHAR(25),CI.OCHS_CandidateInfoID)
	--added join condition to avoid incorrect join. experienced OrderIdOrApno field unexpectedly having clno. This could be changed back if a root cause fix could be applied. 
	AND cte.LastName=ci.LastName
Where
	x.[LastUpdate] = CTE.[LastUpdate]








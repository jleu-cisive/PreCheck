






/*Modified By: Gaurav
Modified Date: 01/31/2018
Last Modified Date: 3/17/2021

Modification History:
(01/31/2018) Purpose: Switched from using LastUpdate field to DateRecieved for grouping/ordering
(12/13/2018) Purpose: Added join condition to avoid incorrect join based on OrderIdOrApno.
 experienced OrderIdOrApno field unexpectedly having clno. This could be changed back if a root cause fix could be applied. 
 (3/17/2021) Added 'ClientConfiguration_DrugScreeningID' as part of the resultset
*/
/*Modified By: Abhijit
Modified Date: 09/08/2022
Change: Added left outer join tblZIpCrimStatusMapping to new statuses
*/
CREATE VIEW [dbo].[vwDrugResultCurrent]
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
	(CASE 
		WHEN (zm.[Status] IS NOT NULL)  
		THEN zm.MappedStatus
		else cte.OrderStatus
	END) AS OrderStatus,
	--cte.OrderStatus,
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
INNER JOIN
(
	SELECT
	OrderIDOrApno=R.OrderIDOrApno,
	LastUpdate=MAX(R.LastUpdate)
	FROM dbo.OCHS_ResultDetails R WITH (NOLOCK)
	WHERE ISNUMERIC(R.OrderIDOrApno)=1
	GROUP BY R.OrderIDOrApno
) L 
ON CTE.OrderIDOrApno=L.OrderIDOrApno  AND CTE.LastUpdate=L.LastUpdate
LEFT OUTER JOIN dbo.OCHS_CandidateInfo ci  WITH (NOLOCK)
	ON CTE.OrderIDOrApno=CONVERT(VARCHAR(25),CI.OCHS_CandidateInfoID)
	--added join condition to avoid incorrect join. experienced OrderIdOrApno field unexpectedly having clno. This could be changed back if a root cause fix could be applied. 
	AND cte.LastName=ci.LastName
--added join to map new zipcrim statuses
LEFT OUTER JOIN [dbo].[tblZipCrimStatusMapping] zm
ON CTE.OrderStatus= zm.[Status] and zm.IsActive=1









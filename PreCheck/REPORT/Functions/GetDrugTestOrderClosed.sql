
/* =============================================
-- Author:		Gaurav
-- Create date: 11/5/2019
-- Modify date: 10/20/2020
-- Modification Description: Added to where clause 'AND D.TestResult <> 'x:CancelledRequest''
-- Description:	Returns count on DRUG TEST completion/CLOSURE
-- select [Report].[GetDrugTestOrderClosed]('6/15/2021','6/16/2021',7519,11045)
	
   Last Modify Date: 6/2/2021
   Last Modify By: Gaurav Bangia
   Modification Reason: Exclude the Infor requests based drug test orders.
   Next (TBD): Parameterize the logic is preferred
*/
-- =============================================

CREATE  function [REPORT].[GetDrugTestOrderClosed](@StartTime SMALLDATETIME,@EndTime SMALLDATETIME, @ClientId INT, @ExcludeFacilityId INT null)
RETURNS int
AS	
BEGIN
	
	DECLARE @count INT 
	
	SELECT @count=COUNT(*) 
	FROM
	(
	--FROM [dbo].[vwDrugResultCurrent] D 
	SELECT DISTINCT D.ApplicantLastName, D.ApplicantFirstName, D.ChainOfCustody, D.ResultUpdateDate, D.DrugScreenStatus, D.CLNO, D.OrderNumber,
	D.CandidateId
	FROM [PRECHECK].[Enterprise].[vwDrugReportStatus] D WITH (NOLOCK)
	INNER JOIN Enterprise.PreCheck.vwClient C ON d.CLNO=C.ClientId 
		--AND D.LastUpdate BETWEEN @StartTime AND @EndTime		
		AND D.ResultUpdateDate BETWEEN @StartTime AND @EndTime		
	LEFT OUTER JOIN 
	(
		SELECT [DrugTestServiceNumber] = JSON_VALUE(JsonContent,'$.Services[1].OrderServiceNumber'), IntegrationRequestId,
		OrderNumber
		FROM Enterprise.Staging.OrderStage EO WITH (NOLOCK)
		INNER JOIN  dbo.Integration_OrderMgmt_Request ior WITH (NOLOCK) ON eo.IntegrationRequestId=ior.RequestID
		INNER JOIN dbo.ClientConfig_Integration ci WITH (NOLOCK) ON ior.CLNO=ci.CLNO AND ISNULL(ci.refATSId,0)=2
		-- Putting a date range to limit the scan
		WHERE CreateDate BETWEEN DATEADD(day,-60,@starttime) AND @endtime
		AND ClientId=@ClientId
	)
	 InforDrugTests
		ON  d.CandidateId=InforDrugTests.DrugTestServiceNumber
	WHERE (c.ClientId=ISNULL(@ClientId,c.ClientId) OR c.ParentId=ISNULL(@ClientId,c.ParentId))
 	AND D.CLNO<> ISNULL(@ExcludeFacilityId,-1)
	--AND d.orderstatus IN ('Link Expired', 'Completed')
	--AND D.TestResult <> 'x:CancelledRequest'
	AND D.DrugScreenStatus IN ('F' ,'C')
	AND DrugScreenResult NOT IN ('x:CancelledRequest')
	-- Exclude InforDrug tests
	AND InforDrugTests.IntegrationRequestId IS NULL
    ) S

	RETURN ISNULL(@count,0)
END

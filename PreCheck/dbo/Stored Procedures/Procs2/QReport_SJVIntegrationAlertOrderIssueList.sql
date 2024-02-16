-- =============================================
-- Author:		<Amy Qing Liu>
-- Create date: <10/12/2020>
-- Description:	the qreport is noly for substatus of "SJV Alert issue" for "Alert" status to collect SJV Alert issues 
-- I used the today's date for faster query as the substatus is created this morning.
-- AmyLiu mofified to let user to choose the ComplateStartDate and ComplateEndDate on 08/15/2022 and use Third Party Verification to replace SJV Alert issue
--EXEC [dbo].[QReport_SJVIntegrationAlertOrderIssueList] '08/15/2022','08/15/2022'
-- =============================================
CREATE PROCEDURE [dbo].[QReport_SJVIntegrationAlertOrderIssueList]
@ComplateStartDate datetime,
@ComplateEndDate datetime
AS
BEGIN

	SET NOCOUNT ON;

	--DECLARE @ComplateStartDate datetime='08/15/2022', @ComplateEndDate datetime='08/15/2022'
		SELECT distinct e.APNO, e.EmplID, e.OrderID,e.DateOrdered,e.Employer, e.Pub_Notes, sss.SectStatusCode SectStatusCode, sss.SectSubStatus,  lg.ProcessedDate
		FROM dbo.Integration_VendorOrder_Log lg (nolock)
		INNER JOIN dbo.Integration_VendorOrder ivo (nolock) ON lg.Integration_VendorOrderId = ivo.Integration_VendorOrderId
		INNER JOIN dbo.empl e ON lg.OrderId = e.OrderId
		INNER JOIN dbo.SectSubStatus sss ON e.SectSubStatusID = sss.SectSubStatusID AND e.SectStat = sss.SectStatusCode and sss.ApplSectionID=1
		WHERE lg.StatusReceived ='Completed' AND lg.IsProcessed=1 AND lg.ProcessedDate IS NOT null
		AND ivo.VendorName='sjv' AND lg.CreatedDate>=@ComplateStartDate  and lg.CreatedDate<=@ComplateEndDate+1
		AND sss.SectStatusCode ='C'
		AND sss.SectSubStatus ='Third Party Verification'
		ORDER BY lg.ProcessedDate DESC

END


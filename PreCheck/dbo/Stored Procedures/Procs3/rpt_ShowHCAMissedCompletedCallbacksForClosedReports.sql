
CREATE PROCEDURE [dbo].[rpt_ShowHCAMissedCompletedCallbacksForClosedReports]
(@year int)
as
SELECT 
	iomr.RequestID,
	iomr.Apno AS [Report Number],
	a.ApDate AS [Report Closed Date],
	a.First,
	a.Last 
FROM 
	dbo.Integration_OrderMgmt_Request iomr (NOLOCK)
INNER JOIN dbo.Appl a (NOLOCK) ON iomr.Apno = a.APNO
INNER JOIN dbo.Client c (NOLOCK) ON a.Clno = c.Clno --Code added by Arindam for ticket# -84621 PART 3
WHERE a.ApStatus IN ('F') AND (iomr.Process_Callback_Final= 0 and iomr.Callback_Final_Date is null)
AND iomr.Clno = 7519 
AND c.AffiliateID in (4,294) --Code added by Arindam for ticket# -84621 PART 3
and year(iomr.RequestDate) = @year 
ORDER BY 1 DESC

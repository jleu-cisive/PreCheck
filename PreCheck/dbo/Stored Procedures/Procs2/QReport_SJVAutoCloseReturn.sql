-- =============================================
-- Author:		<Amy Liu>
-- Create date: <10/03/2022>
-- Description:	HDT64389 New Qreport - SJV Auto Close Return on 10/03/2022
-- EXEC [dbo].[QReport_SJVAutoCloseReturn] '09/28/2022','09/30/2022', 0
-- EXEC [dbo].[QReport_SJVAutoCloseReturn] '09/28/2022','09/30/2022', 117
-- =============================================
CREATE PROCEDURE [dbo].[QReport_SJVAutoCloseReturn]
(
	@StartDate datetime,
	@EndDate datetime,
	@AffiliateID int
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT 	x.Status,x.SectsubStatus , count(1) AS [NumberReturns]
	FROM (
		SELECT distinct c.AffiliateID,a.apno as [ReportNumber],c.Name AS [ClientName],ra.Affiliate,e.Employer AS [EmploymentName],e.SectStat,ss.description AS [Status], e.SectSubStatusID, sss.SectsubStatus, e.OrderID, e.DateOrdered AS [DateOrdered]
		FROM dbo.Integration_VendorOrder_Log lg (nolock)
		INNER JOIN dbo.Integration_VendorOrder ivo (nolock) ON lg.Integration_VendorOrderId = ivo.Integration_VendorOrderId
		INNER JOIN dbo.empl e (nolock) ON lg.OrderId = e.OrderId
		INNER JOIN dbo.appl a (nolock) ON e.apno = a.apno
		INNER JOIN dbo.client c (nolock) ON a.CLNO = c.CLNO
		LEFT JOIN dbo.refAffiliate ra(nolock) ON c.AffiliateID = ra.AffiliateID
		INNER JOIN dbo.SectStat ss (nolock) ON ss.code = e.SectStat	
		left JOIN dbo.SectSubStatus sss (nolock) ON e.SectSubStatusID = sss.SectSubStatusID AND sss.ApplSectionID =1
		WHERE ivo.VendorName='sjv' AND lg.StatusReceived='Completed' AND lg.IsProcessed	=1
		AND lg.CreatedDate	>=@StartDate and lg.CreatedDate	<@EndDate +1
		AND (@AffiliateID=0 OR @AffiliateID= c.AffiliateID)
	 )x
		GROUP BY x.SectStat,x.status , x.SectSubStatusID, x.SectsubStatus
		ORDER BY x.SectStat,x.status , x.SectSubStatusID, x.SectsubStatus
END

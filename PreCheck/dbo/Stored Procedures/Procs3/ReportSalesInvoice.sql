



CREATE PROCEDURE [dbo].[ReportSalesInvoice] 
@CurrentFirstDate datetime 
AS
--Current meaning the month that was asked for -- usually the month before this actual month, is on 8/5/2005, ask for July, so current date is 7/1/2005
--Sales report for Mike Piana
--hz added billingstate on 7/12/06
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT i.CLNO, Name, SalesPersonUserID, min(ApDate) AS FirstApp, BillingCity, BillingState, Addr1 AS Address1, Addr2 AS Address2, Addr3 AS Address3, c.City AS PrimaryCity, c.State AS PrimaryState,
(SELECT sum(Sale) FROM InvMaster WHERE InvDate >= @CurrentFirstDate-75 and  InvDate < @CurrentFirstDate-45 AND CLNO=i.CLNO GROUP BY CLNO) AS LastLastMonth,
(SELECT sum(Sale) FROM InvMaster WHERE InvDate >= @CurrentFirstDate-45 and  InvDate < @CurrentFirstDate-15 AND CLNO=i.CLNO GROUP BY CLNO) AS LastMonth,
(SELECT sum(Sale) FROM InvMaster WHERE InvDate >= @CurrentFirstDate-15 and  InvDate < @CurrentFirstDate+15 AND CLNO=i.CLNO GROUP BY CLNO) AS CurrentMonth
FROM InvMaster i
JOIN Client c ON c.CLNO=i.CLNO
JOIN Appl a ON c.CLNO=a.CLNO
JOIN refBillingStatus bs ON bs.BillingStatusID=c.BillingStatusID
WHERE bs.BillingStatus='Active'
GROUP BY i.CLNO, Name, SalesPersonUserID, BillingCity, BillingState,Addr1,Addr2,Addr3, c.City, c.State
ORDER BY min(ApDate) DESC

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET NOCOUNT OFF
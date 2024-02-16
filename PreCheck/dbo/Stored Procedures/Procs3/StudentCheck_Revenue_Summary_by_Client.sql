-- =============================================  
-- Author: Arindam Mitra  
-- Requester: Christine Law
-- Create date: 04/20/2023  
-- Description: Report to show all clients who have placed StudentCheck orders in the last 12 months. Breakdown of the revenue between background cheks, drug testing, and immunizations.
-- multiple Client no to be separated by a colon. '0' indicates all client Id.
-- Execution: EXEC [dbo].[StudentCheck_Revenue_Summary_by_Client] '0'  

-- =============================================  
CREATE PROCEDURE [dbo].[StudentCheck_Revenue_Summary_by_Client]  
 -- Add the parameters for the stored procedure here  
 @CLNO VARCHAR(500) = NULL
 
AS  

BEGIN
SET NOCOUNT ON  
  
  
 IF(@CLNO = '0' OR @CLNO IS NULL OR @CLNO = 'null')  
 BEGIN  
  SET @CLNO = '' 
 END  
  
  
  SELECT CL.CLNO, CL.Name 'Client Name', bs.ServiceName, SUM(os.Price) InvoiceAmt
FROM appl a WITH (NOLOCK)
INNER JOIN Client CL WITH (NOLOCK) ON A.CLNO=CL.CLNO
INNER JOIN Enterprise..[Order] od WITH (NOLOCK) ON a.apno=od.OrderNumber
INNER JOIN Enterprise..OrderService os WITH (NOLOCK) ON od.orderid=os.OrderId
INNER JOIN Enterprise..BusinessService bs WITH (NOLOCK) ON os.BusinessServiceId=bs.BusinessServiceId
INNER JOIN precheck.dbo.invdetail inv WITH (NOLOCK) ON a.APNO=inv.APNO
where cl.ClientTypeID IN (6,7,8,9,11,12,13) 
AND inv.type IN (0,1)
AND os.BusinessServiceId IN (1,2,3)
AND (convert(DATE, A.Apdate) >=  convert(date, Dateadd(Month, -12, GETDATE())))
AND (ISNULL(@CLNO,'') = '' OR A.CLNO IN (SELECT splitdata FROM dbo.fnSplitString(@CLNO,':')))   
GROUP BY CL.CLNO, CL.Name, bs.ServiceName
ORDER BY CL.Name, bs.ServiceName


SET NOCOUNT OFF 

END
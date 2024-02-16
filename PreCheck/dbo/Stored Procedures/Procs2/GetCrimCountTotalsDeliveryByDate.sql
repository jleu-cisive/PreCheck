-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetCrimCountTotalsDeliveryByDate]
	-- Add the parameters for the stored procedure here
	@StartDate Date,
	@EndDate Date
	
AS
BEGIN

SELECT isnull([t1].[deliverymethod], 'n/a') AS [DeliveryMethod], COUNT(*) AS [Count]
from appl [t0] with (nolock)
inner join crim [t1] with (nolock) on t0.apno = t1.apno
WHERE
[t1].ishidden = 0 and 
 (( Convert(date, [t1].IrisOrdered) >= Convert(date, @StartDate)) AND (Convert(date, [t1].IrisOrdered)  <= 
	Convert(date, @EndDate)) AND ([t1].[APNO] = [t0].[APNO]))
GROUP BY [t1].[deliverymethod]
END

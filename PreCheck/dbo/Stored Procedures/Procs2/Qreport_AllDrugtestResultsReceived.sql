-- =============================================
-- Author:		Humera Ahmed
-- Create date: 09/08/2021
-- Description:	Q-report that shows all the drug test results we have received Please include transaction IDs, Chain of Custody Form Number, name, CLNO/Location Code.
-- EXEC [dbo].[Qreport_AllDrugtestResultsReceived] '07/01/2021'--,'09/08/2021'
-- Modified By :Sahithi -10/13/2021
-- For HDT:21937, When Clno =0 , SP has to return results for all clients , within the provided date range.

-- Modified by: Humera Ahmed on 01/25/2022 - Add a new search parameter ParentCLNO for HDT #34144 Modify QR-All Drugtest Results Received
-- Modified by: Humera Ahmed on 01/31/2022 for HDT #34789 - To include all ParentCLNO, to include datapoint [ParentCLNO]

-- EXEC [Qreport_AllDrugtestResultsReceived] 0,0,'09/26/2021','01/25/2022'
-- =============================================
CREATE PROCEDURE [dbo].[Qreport_AllDrugtestResultsReceived]
	-- Add the parameters for the stored procedure here
	@CLNO int,
	@ParentCLNO int,
	@StartDate DateTime,
	@EndDate DateTime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

  

	SELECT
		ord.CLNO,
		ord.OrderIDOrApno as [OrderNumber],
		c.Name [Client Name],
		isnull(cast(c.WebOrderParentCLNO AS varchar(20)),' ') [ParentCLNO],
		ord.TID [Transaction ID],
		ord.CoC [Chain of Custody],
		ord.FirstName [First Name],
		ord.LastName [Last Name],
		ord.OrderStatus [Order Status],
		ord.TestResult [Test Result],
		format(ord.LastUpdate,'MM/dd/yyyy') [Last Update Date]
	FROM dbo.OCHS_ResultDetails ord (NOLOCK)
	INNER JOIN dbo.Client c (NOLOCK) ON ord.CLNO = c.CLNO
	WHERE
		ord.LastUpdate >= @StartDate 
		AND ord.LastUpdate < DATEADD(DAY, 1, @EndDate)
		AND	ord.CLNO =  IIF(@CLNO=0,ord.CLNO,@CLNO)
		AND (
			isnull(c.WebOrderParentCLNO,' ') = IIF(@ParentCLNO=0,isnull(c.WebOrderParentCLNO,' '),@ParentCLNO)
			)

	ORDER BY c.WebOrderParentCLNO, ord.LastUpdate
	END

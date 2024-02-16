-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 10/06/2021
-- Description:	For al ZipCrim MyScreen sending results as Expired,
-- we are updating the results to x:Expired.
-- =============================================
CREATE PROCEDURE [dbo].[UpdateDrugTestOrderToExpired_Schedule] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DROP TABLE IF EXISTS #tempResultDetails

DECLARE @recordCount int

Set @recordCount =	(Select Count(*) From Precheck.dbo.OCHS_ResultDetails where Testresult ='Expired' and LastUpdate >'09/30/2021' and OrderStatus ='Completed')

Select * INTO #tempResultDetails From Precheck.dbo.OCHS_ResultDetails where Testresult ='Expired' and LastUpdate >'09/30/2021' and OrderStatus ='Completed'

IF(@recordCount >0)
	BEGIN
    -- Insert statements for procedure here
	Update Precheck.dbo.OCHS_ResultDetails Set Testresult ='x:Expired' WHERE LastUpdate >'09/30/2021' and TestResult ='Expired' and OrderStatus ='Completed'
 
	END

	SELECT * FROM #tempResultDetails
END

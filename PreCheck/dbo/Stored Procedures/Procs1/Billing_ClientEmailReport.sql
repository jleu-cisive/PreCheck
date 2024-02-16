-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 12/04/2013
-- Description:	Gets all the records between startdate and end date
-- =============================================
CREATE PROCEDURE [dbo].[Billing_ClientEmailReport] 
	-- Add the parameters for the stored procedure here
	@StartDate datetime = '',
	@EndDate datetime =''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	 
SELECT  CLNO, ClientName, Name, Phone, Email1, Email2
FROM  dbo.ClientEmail
WHERE( CreatedDate >= @StartDate OR @StartDate='')          
AND (CreatedDate < @EndDate  OR @EndDate = '')

   
SET NOCOUNT OFF


END

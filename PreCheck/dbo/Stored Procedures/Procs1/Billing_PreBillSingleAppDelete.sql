-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Billing_PreBillSingleAppDelete]	
	
	@APNO int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
DELETE FROM InvDetail WHERE APNO = @APNO AND not Type = 1 AND Billed = 0
SET NOCOUNT OFF

END





-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Billing_PreBillSingleDelete]
	@CLNO smallint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
DELETE FROM InvDetail WHERE APNO in(
SELECT Apno FROM Appl 
WHERE (CLNO = @CLNO)
  --AND (Billed = 0)on a reopen it might be 1
) AND not Type = 1 AND Billed = 0

END





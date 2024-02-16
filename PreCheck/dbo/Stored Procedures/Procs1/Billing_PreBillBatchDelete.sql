-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Billing_PreBillBatchDelete]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--DELETE FROM InvDetail WHERE not Type = 1 AND Billed = 0
DELETE FROM DBO.InvDetail 
WHERE  Type <> 1 AND Billed = 0 --changed by santosh on 12/3/12

SET NOCOUNT OFF
END




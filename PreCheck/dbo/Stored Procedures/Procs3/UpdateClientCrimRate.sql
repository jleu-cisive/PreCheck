
-- =============================================
-- Date: September 30, 2001
-- Author: Pat Coffer
--
-- Updates a client criminal rate.
-- =============================================
CREATE PROCEDURE UpdateClientCrimRate
	@CLNO smallint,
	@CNTY_NO int,
	@Rate smallmoney
AS 
SET NOCOUNT ON
UPDATE ClientCrimRate
SET Rate = @Rate
WHERE (CLNO = @CLNO)
  AND (CNTY_NO = @CNTY_NO)

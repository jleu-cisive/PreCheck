
-- =======================================
-- Date: September 30, 2001
-- Author: Pat Coffer
--
-- Deletes a client criminal rate.
-- =======================================
CREATE PROCEDURE DeleteClientCrimRate
	@CLNO smallint,
	@CNTY_NO int
AS
SET NOCOUNT ON
DELETE FROM ClientCrimRate
WHERE (CLNO = @CLNO)
  AND (CNTY_NO = @CNTY_NO)

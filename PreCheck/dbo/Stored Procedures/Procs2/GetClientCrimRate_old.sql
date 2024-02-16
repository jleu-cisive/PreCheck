CREATE PROCEDURE [GetClientCrimRate_old]
	@CLNO smallint,
	@CNTY_NO int,
	@Rate smallmoney OUTPUT,
	@ExcludeFromRules bit OUTPUT
AS
SET NOCOUNT ON
SELECT @Rate = Rate, @ExcludeFromRules=ExcludeFromRules
FROM ClientCrimRate
WHERE (CLNO = @CLNO)
  AND (CNTY_NO = @CNTY_NO)
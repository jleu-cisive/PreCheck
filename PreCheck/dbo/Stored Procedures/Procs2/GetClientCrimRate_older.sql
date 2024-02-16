
CREATE PROCEDURE [GetClientCrimRate_older]
	@CLNO smallint,
	@CNTY_NO int,
	@Rate smallmoney OUTPUT
AS
SET NOCOUNT ON
SELECT @Rate = Rate
FROM ClientCrimRate
WHERE (CLNO = @CLNO)
  AND (CNTY_NO = @CNTY_NO)

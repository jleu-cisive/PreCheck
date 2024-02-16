-- Alter Procedure GetDefaultCrimRate

CREATE PROCEDURE dbo.GetDefaultCrimRate
	@CNTY_NO int,
	@Rate smallmoney OUTPUT
AS 
SET NOCOUNT ON
SELECT @Rate = Crim_DefaultRate
FROM dbo.TblCounties
WHERE CNTY_NO = @CNTY_NO

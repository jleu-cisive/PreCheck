-- Alter Procedure GetFullCountyName

CREATE PROCEDURE dbo.GetFullCountyName 
  @CNTY_NO int
AS

SELECT a_county, state, country FROM dbo.TblCounties WHERE CNTY_NO=@CNTY_NO

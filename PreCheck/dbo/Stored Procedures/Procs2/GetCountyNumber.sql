-- Alter Procedure GetCountyNumber

CREATE PROCEDURE dbo.GetCountyNumber 
  @County varchar(25),
  @State varchar(25),
  @Country varchar(25),
  @CNTY_NO int out
AS

SELECT @CNTY_NO=MIN(CNTY_NO) FROM dbo.TblCounties WHERE a_county=@County and state=@state and country=@country

-- Alter Procedure ADD_CNTY_NO_TO_Crim

CREATE PROCEDURE dbo.ADD_CNTY_NO_TO_Crim AS

Update CRIM Set CNTY_NO=TblCounties.CNTY_NO FROM dbo.TblCounties where crim.county = TblCounties.county

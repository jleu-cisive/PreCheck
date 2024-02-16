-- Alter Procedure Add_CNTY_NO_To_ClientCrimRate

CREATE PROCEDURE dbo.Add_CNTY_NO_To_ClientCrimRate AS

Update ClientCrimRate Set CNTY_NO=TblCounties.CNTY_NO FROM dbo.TblCounties where clientcrimrate.county = TblCounties.county

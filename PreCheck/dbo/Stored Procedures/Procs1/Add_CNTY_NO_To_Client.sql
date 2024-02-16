-- Alter Procedure Add_CNTY_NO_To_Client

CREATE PROCEDURE dbo.Add_CNTY_NO_To_Client AS

Update CLIENT Set CNTY_NO=TblCounties.CNTY_NO FROM dbo.TblCounties where client.homecounty = TblCounties.county


CREATE Procedure [dbo].[Add_CNTY_NO_To_Civil] AS

Update CIVIL Set CNTY_NO=Counties.CNTY_NO FROM Counties where civil.county = Counties.county

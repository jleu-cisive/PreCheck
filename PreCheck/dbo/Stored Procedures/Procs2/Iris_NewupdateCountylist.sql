-- Alter Procedure Iris_NewupdateCountylist

CREATE PROCEDURE [dbo].[Iris_NewupdateCountylist] @vid int AS
SELECT     Iris_Researcher_Charges.Researcher_id,Iris_Researcher_Charges.id, Iris_Researcher_Charges.Researcher_Fel, Iris_Researcher_Charges.Researcher_Mis, 
                      Iris_Researcher_Charges.Researcher_fed, Iris_Researcher_Charges.Researcher_alias, Iris_Researcher_Charges.Researcher_combo, 
                      Iris_Researcher_Charges.Researcher_other, Iris_Researcher_Charges.Researcher_Default, Researcher_Courtfees,
                      Iris_Researcher_Charges.Researcher_Aliases_count, Iris_Researcher_Charges.cnty_no, TblCounties.State, TblCounties.A_County, 
                      TblCounties.Country,dbo.Iris_researcher_Charges.Researcher_CourtFees
FROM         Iris_Researcher_Charges INNER JOIN
                      dbo.TblCounties ON Iris_Researcher_Charges.cnty_no = TblCounties.CNTY_NO
where   Iris_Researcher_Charges.Researcher_id = @vid

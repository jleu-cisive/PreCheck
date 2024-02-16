
CREATE PROCEDURE [dbo].[Iris_R_GetCountyDetails] @id int AS
SELECT     dbo.Iris_researchers.R_Name, dbo.Iris_researchers.Contact_Name, dbo.Iris_researchers.R_Email_Address, dbo.Iris_researchers.R_Address, 
                      dbo.Iris_researchers.R_City, dbo.Iris_researchers.R_State_Province, dbo.Iris_researchers.R_Zip, dbo.Iris_researchers.R_Phone, 
                      dbo.Iris_researchers.R_Alternate_Phone, dbo.Iris_researchers.R_Fax, dbo.Iris_researcher_Charges.Researcher_Fel, dbo.Iris_researcher_Charges.Researcher_Mis, 
                      dbo.Iris_researcher_Charges.Researcher_fed, dbo.Iris_researcher_Charges.Researcher_alias, dbo.Iris_researcher_Charges.Researcher_combo, 
                      dbo.Iris_researcher_Charges.Researcher_other, dbo.Iris_researcher_Charges.Researcher_Default, dbo.Iris_researcher_Charges.Researcher_id, 
                      dbo.Iris_researcher_Charges.id,iris_researchers.r_vendornotes,dbo.Iris_researcher_Charges.Researcher_CourtFees
FROM         dbo.Iris_researcher_Charges LEFT OUTER JOIN
                      dbo.Iris_researchers ON dbo.Iris_researcher_Charges.Researcher_id = dbo.Iris_researchers.R_id
                   where iris_researcher_charges.id = @id


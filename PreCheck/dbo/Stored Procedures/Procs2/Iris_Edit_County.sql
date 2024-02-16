CREATE PROCEDURE Iris_Edit_County @rid int AS
SELECT     dbo.Iris_County.id AS editcountyid, dbo.Iris_State.id AS editstateid, dbo.Iris_Researcher_Charges.Researcher_id, 
                      dbo.Iris_Researcher_Charges.Researcher_county, dbo.Iris_Researcher_Charges.Researcher_state, dbo.Iris_Researcher_Charges.id, 
                      dbo.Iris_Researcher_Charges.Researcher_Fel, dbo.Iris_Researcher_Charges.Researcher_Mis, dbo.Iris_Researcher_Charges.Researcher_fed, 
                      dbo.Iris_Researcher_Charges.Researcher_alias, dbo.Iris_Researcher_Charges.Researcher_combo, dbo.Iris_Researcher_Charges.Researcher_other, 
                      dbo.Iris_Researcher_Charges.Researcher_Default, dbo.Iris_Researcher_Charges.Researcher_Aliases_count
FROM         dbo.Iris_State RIGHT OUTER JOIN
                      dbo.Iris_County ON dbo.Iris_State.STATE = dbo.Iris_County.STATE RIGHT OUTER JOIN
                      dbo.Iris_Researcher_Charges ON dbo.Iris_County.STATE = dbo.Iris_Researcher_Charges.Researcher_state AND 
                      dbo.Iris_County.COUNTY = dbo.Iris_Researcher_Charges.Researcher_county
WHERE     (dbo.Iris_Researcher_Charges.Researcher_id = @rid)
order by iris_researcher_charges.Researcher_state,iris_researcher_charges.Researcher_county

CREATE PROCEDURE Iris_Tobeworked AS
SELECT DISTINCT 
                    Crim_Que.Bis_Crim_County as county, crim_que.crim_time as date,Crim_Que.Crim_Time, Crim_Que.B_Rule, Iris_Researchers.R_Name as vendor, 
                      Iris_Researchers.R_Firstname, Iris_Researchers.R_Lastname, Crim_Que.Vendorid, Iris_Researchers.R_Delivery, 
                      Crim_Que.County,crim_que.county as iris_county, Crim_Que.State as iris_state
FROM         Iris_Researchers RIGHT OUTER JOIN
                      Crim_Que ON Iris_Researchers.R_id = Crim_Que.Vendorid
WHERE     (Crim_Que.Vendorid IS NULL) AND (Crim_Que.Tobeworked = 1)

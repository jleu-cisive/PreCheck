CREATE PROCEDURE Iris_Staging_Detail @apno int AS
SELECT     Crim_Que.Appno, Appl.[Last], Appl.[First], Appl.Middle, Appl.Alias, Appl.Alias2, Appl.Alias3, Appl.Alias4, 
                      Crim_Que.Status, Crim_Que.BatchNumber, Crim_Que.Ordered, Crim_Que.Clear, Crim_Que.Vendorid, 
                      Iris_Researchers.R_Name, Crim_Que.Queid, Crim_Que.Crimid
FROM         Appl INNER JOIN
                      Crim_Que ON Appl.APNO = Crim_Que.Appno LEFT OUTER JOIN
                      Iris_Researchers ON Crim_Que.Vendorid = Iris_Researchers.R_id
where crim_que.appno = @apno

-- Alter Procedure Iris_Staging_County_Rule
CREATE PROCEDURE dbo.Iris_Staging_County_Rule @tappno int, @cntyno int  AS
/*SELECT  Crim_Que.Queid,Crim_Que.sent_bis,Crimid,Crim_Que.Crimid,Crim_Que.degree,crim_que.pub_notes, Crim_Que.Appno, Crim_Que.County, Crim_Que.State, Crim_Que.Vendorid, 
     Crim_Que.B_Rule, Crim_Que.Ordered,crim_que.disp_date,Crim_Que.Clear, Crim_Que.Status, Iris_Researchers.R_id,crim_que.sentence,crim_que.fine, 
    Iris_Researchers.R_Name,crim_que.caseno,crim_que.date_filed,crim_que.offense,crim_que.disposition FROM Crim_Que INNER JOIN 
     Iris_Researchers ON Crim_Que.Vendorid = Iris_Researchers.R_id where appno = @tappno and b_rule = 'Yes' order by crim_que.county*/
SELECT      dbo.Crim.CrimID, dbo.Crim.CrimID AS Expr1, dbo.Crim.Degree, dbo.Crim.Pub_Notes, dbo.Crim.APNO, dbo.TblCounties.A_County, crim.dob,crim.ssn,crim.name,
                      dbo.TblCounties.State, dbo.Crim.vendorid, dbo.Crim.b_rule, dbo.Crim.Ordered, dbo.Crim.Disp_Date, dbo.Crim.Clear, dbo.Crim.status, 
                      dbo.Iris_Researchers.R_id, dbo.Crim.Sentence, dbo.Crim.Fine, dbo.Iris_Researchers.R_Name, dbo.Crim.CaseNo, dbo.Crim.Date_Filed, 
                      dbo.Crim.Offense, dbo.Crim.Disposition,crim.cnty_no,crim.priv_notes
FROM         dbo.Iris_Researchers INNER JOIN
                      dbo.Crim ON dbo.Iris_Researchers.R_id = dbo.Crim.vendorid LEFT OUTER JOIN
                      dbo.TblCounties ON dbo.Crim.CNTY_NO = dbo.TblCounties.CNTY_NO
WHERE     (dbo.Crim.APNO = @tappno) AND (dbo.Crim.b_rule = 'Yes') AND (dbo.Crim.CNTY_NO =  @cntyno)
ORDER BY dbo.TblCounties.A_County

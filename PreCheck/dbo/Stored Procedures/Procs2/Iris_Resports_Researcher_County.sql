CREATE PROCEDURE Iris_Resports_Researcher_County @rid int,@cntyno int, @startdate varchar(10),@enddate varchar(10)  AS
SELECT      A.CrimID, A.Ordered,iris_researchers.r_name,
                          (SELECT     COUNT(*)
                            FROM          Crim
                            WHERE      (Crim.Apno = A.Apno) AND ((Crim.Clear = 'f') OR
                                                   (Crim.Clear = 'p'))) AS Total_Hits,
                          (SELECT     COUNT(*)
                            FROM          Crim
                            WHERE      (Crim.Apno = A.Apno) AND (crim.clear = 't')) AS Total_NoHits, A.vendorid, A.APNO, dbo.Counties.CNTY_NO, dbo.Counties.State, 
                      dbo.Counties.A_County
FROM         dbo.Crim A WITH (NOLOCK) INNER JOIN
                      dbo.Iris_Researchers WITH (NOLOCK) ON A.vendorid = dbo.Iris_Researchers.R_id INNER JOIN
                      dbo.Counties WITH (NOLOCK) ON A.CNTY_NO = dbo.Counties.CNTY_NO
WHERE     (dbo.DatePart(A.Ordered) BETWEEN dbo.DatePart(@startdate) AND dbo.DatePart(@enddate)) AND (A.vendorid = @rid) AND 
                      (dbo.Counties.CNTY_NO = @cntyno)
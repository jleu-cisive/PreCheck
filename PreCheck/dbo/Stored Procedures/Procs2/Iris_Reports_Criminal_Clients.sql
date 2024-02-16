CREATE PROCEDURE Iris_Reports_Criminal_Clients @clno int, @startdate varchar(10),@enddate varchar(10) AS
 
SELECT     A.APNO, A.ApStatus, A.ApDate, C.CLNO, C.Name AS Client_Name,
                          (SELECT     COUNT(*)
                            FROM          Crim
                            WHERE      (Crim.Apno = A.Apno) AND ((Crim.Clear = 'f') OR
                                                   (Crim.Clear = 'p'))) AS Crim_Count,
                          (SELECT     COUNT(*)
                            FROM          Crim
                            WHERE      (Crim.Apno = A.Apno)) AS Crim_Total
 
FROM         dbo.Appl A WITH (NOLOCK) INNER JOIN
                      dbo.Client C WITH (NOLOCK) ON A.CLNO = C.CLNO
WHERE    (C.CLNO = @clno)
and (dbo.datepart(a.apdate) between dbo.datepart(@startdate) and dbo.datepart(@enddate))
ORDER BY A.ApDate

CREATE PROCEDURE [dbo].[Activity_Summary_Report] @begdate varchar(10), @enddate varchar(10),@clno int AS
SET NOCOUNT ON
SELECT  c.clno,c.name,

                          (SELECT     COUNT(*)
                            FROM          Crim (NOLOCK) 
                            WHERE      (Crim.Apno = A.Apno)) AS Crim_Count,
                          (SELECT     COUNT(*)
                            FROM          Crim (NOLOCK) 
                            WHERE      (Crim.Apno = A.Apno) AND (Crim.Clear = 'p' or crim.clear = 'f')) AS Neg_Crim_Count,

                 (SELECT     COUNT(*)
                            FROM          Civil (NOLOCK) 
                            WHERE      (Civil.Apno = A.Apno))  AS Civil_Count,
                          (SELECT     COUNT(*)
                            FROM          Civil (NOLOCK) 
                            WHERE      (Civil.Apno = A.Apno) AND (Civil.Clear <> 'T')) AS Neg_Civil_Count,

                          (SELECT     COUNT(*)
                            FROM          Credit (NOLOCK) 
                            WHERE      (Credit.Apno = A.Apno) and (credit.reptype = 'C')) AS Credit_Count,
                          (SELECT     COUNT(*)
                            FROM          Credit (NOLOCK) 
                            WHERE      (Credit.Apno = A.Apno) AND (Credit.SectStat <> 6) and (credit.reptype = 'C')) AS Neg_Credit_Count,

 (SELECT     COUNT(*)
                            FROM          Credit (NOLOCK) 
                            WHERE      (Credit.Apno = A.Apno) and (credit.reptype = 'S')) AS Social_Count,
                          (SELECT     COUNT(*)
                            FROM          Credit (NOLOCK) 
                            WHERE      (Credit.Apno = A.Apno) AND (Credit.SectStat = 6) and (credit.reptype = 'S')) AS Neg_Social_Count,




                          (SELECT     COUNT(*)
                            FROM          DL (NOLOCK) 
                            WHERE      (DL.Apno = A.Apno) ) AS DL_Count,
                          (SELECT     COUNT(*)
                            FROM          DL (NOLOCK) 
                            WHERE      (DL.Apno = A.Apno) AND (DL.SectStat = '6' or dl.sectstat = '7')) AS Neg_DL_Count,




                          (SELECT     COUNT(*)
                            FROM          Empl (NOLOCK) 
                            WHERE      (Empl.Apno = A.Apno) AND Empl.IsOnReport = 1) AS Empl_Count,
                          (SELECT     COUNT(*)
                            FROM          Empl (NOLOCK) 
                            WHERE      (Empl.Apno = A.Apno) AND Empl.IsOnReport = 1 AND (Empl.SectStat = '6' or empl.sectstat = '7')) AS Neg_Empl_Count,




                          (SELECT     COUNT(*)
                            FROM          Educat (NOLOCK) 
                            WHERE      (Educat.Apno = A.Apno) AND Educat.IsOnReport = 1) AS Educat_Count,
                          (SELECT     COUNT(*)
                            FROM          Educat (NOLOCK) 
                            WHERE      (Educat.Apno = A.Apno) AND Educat.IsOnReport = 1 AND (Educat.SectStat = '6' or educat.sectstat = '7')) AS Neg_Educat_Count,




                          (SELECT     COUNT(*)
                            FROM          ProfLic (NOLOCK) 
                            WHERE      (ProfLic.Apno = A.Apno) AND ProfLic.IsOnReport = 1) AS ProfLic_Count,
                          (SELECT     COUNT(*)
                            FROM          ProfLic (NOLOCK) 
                            WHERE      (ProfLic.Apno = A.Apno) AND ProfLic.IsOnReport = 1 AND (ProfLic.SectStat = '6' or proflic.sectstat = '7')) AS Neg_ProfLic_Count,




                          (SELECT     COUNT(*)
                            FROM          PersRef (NOLOCK) 
                           WHERE      (PersRef.Apno = A.Apno) AND PersRef.IsOnReport = 1 AND (PersRef.SectStat = 1)) AS PersRef_Count,
                          (SELECT     COUNT(*)
                            FROM          PersRef (NOLOCK) 
                            WHERE      (PersRef.Apno = A.Apno) AND PersRef.IsOnReport = 1 AND (PersRef.SectStat <> 1)) AS Neg_PersRef_Count,
                       
  (SELECT     COUNT(*)
                            FROM          medinteg (NOLOCK) 
                            WHERE      (medinteg.Apno = A.Apno) ) AS Med_Count,
                          (SELECT     COUNT(*)
                            FROM          medinteg (NOLOCK) 
                            WHERE      (medinteg.Apno = A.Apno) AND (medinteg.SectStat = '6' or medinteg.sectstat = '7')) AS Neg_Med_Count



FROM         dbo.Appl A (NOLOCK) INNER JOIN
                      dbo.Client C (NOLOCK) ON A.CLNO = C.CLNO
WHERE     (A.ApStatus = 'F') AND (A.ApDate BETWEEN @begdate AND @enddate)  
AND (C.CLNO = @clno)

ORDER BY c.clno,a.apdate


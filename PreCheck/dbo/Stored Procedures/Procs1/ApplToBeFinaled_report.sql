
-- =============================================    
-- Author:  <Amy Liu>    
-- Tune date: <08/16/2021>    
-- Description: fine tune the stored procedure: ApplToBeFinaled    
-- =============================================    


CREATE PROCEDURE [dbo].[ApplToBeFinaled_report] AS    
SET NOCOUNT ON    
    
--The logic doesn't cover if the app has no section attached to it.    
SELECT A.Apno, A.ApStatus, A.UserID, A.Investigator,    
       A.ApDate, A.ReopenDate,  A.Last, A.First, A.Middle,     
       C.Name AS Client_Name    
 FROM dbo.Appl A WITH (NOLOCK)    
INNER JOIN dbo.Client C ON A.Clno = C.Clno    
left join dbo.Crim  WITH (NOLOCK) on crim.apno= a.apno And Crim.IsHidden =0 and ( crim.clear is null or crim.clear in ('R','M','O','V','I','W','Z','D'))    
left join dbo.Civil WITH (NOLOCK) on civil.apno = a.apno AND ((Civil.Clear IS NULL) OR (Civil.Clear = 'O'))    
left join dbo.Credit WITH (NOLOCK) on (Credit.Apno = A.Apno) AND (Credit.SectStat = '0' OR Credit.SectStat = '9')    
left join  dbo.DL WITH (NOLOCK)  on (DL.Apno = A.Apno) AND (DL.SectStat = '0' OR DL.SectStat = '9')    
left join dbo.Empl WITH (NOLOCK) on  (Empl.Apno = A.Apno) AND Empl.IsOnReport = 1 AND (Empl.SectStat = '0' OR Empl.SectStat = '9')    
left join dbo.Educat WITH (NOLOCK) on  (Educat.Apno = A.Apno) AND Educat.IsOnReport = 1 AND (Educat.SectStat = '0' OR Educat.SectStat = '9')    
left join dbo.ProfLic WITH (NOLOCK) on (ProfLic.Apno = A.Apno) AND ProfLic.IsOnReport = 1 AND (ProfLic.SectStat ='0' OR ProfLic.SectStat = '9')    
left join dbo.PersRef WITH (NOLOCK) on  (PersRef.Apno = A.Apno) AND PersRef.IsOnReport = 1 AND (PersRef.SectStat = '0' OR PersRef.SectStat = '9')    
left join dbo.Medinteg WITH (NOLOCK)  on  (Medinteg.Apno = A.Apno) AND (Medinteg.SectStat = '0' OR Medinteg.SectStat = '9')    
WHERE (A.ApStatus IN ('P','W'))    
   AND ISNULL(A.Investigator, '') <> ''    
   AND A.userid IS NOT null    
   --AND ISNULL(A.CAM, '') = '' -- Humera Ahmed on 8/16/2019 for fixing HDT#56758    
   AND ISNULL(c.clienttypeid,-1) <> 15    
and crim.CrimID is null    
and civil.CivilID is null    
and credit.apno is null    
and DL.APNO is null    
and empl.EmplID is null    
and Educat.EducatID is null    
and ProfLic.ProfLicID is null    
and PersRef.PersRefID is null    
and Medinteg.apno is null    
--and a.APNO= 5558112    
ORDER BY A.ApDate    
    
-----------------------    
/*    
 and (     
   SELECT COUNT(*) FROM Crim WITH (NOLOCK)    
   WHERE (Crim.Apno = A.Apno) And Crim.IsHidden =0    
    AND (    
     (Crim.Clear IS NULL) OR (Crim.Clear = 'R') OR (Crim.Clear = 'M') OR (Crim.Clear = 'O')OR (Crim.Clear = 'V')OR (Crim.Clear = 'I')     
     OR (Crim.Clear = 'W') OR (Crim.Clear = 'Z') OR (Crim.Clear = 'D')    
    )    
    )=0    
    and (    
   SELECT COUNT(*) FROM Civil WITH (NOLOCK)    
    WHERE (Civil.Apno = A.Apno)    
   AND ((Civil.Clear IS NULL) OR (Civil.Clear = 'O'))    
  )=0    
 and (    
   SELECT COUNT(*) FROM Credit WITH (NOLOCK)    
   WHERE (Credit.Apno = A.Apno) AND (Credit.SectStat = '0' OR Credit.SectStat = '9')    
  )=0    
 and (    
   SELECT COUNT(*) FROM DL WITH (NOLOCK)    
   WHERE (DL.Apno = A.Apno) AND (DL.SectStat = '0' OR DL.SectStat = '9')    
  )=0    
 and (    
   SELECT COUNT(*) FROM Empl WITH (NOLOCK)    
   WHERE (Empl.Apno = A.Apno) AND Empl.IsOnReport = 1 AND (Empl.SectStat = '0' OR Empl.SectStat = '9')    
  )=0    
 and (    
   SELECT COUNT(*) FROM Educat WITH (NOLOCK)    
   WHERE (Educat.Apno = A.Apno) AND Educat.IsOnReport = 1 AND (Educat.SectStat = '0' OR Educat.SectStat = '9')    
  )=0    
 and (    
   SELECT COUNT(*) FROM ProfLic WITH (NOLOCK)    
   WHERE (ProfLic.Apno = A.Apno) AND ProfLic.IsOnReport = 1 AND (ProfLic.SectStat ='0' OR ProfLic.SectStat = '9')    
  )=0    
 and (    
   SELECT COUNT(*) FROM PersRef WITH (NOLOCK)    
   WHERE (PersRef.Apno = A.Apno) AND PersRef.IsOnReport = 1 AND (PersRef.SectStat = '0' OR PersRef.SectStat = '9')    
  )=0    
 and (    
   SELECT COUNT(*) FROM Medinteg WITH (NOLOCK)           --added RSK 7/5/2006 How did this go so long without being caught?    
   WHERE (Medinteg.Apno = A.Apno) AND (Medinteg.SectStat = '0' OR Medinteg.SectStat = '9')    
  )=0  --added RSK 7/5/2006    
--ORDER BY A.Apno    
ORDER BY A.ApDate    
*/

-- =============================================
-- Date: July 4, 2001
-- Author: Pat Coffer
-- =============================================
CREATE  PROCEDURE [dbo].[ApplToDo]
AS
SET NOCOUNT ON
SELECT A.Apno, A.ApStatus, A.UserID, A.Investigator,
       A.ApDate, A.Last, A.First, A.Middle, 
       C.Name AS Client_Name,
       (SELECT COUNT(1) FROM Crim
	WHERE (Crim.Apno = A.Apno)
	  AND ((Crim.Clear IS NULL) OR (Crim.Clear = 'O')))
        AS Crim_Count,
       (SELECT COUNT(1) FROM Civil
	WHERE (Civil.Apno = A.Apno)
	  AND ((Civil.Clear IS NULL) OR (Civil.Clear = 'O')))
        AS Civil_Count,
       (SELECT COUNT(1) FROM Credit
	WHERE (Credit.Apno = A.Apno)
	  AND (Credit.SectStat = 0)) AS Credit_Count,
       (SELECT COUNT(1) FROM DL
	WHERE (DL.Apno = A.Apno)
	  AND (DL.SectStat = 0)) AS DL_Count,
       (SELECT COUNT(1) FROM Empl
	WHERE (Empl.Apno = A.Apno)
	  AND (Empl.SectStat = 0)) AS Empl_Count,
       (SELECT COUNT(1) FROM Educat
	WHERE (Educat.Apno = A.Apno)
	  AND (Educat.SectStat = 0)) AS Educat_Count,
       (SELECT COUNT(1) FROM ProfLic
	WHERE (ProfLic.Apno = A.Apno)
	  AND (ProfLic.SectStat = 0)) AS ProfLic_Count,
       (SELECT COUNT(1) FROM PersRef
	WHERE (PersRef.Apno = A.Apno)
	  AND (PersRef.SectStat = 0)) AS PersRef_Count
FROM Appl A
JOIN Client C ON A.Clno = C.Clno
WHERE (A.ApStatus IN ('P','W'))
ORDER BY A.ApDate

-- =============================================
-- Date: July 4, 2001
-- Author: Pat Coffer
-- =============================================
CREATE  PROCEDURE ApplToDoUser
	@UserID varchar(8)
AS
SET NOCOUNT ON
SELECT A.Apno, A.ApStatus, A.UserID, A.Investigator,
       A.ApDate, A.Last, A.First, A.Middle, 
       C.Name AS Client_Name,
       (SELECT COUNT(*) FROM Crim
	WHERE (Crim.Apno = A.Apno)
	  AND ((Crim.Clear IS NULL) OR (Crim.Clear = 'O')))
        AS Crim_Count,
       (SELECT COUNT(*) FROM Civil
	WHERE (Civil.Apno = A.Apno)
	  AND ((Civil.Clear IS NULL) OR (Civil.Clear = 'O')))
        AS Civil_Count,
       (SELECT COUNT(*) FROM Credit
	WHERE (Credit.Apno = A.Apno)
	  AND (Credit.SectStat = 0)) AS Credit_Count,
       (SELECT COUNT(*) FROM DL
	WHERE (DL.Apno = A.Apno)
	  AND (DL.SectStat = 0)) AS DL_Count,
       (SELECT COUNT(*) FROM Empl
	WHERE (Empl.Apno = A.Apno)
	  AND (Empl.SectStat = 0)) AS Empl_Count,
       (SELECT COUNT(*) FROM Educat
	WHERE (Educat.Apno = A.Apno)
	  AND (Educat.SectStat = 0)) AS Educat_Count,
       (SELECT COUNT(*) FROM ProfLic
	WHERE (ProfLic.Apno = A.Apno)
	  AND (ProfLic.SectStat = 0)) AS ProfLic_Count,
       (SELECT COUNT(*) FROM PersRef
	WHERE (PersRef.Apno = A.Apno)
	  AND (PersRef.SectStat = 0)) AS PersRef_Count
FROM Appl A
JOIN Client C ON A.Clno = C.Clno
WHERE (A.ApStatus IN ('P','W'))
  AND (A.UserID = @UserID)
ORDER BY A.ApDate

CREATE PROCEDURE test_Need_Review AS



-- Coded for online reporting  JS
SET NOCOUNT ON
SELECT A.Apno, A.ApStatus, A.UserID, A.Investigator,
       A.ApDate, A.Last, A.First, A.Middle, a.reopendate,

       C.Name AS Client_Name,
       'Elapsed'  = CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate, getdate())),
   
       (SELECT COUNT(*) FROM Crim
	WHERE (Crim.Apno = A.Apno)
	  AND (Crim.Clear IS NULL))
        AS Crim_Count,
       (SELECT COUNT(*) FROM Civil
	WHERE (Civil.Apno = A.Apno)
	  AND (Civil.Clear IS NULL))
        AS Civil_Count,
       (SELECT COUNT(*) FROM Credit
	WHERE (Credit.Apno = A.Apno)
	  AND ( credit.sectstat=0)) AS Credit_Count,
       (SELECT COUNT(*) FROM DL
	WHERE (DL.Apno = A.Apno)
	  AND ( DL.SectStat = 0)) AS DL_Count,
       (SELECT COUNT(*) FROM Empl
	WHERE (Empl.Apno = A.Apno)
	  AND ( empl.sectstat = 0)) AS Empl_Count,
       (SELECT COUNT(*) FROM Educat
	WHERE (Educat.Apno = A.Apno)
	  AND ( Educat.SectStat = 0)) AS Educat_Count,
       (SELECT COUNT(*) FROM ProfLic
	WHERE (ProfLic.Apno = A.Apno)
	  AND ( ProfLic.SectStat = 0)) AS ProfLic_Count,
       (SELECT COUNT(*) FROM PersRef
	WHERE (PersRef.Apno = A.Apno)
	  AND ( PersRef.SectStat = 0)) AS PersRef_Count,
        (SELECT COUNT(*) FROM medinteg
	WHERE (medinteg.Apno = A.Apno)
	  AND ( medinteg.SectStat = 0)) AS Medinteg_Count
FROM Appl A
JOIN Client C ON A.Clno = C.Clno
WHERE (A.ApStatus IN ('P','W')) 
and not (CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate, getdate())) < 0)
--and (
--    (SELECT COUNT(*) FROM Crim
--	WHERE (Crim.Apno = A.Apno)
--	  AND (Crim.Clear IS NULL)) <> 0 and
--       (SELECT COUNT(*) FROM Civil
--	WHERE (Civil.Apno = A.Apno)
--	  AND (Civil.Clear IS NULL)) <> 0
--and       (SELECT COUNT(*) FROM Credit
--	WHERE (Credit.Apno = A.Apno)
--	  AND ( credit.sectstat=0)) <> 0
--and        (SELECT COUNT(*) FROM DL
--	WHERE (DL.Apno = A.Apno)
--	  AND ( DL.SectStat = 0))  <> 0)
--       (SELECT COUNT(*) FROM Empl
--	WHERE (Empl.Apno = A.Apno)
--	  AND ( empl.sectstat = 0)) AS Empl_Count,
--       (SELECT COUNT(*) FROM Educat
--	WHERE (Educat.Apno = A.Apno)
--	  AND ( Educat.SectStat = 0)) AS Educat_Count,
--       (SELECT COUNT(*) FROM ProfLic
--	WHERE (ProfLic.Apno = A.Apno)
--	  AND ( ProfLic.SectStat = 0)) AS ProfLic_Count,
--       (SELECT COUNT(*) FROM PersRef
--	WHERE (PersRef.Apno = A.Apno)
--	  AND ( PersRef.SectStat = 0)) AS PersRef_Count,
--        (SELECT COUNT(*) FROM medinteg
--	WHERE (medinteg.Apno = A.Apno)
--	  AND ( medinteg.SectStat = 0)) AS Medinteg_Count

ORDER BY  elapsed Desc
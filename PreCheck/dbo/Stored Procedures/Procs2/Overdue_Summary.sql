CREATE PROCEDURE Overdue_Summary AS
SET NOCOUNT ON
SELECT A.Apno, A.ApStatus, A.UserID, A.Investigator,a.Reopendate,
       A.ApDate, A.Last, A.First, A.Middle, 
     --CONVERT(numeric(7,2), dbo.ElapsedBusinessDays(a.ApDate, getdate())) as Elapsed,
       C.Name AS Client_Name,
       'Elapsed'  = 
      case CONVERT(numeric(7,2), dbo.ElapsedBusinessDays(a.ApDate, getdate()))
         when 4 then 1
         when 5 then 2
        when 6 then 3
        when 7 then 4
        else
        5
        
   end,
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
	  AND (Credit.SectStat = '9')) AS Credit_Count,
       (SELECT COUNT(*) FROM DL
	WHERE (DL.Apno = A.Apno)
	  AND (DL.SectStat = '9')) AS DL_Count,
       (SELECT COUNT(*) FROM Empl
	WHERE (Empl.Apno = A.Apno)
	  AND (Empl.SectStat = '9')) AS Empl_Count,
       (SELECT COUNT(*) FROM Educat
	WHERE (Educat.Apno = A.Apno)
	  AND (Educat.SectStat = '9')) AS Educat_Count,
       (SELECT COUNT(*) FROM ProfLic
	WHERE (ProfLic.Apno = A.Apno)
	  AND (ProfLic.SectStat = '9')) AS ProfLic_Count,
       (SELECT COUNT(*) FROM PersRef
	WHERE (PersRef.Apno = A.Apno)
	  AND (PersRef.SectStat = '9')) AS PersRef_Count
FROM Appl A
JOIN Client C ON A.Clno = C.Clno
WHERE (A.ApStatus IN ('P','W')) 
and not CONVERT(numeric(7,2), dbo.ElapsedBusinessDays(a.ApDate, getdate())) < 4 
--and A.apdate >= DATEADD(day, -2, getdate())
ORDER BY  elapsed Desc
-- A.ApDate
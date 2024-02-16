CREATE PROCEDURE [dbo].[Overdue_Status_Per_Client] @clno int  AS
-- Coded for online reporting  JS
SET NOCOUNT ON
SELECT A.Apno, A.ApStatus, A.UserID, A.Investigator,
       A.ApDate, A.Last, A.First, A.Middle, a.reopendate,
     --CONVERT(numeric(7,2), dbo.ElapsedBusinessDays(a.ApDate, getdate())) as Elapsed,
       C.Name AS Client_Name,
       'Elapsed'  = CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate, getdate())),
      --case CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate, getdate()))
       --when 1 then 1
      -- when 2 then 2
      -- when 3 then 3
      -- when 4 then 4
      -- when 5 then 5
      -- when 6 then 6
      -- else
      -- 7
       --when 3 then 1
        --when 4 then 2
       --when 5 then 3
       --when 6 then 4
        --else
        --5
        
  -- end,
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
	  AND (Credit.SectStat = '9' or credit.sectstat='0')) AS Credit_Count,
       (SELECT COUNT(*) FROM DL
	WHERE (DL.Apno = A.Apno)
	  AND (DL.SectStat = '9' or DL.SectStat = '0')) AS DL_Count,
       (SELECT COUNT(*) FROM Empl
	WHERE (Empl.Apno = A.Apno)
	  AND (Empl.SectStat = '9' or empl.sectstat = '0') AND Empl.IsOnReport = 1) AS Empl_Count,
       (SELECT COUNT(*) FROM Educat
	WHERE (Educat.Apno = A.Apno)
	  AND (Educat.SectStat = '9' or Educat.SectStat = '0') AND Educat.IsOnReport = 1) AS Educat_Count,
       (SELECT COUNT(*) FROM ProfLic
	WHERE (ProfLic.Apno = A.Apno)
	  AND (ProfLic.SectStat = '9' or ProfLic.SectStat = '0') AND ProfLic.IsOnReport = 1) AS ProfLic_Count,
       (SELECT COUNT(*) FROM PersRef
	WHERE (PersRef.Apno = A.Apno)
	  AND (PersRef.SectStat = '9' or PersRef.SectStat = '0') AND PersRef.IsOnReport = 1) AS PersRef_Count,
        (SELECT COUNT(*) FROM medinteg
	WHERE (medinteg.Apno = A.Apno)
	  AND (medinteg.SectStat = '9' or medinteg.SectStat = '0')) AS Medinteg_Count
FROM Appl A
JOIN Client C ON A.Clno = C.Clno
WHERE (A.ApStatus IN ('P','W')) 
and not CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate, getdate())) < 0 
and (c.clno = @clno)
--and A.apdate >= DATEADD(day, -2, getdate())
ORDER BY  elapsed Desc
-- A.ApDate

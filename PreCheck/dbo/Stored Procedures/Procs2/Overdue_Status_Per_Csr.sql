
CREATE PROCEDURE [dbo].[Overdue_Status_Per_Csr] @csrt varchar(20) AS


-- Overdue status per CSR
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
       (SELECT COUNT(*) FROM Crim with (nolock)
	WHERE (Crim.Apno = A.Apno) 
	  AND ((Crim.Clear IS NULL) OR (Crim.Clear = 'O')))
        AS Crim_Count,
       (SELECT COUNT(*) FROM Civil with (nolock)
	WHERE (Civil.Apno = A.Apno)
	  AND ((Civil.Clear IS NULL) OR (Civil.Clear = 'O')))
        AS Civil_Count,
       (SELECT COUNT(*) FROM Credit with (nolock)
	WHERE (Credit.Apno = A.Apno) 
	  AND (Credit.SectStat = '9')) AS Credit_Count,
       (SELECT COUNT(*) FROM DL with (nolock)
	WHERE (DL.Apno = A.Apno) 
	  AND (DL.SectStat = '9')) AS DL_Count,
       (SELECT COUNT(*) FROM Empl with (nolock)
	WHERE (Empl.Apno = A.Apno) AND Empl.IsOnReport = 1
 	  AND (Empl.SectStat = '9')) AS Empl_Count,
       (SELECT COUNT(*) FROM Educat with (nolock)
	WHERE (Educat.Apno = A.Apno) AND Educat.IsOnReport = 1
	  AND (Educat.SectStat = '9')) AS Educat_Count,
       (SELECT COUNT(*) FROM ProfLic with (nolock)
	WHERE (ProfLic.Apno = A.Apno) AND ProfLic.IsOnReport = 1
	  AND (ProfLic.SectStat = '9')) AS ProfLic_Count,
       (SELECT COUNT(*) FROM PersRef with (nolock)
	WHERE (PersRef.Apno = A.Apno) AND PersRef.IsOnReport = 1
 	  AND (PersRef.SectStat = '9')) AS PersRef_Count
FROM Appl A with (nolock)
JOIN Client C  with (nolock) ON A.Clno = C.Clno
WHERE (A.ApStatus IN ('P','W')) and a.userid = @csrt
--and not CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate, getdate())) < 0 
--and A.apdate >= DATEADD(day, -2, getdate())
ORDER BY  elapsed Desc
-- A.ApDate





set ANSI_NULLS OFF
set QUOTED_IDENTIFIER OFF


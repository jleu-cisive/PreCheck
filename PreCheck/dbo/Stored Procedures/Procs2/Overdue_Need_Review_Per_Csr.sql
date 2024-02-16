
CREATE PROCEDURE [dbo].[Overdue_Need_Review_Per_Csr] @csrt varchar(20) AS


-- Overdue status per CSR
-- Coded for online reporting  JS
SET NOCOUNT ON
SELECT A.Apno, A.ApStatus, A.UserID, A.Investigator,
       A.ApDate, A.Last, A.First, A.Middle, a.reopendate,
          C.Name AS Client_Name,
       'Elapsed'  = CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate, getdate())),
         (SELECT COUNT(*) FROM Crim  with (nolock) 
	WHERE (Crim.Apno = A.Apno)  AND (Crim.IsHidden = 0)
	  AND (Crim.Clear IS NULL))
        AS Crim_Count,
       (SELECT COUNT(*) FROM Civil with (nolock) 
	WHERE (Civil.Apno = A.Apno)
	  AND (Civil.Clear IS NULL))
        AS Civil_Count,
       (SELECT COUNT(*) FROM Credit with (nolock) 
	WHERE (Credit.Apno = A.Apno)
	  AND (Credit.SectStat = '0')) AS Credit_Count,
       (SELECT COUNT(*) FROM DL with (nolock) 
	WHERE (DL.Apno = A.Apno)
	  AND (DL.SectStat = '0')) AS DL_Count,
       (SELECT COUNT(*) FROM Empl with (nolock) 
	WHERE (Empl.Apno = A.Apno) AND Empl.IsOnReport = 1
	  AND (Empl.SectStat = '0')) AS Empl_Count,
       (SELECT COUNT(*) FROM Educat with (nolock) 
	WHERE (Educat.Apno = A.Apno) AND Educat.IsOnReport = 1
	  AND (Educat.SectStat = '0')) AS Educat_Count,
       (SELECT COUNT(*) FROM ProfLic with (nolock) 
	WHERE (ProfLic.Apno = A.Apno) AND ProfLic.IsOnReport = 1
	  AND (ProfLic.SectStat = '0')) AS ProfLic_Count,
       (SELECT COUNT(*) FROM PersRef with (nolock) 
	WHERE (PersRef.Apno = A.Apno) AND PersRef.IsOnReport = 1
	  AND (PersRef.SectStat = '0')) AS PersRef_Count,
      (SELECT COUNT(*) FROM medinteg with (nolock) 
	WHERE (medinteg.Apno = A.Apno) 
	  AND ( medinteg.SectStat = '0')) AS Medinteg_Count
FROM Appl A with (nolock) 
JOIN Client C  with (nolock) ON A.Clno = C.Clno
WHERE (A.ApStatus IN ('P','W')) and (a.userid = @csrt)
and (not CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate, getdate())) < 0) AND (A.ApDate is not null)

ORDER BY  elapsed Desc



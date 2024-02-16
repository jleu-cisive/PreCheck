
CREATE PROCEDURE [dbo].[Overdue_DNC] AS



-- Coded for online reporting  JS
SET NOCOUNT ON
SELECT A.Apno, A.ApStatus, A.UserID, A.Investigator,PC_Time_Stamp,
       A.ApDate, A.Last, A.First, A.Middle, a.reopendate,

       C.Name AS Client_Name,
       'Elapsed'  = CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate, getdate())),
   
       (SELECT COUNT(*) FROM Crim  with (nolock)
	WHERE (Crim.Apno = A.Apno) 
	  AND (Crim.Clear IS NULL))
        AS Crim_Count,
       (SELECT 0)
        AS Civil_Count,
       (SELECT COUNT(*) FROM Credit with (nolock)
	WHERE (Credit.Apno = A.Apno) 
	  AND ( credit.sectstat='0')) AS Credit_Count,
       (SELECT COUNT(*) FROM DL with (nolock)
	WHERE (DL.Apno = A.Apno) 
	  AND ( DL.SectStat = '0')) AS DL_Count,
       (SELECT COUNT(*) FROM Empl with (nolock)
	WHERE (Empl.Apno = A.Apno) AND Empl.IsOnReport = 1
	  AND ( empl.sectstat = '9' and empl.dnc = 1)) AS Empl_Count,
       (SELECT COUNT(*) FROM Educat with (nolock)
	WHERE (Educat.Apno = A.Apno) AND Educat.IsOnReport = 1
	  AND ( Educat.SectStat = '0')) AS Educat_Count,
       (SELECT COUNT(*) FROM ProfLic with (nolock)
	WHERE (ProfLic.Apno = A.Apno) AND ProfLic.IsOnReport = 1
	  AND ( ProfLic.SectStat = '0')) AS ProfLic_Count,
       (SELECT COUNT(*) FROM PersRef with (nolock)
	WHERE (PersRef.Apno = A.Apno) AND PersRef.IsOnReport = 1
	  AND ( PersRef.SectStat = '0')) AS PersRef_Count,
        (SELECT COUNT(*) FROM medinteg with (nolock)
	WHERE (medinteg.Apno = A.Apno) 
	  AND ( medinteg.SectStat = '0')) AS Medinteg_Count
FROM Appl A with (nolock)
JOIN Client C  with (nolock) ON A.Clno = C.Clno
WHERE (A.ApStatus IN ('P','W')) 
and not CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate, getdate())) < 0

ORDER BY  elapsed Desc


set ANSI_NULLS OFF
set QUOTED_IDENTIFIER OFF


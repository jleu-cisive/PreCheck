CREATE  PROCEDURE [dbo].[Client_Summary] @timestart varchar(10),
	@timeend varchar(10)
AS
-- Coded for online crystal reports - JS
SET NOCOUNT ON
SELECT  count(a.apno) as total, AVG(CONVERT(numeric(7,2), dbo.ElapsedBusinessDays(a.ApDate, a.CompDate))) as Elapsed,
       C.Name AS Client_Name,a.apno,
       (SELECT COUNT(*) FROM Crim
	WHERE (Crim.Apno = A.Apno)
	  )
        AS Crim_Count,
       
           (SELECT COUNT(*) FROM DL
	WHERE (DL.Apno = A.Apno) 
	  AND (DL.SectStat = 4 or DL.SectStat = 5)) AS DL_Count,
       (SELECT COUNT(*) FROM Empl
	WHERE (Empl.Apno = A.Apno) AND Empl.IsOnReport = 1
	  AND (Empl.SectStat = 4 or Empl.SectStat = 5 or Empl.Sectstat = 6)) AS Empl_Count,
       (SELECT COUNT(*) FROM Educat
	WHERE (Educat.Apno = A.Apno) AND Educat.IsOnReport = 1
	  AND (Educat.SectStat = 4 or Educat.SectStat = 5)) AS Educat_Count,
       (SELECT COUNT(*) FROM ProfLic
	WHERE (ProfLic.Apno = A.Apno) AND ProfLic.IsOnReport = 1
	  AND (ProfLic.SectStat = 4  or ProfLic.SectStat = 5)) AS ProfLic_Count,
       (SELECT COUNT(*) FROM PersRef
	WHERE (PersRef.Apno = A.Apno) AND PersRef.IsOnReport = 1
	  AND (PersRef.SectStat = 4 or PersRef.SectStat = 5 )) AS PersRef_Count
FROM Appl A
JOIN Client C ON A.Clno = C.Clno
WHERE    (A.compdate BETWEEN  @timestart AND @timeend) AND (a.ApStatus <> 'M')



--WHERE    A.compdate BETWEEN CONVERT(DATETIME, @timestart, 102) AND CONVERT(DATETIME, 
--                      @timeend, 102)
--WHERE (A.ApStatus IN ('P','W'))  
--and A.a--pdate >= DATEADD(day, -2, getdate())
group by c.name,a.apno
ORDER BY  c.name Desc
-- A.ApDate
set ANSI_NULLS OFF
set QUOTED_IDENTIFIER OFF

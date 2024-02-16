


CREATE PROCEDURE [dbo].[Empl_GetNewwork_Report]  AS
-- Coded for online reporting  JS
SET NOCOUNT ON
SELECT A.Apno, A.ApStatus, A.UserID, e.Investigator,a.reopendate,
       A.ApDate, A.Last, A.First, A.Middle, CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate, getdate())) as Elapsed,
       C.Name AS Client_Name,
    --   'Elapsed'  = 
    --  case CONVERT(numeric(7,2), dbo.ElapsedBusinessDays(a.ApDate, getdate()))
     --    when 4 then 1
     --    when 5 then 2
     --   when 6 then 3
      --  when 7 then 4
      --  else
      --  5
        
   --end,
       (SELECT COUNT(*) FROM Empl
	WHERE (Empl.Apno = A.Apno)
	  AND (Empl.SectStat = '0') AND Empl.IsOnReport = 1) AS Empl_Count
FROM Appl A
JOIN Client C ON A.Clno = C.Clno
Join Empl E on a.apno = e.apno
WHERE (A.ApStatus IN ('P','W')) 
--and not CONVERT(numeric(7,2), dbo.ElapsedBusinessDays(a.ApDate, getdate())) < 4  
and     (SELECT COUNT(*) FROM Empl
	WHERE (Empl.Apno = A.Apno) AND Empl.IsOnReport = 1
	  AND (Empl.SectStat = '0' and empl.Dnc = 0))  > 0
--and A.apdate >= DATEADD(day, -2, getdate())
ORDER BY  elapsed Desc
-- A.ApDate


set ANSI_NULLS OFF
set QUOTED_IDENTIFIER OFF



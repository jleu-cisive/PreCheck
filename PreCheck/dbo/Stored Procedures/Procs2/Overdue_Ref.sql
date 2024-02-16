CREATE PROCEDURE Overdue_Ref  AS
-- Coded for online reporting  JS
SET NOCOUNT ON
SELECT A.Apno, A.ApStatus, A.UserID, A.Investigator,
       A.ApDate, A.Last, A.First, A.Middle, 
     --CONVERT(numeric(7,2), dbo.ElapsedBusinessDays(a.ApDate, getdate())) as Elapsed,
       C.Name AS Client_Name,
       'Elapsed'  = 
      case CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate, getdate())) 
         when 4 then 1
         when 5 then 2
        when 6 then 3
        when 7 then 4
        else
        5
   end,
       (SELECT COUNT(*) FROM PersRef
	WHERE (PersRef.Apno = A.Apno)
	  AND (PersRef.SectStat = '9')) AS PersRef_Count
FROM Appl A
JOIN Client C ON A.Clno = C.Clno
WHERE (A.ApStatus IN ('P','W')) 
and not CONVERT(numeric(7,2), dbo.ElapsedBusinessDays(a.ApDate, getdate())) < 4  
--and A.apdate >= DATEADD(day, -2, getdate())
and  (SELECT COUNT(*) FROM PersRef
	WHERE (PersRef.Apno = A.Apno)
	  AND (PersRef.SectStat = '0')) > 0
ORDER BY  elapsed Desc
-- A.ApDate
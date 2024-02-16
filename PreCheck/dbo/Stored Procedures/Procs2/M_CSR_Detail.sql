

CREATE PROCEDURE [dbo].[M_CSR_Detail] @t_sortby varchar(20)
 AS
-- Coded for online reporting  JS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET NOCOUNT ON
DECLARE @SearchSQL varchar(5000)
If (select @t_sortby) = 'no'
begin
SELECT A.Apno, A.ApStatus, A.UserID, A.Investigator,a.pc_time_stamp,
       A.ApDate, A.Last, A.First, A.Middle, 
     --CONVERT(numeric(7,2), dbo.ElapsedBusinessDays(a.ApDate, getdate())) as Elapsed,
       C.Name AS Client_Name,
       'Elapsed'  = 
       CONVERT(numeric(7,2), dbo.ElapsedBusinessDays(a.ApDate, getdate())),
      
       (SELECT COUNT(*) FROM Crim with (nolock) 
	WHERE (Crim.Apno = A.Apno)
	  AND ((Crim.Clear IS NULL) OR (Crim.Clear = 'O')))
        AS Crim_Count,
       (SELECT 0)
        AS Civil_Count,
       (SELECT COUNT(*) FROM Credit with (nolock) 
	WHERE (Credit.Apno = A.Apno)
	  AND (Credit.SectStat = '0')) AS Credit_Count,
       (SELECT COUNT(*) FROM DL with (nolock) 
	WHERE (DL.Apno = A.Apno)
	  AND (DL.SectStat = '0')) AS DL_Count,
       (SELECT COUNT(*) FROM Empl with (nolock) 
	WHERE (Empl.Apno = A.Apno)
	  AND (Empl.SectStat = '0')) AS Empl_Count,
       (SELECT COUNT(*) FROM Educat with (nolock) 
	WHERE (Educat.Apno = A.Apno)
	  AND (Educat.SectStat = '0')) AS Educat_Count,
       (SELECT COUNT(*) FROM ProfLic with (nolock) 
	WHERE (ProfLic.Apno = A.Apno)
	  AND (ProfLic.SectStat = '0')) AS ProfLic_Count,
       (SELECT COUNT(*) FROM PersRef with (nolock) 
	WHERE (PersRef.Apno = A.Apno)
	  AND (PersRef.SectStat = '0')) AS PersRef_Count
FROM Appl A  with (nolock) 
JOIN Client C  with (nolock) ON A.Clno = C.Clno
WHERE (A.ApStatus IN ('P','W')) 
--and A.apdate >= DATEADD(day, -2, getdate())
ORDER BY elapsed DESC
-- A.ApDate
end
If (select @t_sortby) <> 'no'
begin
select @searchsql = '
SELECT A.Apno, A.ApStatus, A.UserID, A.Investigator,a.pc_time_stamp,
       A.ApDate, A.Last, A.First, A.Middle, 
       C.Name AS Client_Name,
       ''Elapsed''  = 
       CONVERT(numeric(7,2), dbo.ElapsedBusinessDays(a.ApDate, getdate())),
      
       (SELECT COUNT(*) FROM Crim  with (nolock) 
	WHERE (Crim.Apno = A.Apno)
	  AND ((Crim.Clear IS NULL) OR (Crim.Clear = ''O'')))
        AS Crim_Count,
       (SELECT 0)
        AS Civil_Count,
       (SELECT COUNT(*) FROM Credit with (nolock) 
	WHERE (Credit.Apno = A.Apno)
	  AND (Credit.SectStat = 0)) AS Credit_Count,
       (SELECT COUNT(*) FROM DL with (nolock) 
	WHERE (DL.Apno = A.Apno)
	  AND (DL.SectStat = ''0'')) AS DL_Count,
       (SELECT COUNT(*) FROM Empl with (nolock) 
	WHERE (Empl.Apno = A.Apno)
	  AND (Empl.SectStat = ''0'')) AS Empl_Count,
       (SELECT COUNT(*) FROM Educat with (nolock) 
	WHERE (Educat.Apno = A.Apno)
	  AND (Educat.SectStat = ''0'')) AS Educat_Count,
       (SELECT COUNT(*) FROM ProfLic with (nolock) 
	WHERE (ProfLic.Apno = A.Apno)
	  AND (ProfLic.SectStat = ''0'')) AS ProfLic_Count,
       (SELECT COUNT(*) FROM PersRef with (nolock) 
	WHERE (PersRef.Apno = A.Apno)
	  AND (PersRef.SectStat = ''0'')) AS PersRef_Count
FROM Appl A with (nolock) 
JOIN Client C  with (nolock) ON A.Clno = C.Clno
WHERE (A.ApStatus IN (''P'',''W'')) 
ORDER BY  ' + @t_sortby +' '
exec(@SearchSQL)
end

SET TRANSACTION ISOLATION LEVEL READ COMMITTED 
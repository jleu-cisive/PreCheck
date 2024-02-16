
Create PROCEDURE [dbo].[Overdue_educat]  
AS
-- Coded for online reporting  JS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT DISTINCT
	COUNT(E.EducatID) AS Educat_Count
	, A.APNO
	, A.ApStatus
	, A.UserID
	, E.Investigator
	, A.ReopenDate
	, A.ApDate
	, A.[Last]
	, A.[First]
	, A.Middle
	, CONVERT(numeric(7, 2), dbo.NewElapsedBusinessDays(A.ReopenDate, A.ApDate, GETDATE())) AS Elapsed
	, C.Name AS Client_Name
	, E.SectStat
	, U.Disabled
	, E.School
FROM dbo.Appl A 
	INNER JOIN dbo.Client C 
	ON A.CLNO = C.CLNO 
	INNER JOIN dbo.Educat E
	ON A.APNO = E.APNO
	INNER JOIN dbo.Users U
	ON A.Investigator = U.UserID
WHERE ( SELECT COUNT(*) 
		FROM dbo.Educat 
		WHERE dbo.Educat.Apno = A.Apno 
			AND dbo.Educat.SectStat = '9' 
			--AND dbo.Educat.DNC = 0 
       ) > 0
GROUP BY E.EducatID
	, A.APNO
	, A.ApStatus
	, A.UserID
	, E.Investigator
	, A.ReopenDate
	, A.ApDate
	, A.[Last]
	, A.[First]
	, A.Middle
	-- Elapsed
	--, CONVERT(numeric(7, 2), dbo.NewElapsedBusinessDays(A.ReopenDate, A.ApDate, GETDATE()))
	, C.Name
	, E.SectStat
	, U.Disabled
	, E.School
HAVING A.ApStatus IN ('P', 'W')
	AND E.SectStat = '9'
ORDER BY Elapsed DESC


/*SELECT A.Apno, A.ApStatus, A.UserID, A.Investigator,a.reopendate,
       A.ApDate, A.Last, A.First, A.Middle, CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate, getdate())) as Elapsed,

       C.Name AS Client_Name,

       (SELECT COUNT(*) FROM Empl
	WHERE (Empl.Apno = A.Apno)
	  AND (Empl.SectStat = 9)) AS Empl_Count
FROM Appl A
JOIN Client C ON A.Clno = C.Clno
WHERE (A.ApStatus IN ('P','W')) 
--and not CONVERT(numeric(7,2), dbo.ElapsedBusinessDays(a.ApDate, getdate())) < 4  
and     (SELECT COUNT(*) FROM Empl
	WHERE (Empl.Apno = A.Apno)
	  AND (Empl.SectStat = 9 and empl.Dnc = 0))  > 0
--and A.apdate >= DATEADD(day, -2, getdate())
ORDER BY  elapsed Desc
-- A.ApDate*/

SET NOCOUNT OFF
SET TRANSACTION ISOLATION LEVEL READ COMMITTED






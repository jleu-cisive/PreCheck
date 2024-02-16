
CREATE PROCEDURE [dbo].[Overdue_empl]  
AS
-- Coded for online reporting  JS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT DISTINCT
	COUNT(E.EmplID) AS Empl_Count
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
	, E.Employer
FROM dbo.Appl A  with (nolock)
	INNER JOIN dbo.Client C  with (nolock)
	ON A.CLNO = C.CLNO 
	INNER JOIN dbo.Empl E with (nolock)
	ON A.APNO = E.APNO
	INNER JOIN dbo.Users U with (nolock)
	ON A.Investigator = U.UserID
WHERE ( SELECT COUNT(*) 
		FROM dbo.Empl  with (nolock)
		WHERE dbo.Empl.Apno = A.Apno 
			AND dbo.Empl.SectStat = '9' 
			AND dbo.Empl.DNC = 0 AND dbo.Empl.IsOnReport = 1) > 0
GROUP BY E.EmplID
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
	, E.Employer
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

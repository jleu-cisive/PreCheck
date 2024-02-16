
CREATE PROCEDURE [dbo].[Overdue_Investigator]  @invest varchar(50) AS
-- Coded for online reporting  JS
SET NOCOUNT ON
SELECT distinct COUNT(*) AS Empl_Count,A.Apno, A.ApStatus, A.UserID, e.investigator,
       A.ApDate, A.Last, A.First, A.Middle, 
     CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate, getdate())) as Elapsed,
       C.Name AS Client_Name
FROM Appl A with (nolock)
JOIN Client C with (nolock) ON A.Clno = C.Clno
JOIN empl E with (nolock) on A.apno = E.apno
WHERE (A.ApStatus IN ('P','W')) and ((SELECT COUNT(*) FROM Empl with (nolock)
	WHERE (E.Apno = A.Apno)
	  AND (E.SectStat = '9' and e.Dnc = 0))  > 0 ) and (e.investigator = @invest)
group by a.apno,a.apstatus,a.userid,e.investigator,a.apdate,a.last,a.first,a.middle,a.reopendate,
c.name
ORDER BY  elapsed Desc
-- A.ApDate

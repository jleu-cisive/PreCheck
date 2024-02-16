


CREATE PROCEDURE [dbo].[Overdue_Edu_Investigator_Summary]  AS
-- Coded for online reporting  JS
SET NOCOUNT ON
--SELECT E.INVESTIGATOR,
--(SELECT count (*)
--FROM educat with (nolock)
-- join appl with (nolock) on educat.apno=appl.apno
-- where educat.investigator= E.investigator and educat.SectStat = '9'
--  and Educat.IsOnReport = 1 AND appl.ApStatus IN ('P','W')
-- and (CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(appl.Reopendate,appl.ApDate, getdate())))= 5.0) as '5 Days',
--
--(SELECT count (*)
--FROM educat with (nolock) join appl with (nolock) on educat.apno=appl.apno where educat.investigator= E.investigator and educat.SectStat = '9'   and Educat.IsOnReport = 1 AND appl.ApStatus IN ('P','W') and (CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(appl.Reopendate,appl.ApDate, getdate())))= 4.0 ) as '4 Days',
--
--(SELECT count (*)
--FROM educat with (nolock) join appl with (nolock) on educat.apno=appl.apno where educat.investigator= E.investigator and educat.SectStat = '9'   and  Educat.IsOnReport = 1 AND appl.ApStatus IN ('P','W') and (CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(appl.Reopendate,appl.ApDate, getdate())))= 3.0 ) as '3 Days',
--
--(SELECT count (*) 
--FROM educat with (nolock) join appl with (nolock) on educat.apno=appl.apno where educat.investigator= E.investigator and educat.SectStat = '9'   and Educat.IsOnReport = 1 AND appl.ApStatus IN ('P','W') and (CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(appl.Reopendate,appl.ApDate, getdate())))= 2.0 ) as '2 Days',
--
--(SELECT count (*) 
--FROM educat with (nolock) join appl with (nolock) on educat.apno=appl.apno where educat.investigator= E.investigator and educat.SectStat = '9'   and appl.ApStatus IN ('P','W') and (CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(appl.Reopendate,appl.ApDate, getdate())))= 1.0 ) as '1 Days'
--FROM educat E with (nolock) join users u with (nolock) on u.userid=e.investigator where u.educat=1 AND E.IsOnReport = 1
--GROUP BY E.INVESTIGATOR
--ORDER BY E.INVESTIGATOR
select u.userid as INVESTIGATOR,
(SELECT count (*)
FROM educat with (nolock)
 join appl with (nolock) on educat.apno=appl.apno
 where educat.investigator= u.userid and educat.SectStat = '9'
  and Educat.IsOnReport = 1 AND appl.ApStatus IN ('P','W')
 and (CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(appl.Reopendate,appl.ApDate, getdate())))= 5.0) as '5 Days',
(SELECT count (*)
FROM educat with (nolock) join appl with (nolock) on educat.apno=appl.apno where educat.investigator= u.userid and educat.SectStat = '9'   and Educat.IsOnReport = 1 AND appl.ApStatus IN ('P','W') and (CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(appl.Reopendate,appl.ApDate, getdate())))= 4.0 ) as '4 Days',

(SELECT count (*)
FROM educat with (nolock) join appl with (nolock) on educat.apno=appl.apno where educat.investigator= u.userid and educat.SectStat = '9'   and  Educat.IsOnReport = 1 AND appl.ApStatus IN ('P','W') and (CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(appl.Reopendate,appl.ApDate, getdate())))= 3.0 ) as '3 Days',

(SELECT count (*) 
FROM educat with (nolock) join appl with (nolock) on educat.apno=appl.apno where educat.investigator= u.userid and educat.SectStat = '9'   and Educat.IsOnReport = 1 AND appl.ApStatus IN ('P','W') and (CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(appl.Reopendate,appl.ApDate, getdate())))= 2.0 ) as '2 Days',

(SELECT count (*) 
FROM educat with (nolock) join appl with (nolock) on educat.apno=appl.apno where educat.investigator= u.userid and educat.SectStat = '9'   and appl.ApStatus IN ('P','W') and (CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(appl.Reopendate,appl.ApDate, getdate())))= 1.0 ) as '1 Days'
FROM users u with (nolock) where u.educat=1
ORDER BY INVESTIGATOR

SET NOCOUNT OFF



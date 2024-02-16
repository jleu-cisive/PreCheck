




CREATE PROCEDURE [dbo].[Overdue_Investigator_Summary]  AS
-- Coded for online reporting  JS


SET NOCOUNT ON
--added 11-29-07
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


select u.userid as INVESTIGATOR,
(SELECT count (*)
FROM empl with (nolock,index=IX_Empl_Apno)  join appl (nolock,index=IX_Appl_CLNO) on empl.apno=appl.apno where empl.investigator= u.userid and Empl.SectStat = '9' and Empl.Dnc = 0 and Empl.IsOnReport = 1 AND appl.ApStatus IN ('P','W') and (CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(appl.Reopendate,appl.ApDate, getdate())))= 5.0) as '5 Days'

,(SELECT count (*)
FROM empl (nolock,index=IX_Empl_Apno)  join appl (nolock,index=IX_Appl_CLNO) on empl.apno=appl.apno where empl.investigator= u.userid and Empl.SectStat = '9' and Empl.Dnc = 0  and Empl.IsOnReport = 1 AND appl.ApStatus IN ('P','W') and (CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(appl.Reopendate,appl.ApDate, getdate())))= 4.0 ) as '4 Days'

,(SELECT count (*)
FROM empl (nolock,index=IX_Empl_Apno)  join appl (nolock,index=IX_Appl_CLNO) on empl.apno=appl.apno where empl.investigator= u.userid and Empl.SectStat = '9' and Empl.Dnc = 0  and Empl.IsOnReport = 1 AND appl.ApStatus IN ('P','W') and (CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(appl.Reopendate,appl.ApDate, getdate())))= 3.0 ) as '3 Days'

,(SELECT count (*) 
FROM empl (nolock,index=IX_Empl_Apno)  join appl (nolock,index=IX_Appl_CLNO) on empl.apno=appl.apno where empl.investigator= u.userid and Empl.SectStat = '9' and Empl.Dnc = 0  and Empl.IsOnReport = 1 AND appl.ApStatus IN ('P','W') and (CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(appl.Reopendate,appl.ApDate, getdate())))= 2.0 ) as '2 Days'

,(SELECT count (*) 
FROM empl (nolock,index=IX_Empl_Apno)  join appl (nolock,index=IX_Appl_CLNO) on empl.apno=appl.apno where empl.investigator= u.userid and Empl.SectStat = '9' and Empl.Dnc = 0  and Empl.IsOnReport = 1 AND appl.ApStatus IN ('P','W') and (CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(appl.Reopendate,appl.ApDate, getdate())))= 1.0 ) as '1 Days'

FROM users u with (nolock) where u.empl=1
ORDER BY INVESTIGATOR


SET NOCOUNT OFF
SET TRANSACTION ISOLATION LEVEL READ COMMITTED






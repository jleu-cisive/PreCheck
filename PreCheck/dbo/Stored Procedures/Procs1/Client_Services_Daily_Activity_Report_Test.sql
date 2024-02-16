

-- EXEC Client_Services_Daily_Activity_Report_Test 'ASweet','10/1/2016','10/31/2016'

-- =============================================
-- Author: Radhika Dereddy
-- Date: 10/12/2016
-- Description :The report will in part be based on the current CAM Activity Report 
-- with the creation of new columns to support the addition of information that is currently 
-- not reported but needed to supplement the monitoring of activity in the Client Services Department.
-- =============================================
CREATE PROCEDURE [dbo].[Client_Services_Daily_Activity_Report_Test]
@CAM  varchar(8),
@StartDate Datetime,
@EndDate DateTime

AS
SET NOCOUNT ON

SET @EndDate = DATEADD(d,1,@EndDate)

--Step 1 : Get all the USERID's from APPL
SELECT DISTINCT UserID INTO #tempUSER1
FROM  APPL WITH (NOLOCK)
WHERE appl.ApStatus IN ('F','W')
and appl.CompDate between @StartDate and @EndDate
and UserID is not null
ORDER BY UserID

--Print : Select * from #tempUSER1


--Step 2 : Get the ChangeLog for those USERID's only
SELECT  UserID, id INTO #tempChangeLog
FROM dbo.ChangeLog WITH (NOLOCK)
WHERE  (TableName = 'Appl.ApStatus') and Newvalue = 'F' and OldValue = 'P'
and ChangeDate between @StartDate and @EndDate
ORDER BY UserID

--Print :  Select * from #tempChangeLog


--Step 3 : Get all the USERID's from #tempChangeLog and insert into #tempUser1
INSERT INTO #tempUSER1 (UserID)
(SELECT  DISTINCT UserID FROM  #tempChangeLog)

--Print :  Select * from #tempUSER1


--Step 4 : Get the consolidated list of USERID's from #tempChangeLog and #tempUSER1 and insert into #tempUser
SELECT  DISTINCT UserID INTO #tempUSER
FROM  #tempUSER1 
ORDER BY UserID

--Print :  Select * from #tempUSER


--Step 5 :  Get the Apno's which are in 'To be Finaled' status
CREATE TABLE #tmpAppl (Apno int,ApStatus char(1),UserID varchar(8), Investigator varchar(8),
					   ApDate Datetime, ReopenDate Datetime,  Last varchar(20), First varchar(20), Middle varchar(20), 
					   Client_Name varchar(100))
INSERT INTO #tmpAppl
EXEC [ApplToBeFinaled]

--Print :  Select * from #tmpAppl


--Step 6 : Overdue Needs Review
CREATE TABLE #tmpOverdue (Apno int, ApStatus char(1), UserID varchar(8), Investigator varchar(8), PC_Time_Stamp datetime,
					   ApDate Datetime, Last varchar(20), First varchar(20), Middle varchar(20), ReopenDate Datetime,
					   Client_Name varchar(100), Elapsed decimal, Crim_Count int, Civil_Count int, Credit_Count int, 
					   DL_Count int, Empl_Count int, Educat_Count int, ProfLic_Count int, PersRef_Count int, MedInteg_Count int)

INSERT INTO #tmpOverdue
EXEC [Overdue_Need_Review]

-- Print: Select * from #tmpOverdue


--Step 7 : In Progress Reviewed
SELECT  UserID, id INTO #tempInProgressReviewd
FROM dbo.ChangeLog WITH (NOLOCK)
WHERE  (TableName = 'Appl.InProgressReviewed') and Newvalue = 'True' and OldValue = 'False'
and ChangeDate between @StartDate and @EndDate
and UserID is not null
ORDER BY UserID

-- Print: Select * from #tempInProgressReviewd


--Step 8 : Final Query
 --select UserID,
select * from appl aPending with (nolock) where aPending.UserID = 'Asweet' and  aPending.ApStatus IN ('P','W') and aPending.origcompdate is null and (aPending.Apdate between @StartDate and @EndDate) Order by aPending.Apdate--) as 'Pending',
--(Select count(*) from  #tmpAppl where #tmpAppl.UserID = U.UserID) as 'TBF',
--(select count(*) from appl aAssigned with (nolock) where aAssigned.UserID = U.UserID  and (aAssigned.CompDate  between @StartDate and @EndDate)) as 'Total Closed Where Assigned',
--(select count(*) from #tmpOverdue td with(nolock) where td.UserID = U.UserID and td.ApStatus IN('P', 'W'))  as 'ONR',
select * from appl a1 with (nolock) where (CONVERT(numeric(7,2), dbo.ElapsedBusinessDays_3(a1.ApDate, getdate())))= 1.0 AND a1.ApStatus IN ('P','W')and a1.origcompdate is null and a1.UserID ='Asweet' and (a1.Apdate between @StartDate and @EndDate)--) as '1 Day',
select * from appl a2 with (nolock) where (CONVERT(numeric(7,2), dbo.ElapsedBusinessDays_3(a2.ApDate, getdate())))= 2.0 AND a2.ApStatus IN ('P','W')and a2.origcompdate is null and a2.UserID ='Asweet' and (a2.Apdate between @StartDate and @EndDate)--) as '2 Day',
select * from appl a3 with (nolock) where (CONVERT(numeric(7,2), dbo.ElapsedBusinessDays_3(a3.ApDate, getdate())))= 3.0 AND a3.ApStatus IN ('P','W')and a3.origcompdate is null and a3.UserID ='Asweet' and (a3.Apdate between @StartDate and @EndDate)--) as '3 Day',
select * from appl a4 with (nolock) where (CONVERT(numeric(7,2), dbo.ElapsedBusinessDays_3(a4.ApDate, getdate())))= 4.0 AND a4.ApStatus IN ('P','W')and a4.origcompdate is null and a4.UserID ='Asweet' and (a4.Apdate between @StartDate and @EndDate)--) as '4 Day',
select * from appl a5 with (nolock) where (CONVERT(numeric(7,2), dbo.ElapsedBusinessDays_3(a5.ApDate, getdate())))>= 5.0 AND a5.ApStatus IN ('P','W')and a5.origcompdate is null and a5.UserID ='Asweet' and (a5.Apdate between @StartDate and @EndDate)--) as '5 Day+',
select * from appl a10 with (nolock) where (CONVERT(numeric(7,2), dbo.ElapsedBusinessDays_3(a10.ApDate, getdate())))>= 10.0 AND a10.ApStatus IN ('P','W')and a10.origcompdate is null and a10.UserID='Asweet' and (a10.Apdate between @StartDate and @EndDate)--) as '10 Day+',
--(select count(*) from #tempInProgressReviewd ipr where ipr.UserID = U.UserID  and id in (select appl.APNO from appl appl with (nolock) where appl.UserID = U.UserID and (appl.Apdate between @StartDate and @EndDate))) as 'In Progress Reviewed by Own',
--(select count(*) from #tempInProgressReviewd pr where pr.UserID = U.UserID  and id not in (select appl.APNO from appl appl with (nolock) where appl.UserID = U.UserID and (appl.Apdate between @StartDate and @EndDate))) as 'In Progress Reviewed of Others',
--(select count(*) from #tempInProgressReviewd r where r.UserID = U.UserID ) as 'Total In Progress Reviewed',
--(select count(*) from #tempChangeLog t where t.UserID = U.UserID and id in (select aA.APNO from appl aA with (nolock) where aA.UserID = U.UserID  and (aA.CompDate  between @StartDate and @EndDate))) as 'Closed by Own' ,
--(select count(*) from #tempChangeLog t where t.UserID = U.UserID and id not in (select aB.APNO from appl aB with (nolock) where aB.UserID = U.UserID  and (aB.CompDate  between @StartDate and @EndDate))) as 'Closed of Others' ,
--(select count(*) from #tempChangeLog t where t.UserID = U.UserID ) as 'Total Closed',
--(select count(*) from #tempChangeLog t where t.UserID = U.UserID and id in (select aA.APNO from appl aA with (nolock) where aA.UserID = 'Student'  and (aA.CompDate  between @StartDate and @EndDate))) AS 'Total Closed for Student',
--(select count(*) from #tempChangeLog t where t.UserID = U.UserID and id in (select aA.APNO from appl aA with (nolock) where aA.UserID = 'TenetSer'  and (aA.CompDate  between @StartDate and @EndDate))) AS 'Total Closed for Tenet',
--(select count(*) from #tempChangeLog t where t.UserID = U.UserID and id in (select aA.APNO from appl aA with (nolock) where aA.UserID = 'HROCServ'  and (aA.CompDate  between @StartDate and @EndDate))) AS 'Total Closed for HROCServ'
--from #tempUSER U

--UNION ALL

--Select 'AUTO CLOSE' as UserID,
--0 as 'Pending',
--0 as 'TBF',
--(select count(*) from ApplAutoCloseLog t where ClosedOn  between @StartDate and @EndDate) as 'Total Closed Where Assigned',
--0 as 'ONR',
--0 as '1 Day',
--0 as '2 Day', 
--0 as '3 Day',
--0 as '4 Day',
--0 as '5 Day+',
--0 as '10 Day+',
--0 as 'In Progress Reviewed by Own',
--0 as 'In Progress Reviewed of Others',
--0 as 'Total In Progress Reviewed',
--0 as 'Closed by Own',
--0 as 'Closed of Others' , 
--0 as 'Total Closed',
--0 AS 'Total Closed for Student',
--0 AS 'Total Closed for Tenet',
--0 AS 'Total Closed for HROCServ'


--Step 10 : Drop all temporary tables

DROP TABLE #tempChangeLog

DROP TABLE #tmpAppl

DROP TABLE #tempUSER1

DROP TABLE #tmpOverdue

DROP TABLE #tempInProgressReviewd







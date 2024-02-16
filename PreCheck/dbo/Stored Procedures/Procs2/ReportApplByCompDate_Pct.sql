

CREATE PROCEDURE [dbo].[ReportApplByCompDate_Pct] @from_date datetime, @to_date datetime AS

--SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL
    READ UNCOMMITTED
    
select userID, 
 (select count(a.apno) from appl with (nolock)
   where compdate >= @from_date and compdate < @to_date and userID=a.userID and CLNO not in (2167,1934,2178,1939,1972,1937,1935,1932,1940,1938,1936)
   group by userID) as Count,
 100* (select count(dbo.ApplWorkDuration(apdate, origcompdate, reopendate, compdate)) from appl  with (nolock)
   where compdate >= @from_date and compdate < @to_date and userID=a.userID and (dbo.ApplWorkDuration(apdate, origcompdate, reopendate, compdate)) <=0 and CLNO not in (2167,1934,2178,1939,1972,1937,1935,1932,1940,1938,1936)
   group by userID) /
  (select count(a.apno) from appl  with (nolock)
   where compdate >= @from_date and compdate < @to_date and userID=a.userID
   group by userID) as SameDay,
 100* (select count(dbo.ApplWorkDuration(apdate, origcompdate, reopendate, compdate)) from appl  with (nolock)
   where compdate >= @from_date and compdate < @to_date and userID=a.userID and (dbo.ApplWorkDuration(apdate, origcompdate, reopendate, compdate)) <=1 and CLNO not in (2167,1934,2178,1939,1972,1937,1935,1932,1940,1938,1936)
   group by userID) /
  (select count(a.apno) from appl  with (nolock)
   where compdate >= @from_date and compdate < @to_date and userID=a.userID
   group by userID) as OneDay,

 100* (select count(dbo.ApplWorkDuration(apdate, origcompdate, reopendate, compdate)) from appl  with (nolock)
   where compdate >= @from_date and compdate < @to_date and userID=a.userID and (dbo.ApplWorkDuration(apdate, origcompdate, reopendate, compdate)) <=2 and CLNO not in (2167,1934,2178,1939,1972,1937,1935,1932,1940,1938,1936)
   group by userID) /
  (select count(a.apno) from appl  with (nolock)
   where compdate >= @from_date and compdate < @to_date and userID=a.userID
   group by userID) as TwoDays,
 100* (select count(dbo.ApplWorkDuration(apdate, origcompdate, reopendate, compdate)) from appl  with (nolock)
   where compdate >= @from_date and compdate < @to_date and userID=a.userID and (dbo.ApplWorkDuration(apdate, origcompdate, reopendate, compdate)) <=3 and CLNO not in (2167,1934,2178,1939,1972,1937,1935,1932,1940,1938,1936)
   group by userID) /
  (select count(a.apno) from appl  with (nolock)
   where compdate >= @from_date and compdate < @to_date and userID=a.userID
   group by userID) as ThreeDays,
 100* (select count(dbo.ApplWorkDuration(apdate, origcompdate, reopendate, compdate)) from appl  with (nolock)
   where compdate >= @from_date and compdate < @to_date and userID=a.userID and (dbo.ApplWorkDuration(apdate, origcompdate, reopendate, compdate)) <=4 and CLNO not in (2167,1934,2178,1939,1972,1937,1935,1932,1940,1938,1936)
   group by userID) /
  (select count(a.apno) from appl  with (nolock)
   where compdate >= @from_date and compdate < @to_date and userID=a.userID
   group by userID) as FourDays,
 100* (select count(dbo.ApplWorkDuration(apdate, origcompdate, reopendate, compdate)) from appl  with (nolock)
   where compdate >= @from_date and compdate < @to_date and userID=a.userID and (dbo.ApplWorkDuration(apdate, origcompdate, reopendate, compdate)) <=5 and CLNO not in (2167,1934,2178,1939,1972,1937,1935,1932,1940,1938,1936)
   group by userID) /
  (select count(a.apno) from appl  with (nolock)
   where compdate >= @from_date and compdate < @to_date and userID=a.userID
   group by userID) as FiveDays,
 100* (select count(dbo.ApplWorkDuration(apdate, origcompdate, reopendate, compdate)) from appl  with (nolock)
   where compdate >= @from_date and compdate < @to_date and userID=a.userID and (dbo.ApplWorkDuration(apdate, origcompdate, reopendate, compdate)) <=6 and CLNO not in (2167,1934,2178,1939,1972,1937,1935,1932,1940,1938,1936)
   group by userID) /
  (select count(a.apno) from appl  with (nolock)
   where compdate >= @from_date and compdate < @to_date and userID=a.userID
   group by userID) as SixDays,

'100' As  SixDaysPlus

from appl a  with (nolock)
where compdate >= @from_date and compdate < @to_date and apstatus in ('W','F')  and CLNO not in (2167,1934,2178,1939,1972,1937,1935,1932,1940,1938,1936)
-- and userID in ('CCALDARE','DSANGERH','HOLLIE','LMCGOWAN','LWALKER','SBAZAN','SDUNN','ZDAIGLE')
-- and userID in (SELECT User FROM Appl WHERE )
group by userID
--having  count(apno) is not null
having  (select count(a.apno) from appl  with (nolock)
   where compdate >= @from_date and compdate < @to_date and userID=a.userID
   group by userID) >= 0
order by UserID

SET TRANSACTION ISOLATION LEVEL
    READ COMMITTED
CREATE PROCEDURE dbo.TurnAroundByCSR_counts @from_date datetime, @to_date datetime AS

--SET NOCOUNT ON

select userID, 
 (select count(dbo.ApplWorkDuration(apdate, origcompdate, reopendate, compdate)) from appl
   where compdate >= @from_date and compdate < @to_date and userID=a.userID and (dbo.ApplWorkDuration(apdate, origcompdate, reopendate, compdate)) <=0 and CLNO not in (2167,1934,2178,1939,1972,1937,1935,1932,1940,1938,1936)
   group by userID) as SameDay,
 (select count(dbo.ApplWorkDuration(apdate, origcompdate, reopendate, compdate)) from appl
   where compdate >= @from_date and compdate < @to_date and userID=a.userID and (dbo.ApplWorkDuration(apdate, origcompdate, reopendate, compdate)) <=1 and CLNO not in (2167,1934,2178,1939,1972,1937,1935,1932,1940,1938,1936)
   group by userID) as OneDay,

 (select count(dbo.ApplWorkDuration(apdate, origcompdate, reopendate, compdate)) from appl
   where compdate >= @from_date and compdate < @to_date and userID=a.userID and (dbo.ApplWorkDuration(apdate, origcompdate, reopendate, compdate)) <=2 and CLNO not in (2167,1934,2178,1939,1972,1937,1935,1932,1940,1938,1936)
   group by userID) as TwoDays,
 (select count(dbo.ApplWorkDuration(apdate, origcompdate, reopendate, compdate)) from appl
   where compdate >= @from_date and compdate < @to_date and userID=a.userID and (dbo.ApplWorkDuration(apdate, origcompdate, reopendate, compdate)) <=3 and CLNO not in (2167,1934,2178,1939,1972,1937,1935,1932,1940,1938,1936)
   group by userID) as ThreeDays,
 (select count(dbo.ApplWorkDuration(apdate, origcompdate, reopendate, compdate)) from appl
   where compdate >= @from_date and compdate < @to_date and userID=a.userID and (dbo.ApplWorkDuration(apdate, origcompdate, reopendate, compdate)) <=4 and CLNO not in (2167,1934,2178,1939,1972,1937,1935,1932,1940,1938,1936)
   group by userID) as FourDays,
 (select count(dbo.ApplWorkDuration(apdate, origcompdate, reopendate, compdate)) from appl
   where compdate >= @from_date and compdate < @to_date and userID=a.userID and (dbo.ApplWorkDuration(apdate, origcompdate, reopendate, compdate)) <=5 and CLNO not in (2167,1934,2178,1939,1972,1937,1935,1932,1940,1938,1936)
   group by userID) as FiveDays,
 (select count(dbo.ApplWorkDuration(apdate, origcompdate, reopendate, compdate)) from appl
   where compdate >= @from_date and compdate < @to_date and userID=a.userID and (dbo.ApplWorkDuration(apdate, origcompdate, reopendate, compdate)) <=6 and CLNO not in (2167,1934,2178,1939,1972,1937,1935,1932,1940,1938,1936)
   group by userID) as SixDays,
 (select count(a.apno) from appl
   where compdate >= @from_date and compdate < @to_date and userID=a.userID and CLNO not in (2167,1934,2178,1939,1972,1937,1935,1932,1940,1938,1936)
   group by userID) as SixDaysPlus

from appl a
where compdate >= @from_date and compdate < @to_date and apstatus in ('W','F')  and CLNO not in (2167,1934,2178,1939,1972,1937,1935,1932,1940,1938,1936)
---- and userID in ('CCALDARE','DSANGERH','HOLLIE','LMCGOWAN','LWALKER','SBAZAN','SDUNN','ZDAIGLE')
---- and userID in (SELECT User FROM Appl WHERE )
group by userID
----having  count(apno) is not null
having  (select count(a.apno) from appl
   where compdate >= @from_date and compdate < @to_date and userID=a.userID
   group by userID) >= 0
order by UserID
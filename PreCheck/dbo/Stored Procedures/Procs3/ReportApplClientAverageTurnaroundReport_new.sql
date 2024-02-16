




/**
Used Apdate instead of compdate to get the records recieved in the given time frame and also finalized
**/


create PROCEDURE [dbo].[ReportApplClientAverageTurnaroundReport_new] @CLNO INT, @from_date datetime, @to_date datetime AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
--include the enddate in the results
Set @to_date = DateAdd(d,1,@to_date)

--schapyala removed and apstatus in ('W','F') from all of the below selects (subqueries included) to accomodate for 100% of apps

select clno,apno,apstatus,apdate,Origcompdate,Reopendate,Compdate,
Case when (apstatus in ('W','F')) then ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate )  ) else ( dbo.elapsedbusinessdays_2( Apdate,current_timestamp)) end ElapsedTime
   into #tmpTAT  from appl with (nolock) 
   where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO


SELECT '0 Day' AS 'Turnaround Time',
(select COUNT( APNO ) from #tmpTAT
Where  ElapsedTime = 0 
group by CLNO) as 'Count',
CAST( 100. * (select COUNT( APNO ) from #tmpTAT
Where  ElapsedTime = 0 
   group by CLNO) /
  (select COUNT( APNO ) from #tmpTAT
   group by CLNO) AS NUMERIC( 5, 2 ) ) AS 'Percentage',
CAST( 100. * (select COUNT( APNO ) from #tmpTAT
Where  ElapsedTime = 0 
   group by CLNO) /
  (select COUNT( APNO ) from #tmpTAT
   group by CLNO) AS NUMERIC( 5, 2 ) ) as 'Cumulative %'
from #tmpTAT a 
group by CLNO
UNION
SELECT '1 Day' AS 'Turnaround Time',
(select COUNT( APNO ) from #tmpTAT
Where  ElapsedTime = 1 
group by CLNO) as 'Count',
CAST( 100. * (select COUNT( APNO ) from #tmpTAT
Where  ElapsedTime = 1 
   group by CLNO) /
  (select COUNT( APNO ) from #tmpTAT
   group by CLNO) AS NUMERIC( 5, 2 ) ) AS 'Percentage',
CAST( 100. * (select COUNT( APNO ) from #tmpTAT
Where  ElapsedTime <=1 
   group by CLNO) /
  (select COUNT( APNO ) from #tmpTAT
   group by CLNO) AS NUMERIC( 5, 2 ) ) as 'Cumulative %'
from #tmpTAT a 
group by CLNO
UNION
SELECT '2 Day' AS 'Turnaround Time',
(select COUNT( APNO ) from #tmpTAT
Where  ElapsedTime = 2 
group by CLNO) as 'Count',
CAST( 100. * (select COUNT( APNO ) from #tmpTAT
Where  ElapsedTime = 2 
   group by CLNO) /
  (select COUNT( APNO ) from #tmpTAT
   group by CLNO) AS NUMERIC( 5, 2 ) ) AS 'Percentage',
CAST( 100. * (select COUNT( APNO ) from #tmpTAT
Where  ElapsedTime <=2 
   group by CLNO) /
  (select COUNT( APNO ) from #tmpTAT
   group by CLNO) AS NUMERIC( 5, 2 ) ) as 'Cumulative %'
from #tmpTAT a 
group by CLNO
UNION
SELECT '3 Day' AS 'Turnaround Time',
(select COUNT( APNO ) from #tmpTAT
Where  ElapsedTime = 3 
group by CLNO) as 'Count',
CAST( 100. * (select COUNT( APNO ) from #tmpTAT
Where  ElapsedTime = 3 
   group by CLNO) /
  (select COUNT( APNO ) from #tmpTAT
   group by CLNO) AS NUMERIC( 5, 2 ) ) AS 'Percentage',
CAST( 100. * (select COUNT( APNO ) from #tmpTAT
Where  ElapsedTime <=3 
   group by CLNO) /
  (select COUNT( APNO ) from #tmpTAT
   group by CLNO) AS NUMERIC( 5, 2 ) ) as 'Cumulative %'
from #tmpTAT a 
group by CLNO
UNION
SELECT '4 Day' AS 'Turnaround Time',
(select COUNT( APNO ) from #tmpTAT
Where  ElapsedTime = 4 
group by CLNO) as 'Count',
CAST( 100. * (select COUNT( APNO ) from #tmpTAT
Where  ElapsedTime = 4 
   group by CLNO) /
  (select COUNT( APNO ) from #tmpTAT
   group by CLNO) AS NUMERIC( 5, 2 ) ) AS 'Percentage',
CAST( 100. * (select COUNT( APNO ) from #tmpTAT
Where  ElapsedTime <=4 
   group by CLNO) /
  (select COUNT( APNO ) from #tmpTAT
   group by CLNO) AS NUMERIC( 5, 2 ) ) as 'Cumulative %'
from #tmpTAT a 
group by CLNO
UNION
SELECT '5 Day' AS 'Turnaround Time',
(select COUNT( APNO ) from #tmpTAT
Where  ElapsedTime = 5 
group by CLNO) as 'Count',
CAST( 100. * (select COUNT( APNO ) from #tmpTAT
Where  ElapsedTime = 5 
   group by CLNO) /
  (select COUNT( APNO ) from #tmpTAT
   group by CLNO) AS NUMERIC( 5, 2 ) ) AS 'Percentage',
CAST( 100. * (select COUNT( APNO ) from #tmpTAT
Where  ElapsedTime <=5 
   group by CLNO) /
  (select COUNT( APNO ) from #tmpTAT
   group by CLNO) AS NUMERIC( 5, 2 ) ) as 'Cumulative %'
from #tmpTAT a 
group by CLNO
UNION
SELECT '6+ Day' AS 'Turnaround Time',
(select COUNT( APNO ) from #tmpTAT
Where  ElapsedTime >=6
group by CLNO) as 'Count',
CAST( 100. * (select COUNT( APNO ) from #tmpTAT
Where  ElapsedTime  >=6
   group by CLNO) /
  (select COUNT( APNO ) from #tmpTAT
   group by CLNO) AS NUMERIC( 5, 2 ) ) AS 'Percentage',
CAST( 100. * (select COUNT( APNO ) from #tmpTAT
Where  ElapsedTime  >=0
   group by CLNO) /
  (select COUNT( APNO ) from #tmpTAT
   group by CLNO) AS NUMERIC( 5, 2 ) ) as 'Cumulative %'
from #tmpTAT a 
group by CLNO
--UNION

/*
SELECT '0 Day' AS 'Turnaround Time',
(select COUNT( APNO ) from appl with (nolock) 
where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO  and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate )  ) = 0 
group by CLNO) as 'Count',
CAST( 100. * (select COUNT( APNO ) from appl with (nolock) 
   where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO  and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 0 
   group by CLNO) /
  (select count( APNO ) from appl with (nolock) 
   where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO
   group by CLNO) AS NUMERIC( 5, 2 ) ) AS 'Percentage',
CAST( 100. * (select COUNT( APNO ) from appl with (nolock) 
   where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO  and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 0 
   group by CLNO) /
  (select count( APNO ) from appl with (nolock) 
   where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO
   group by CLNO) AS NUMERIC( 5, 2 ) ) as 'Cumulative %'
from appl a with (nolock) 
where Apdate >= @from_date and Apdate < @to_date  AND CLNO = @CLNO 
group by CLNO
UNION
SELECT '1 Day',
(select COUNT( APNO ) from appl with (nolock) 
where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO   and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 1 
group by CLNO),
CAST( 100. * (select COUNT( APNO ) from appl with (nolock) 
   where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO  and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 1 
   group by CLNO) /
  (select count( APNO ) from appl with (nolock) 
   where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO
   group by CLNO) AS NUMERIC( 5, 2 ) ),
CAST( 100. * (select COUNT( APNO ) from appl with (nolock) 
   where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO  and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) <= 1 
   group by CLNO) /
  (select count( APNO ) from appl with (nolock) 
   where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO
   group by CLNO) AS NUMERIC( 5, 2 ) )
from appl a with (nolock) 
where Apdate >= @from_date and Apdate < @to_date  AND CLNO = @CLNO 
group by CLNO
UNION
SELECT '2 Days',
(select COUNT( APNO ) from appl with (nolock) 
where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO  and  ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 2 
group by CLNO),
CAST( 100. * (select COUNT( APNO ) from appl with (nolock) 
   where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO  and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 2 
   group by CLNO) /
  (select count( APNO ) from appl with (nolock) 
   where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO
   group by CLNO) AS NUMERIC( 5, 2 ) ),
CAST( 100. * (select COUNT( APNO ) from appl with (nolock) 
   where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO  and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) <= 2 
   group by CLNO) /
  (select count( APNO ) from appl with (nolock) 
   where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO
   group by CLNO) AS NUMERIC( 5, 2 ) )
from appl a with (nolock) 
where Apdate >= @from_date and Apdate < @to_date  AND CLNO = @CLNO 
group by CLNO
UNION
SELECT '3 Days',
(select COUNT( APNO ) from appl with (nolock) 
where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO  and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 3 
group by CLNO),
CAST( 100. * (select COUNT( APNO ) from appl with (nolock) 
   where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO  and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 3 
   group by CLNO) /
  (select count( APNO ) from appl with (nolock) 
   where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO
   group by CLNO) AS NUMERIC( 5, 2 ) ), 
CAST( 100. * (select COUNT( APNO ) from appl with (nolock) 
   where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO  and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) <= 3 
   group by CLNO) /
  (select count( APNO ) from appl with (nolock) 
   where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO
   group by CLNO) AS NUMERIC( 5, 2 ) )
from appl a with (nolock) 
where Apdate >= @from_date and Apdate < @to_date  AND CLNO = @CLNO 
group by CLNO
UNION
SELECT '4 Days',
(select COUNT( APNO ) from appl with (nolock) 
where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO  and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 4 
group by CLNO),
CAST( 100. * (select COUNT( APNO ) from appl with (nolock) 
   where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO  and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 4 
   group by CLNO) /
  (select count( APNO ) from appl with (nolock) 
   where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO
   group by CLNO) AS NUMERIC( 5, 2 ) ),
CAST( 100. * (select COUNT( APNO ) from appl with (nolock) 
   where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO  and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) <= 4 
   group by CLNO) /
  (select count( APNO ) from appl with (nolock) 
   where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO
   group by CLNO) AS NUMERIC( 5, 2 ) )
from appl a with (nolock) 
where Apdate >= @from_date and Apdate < @to_date  AND CLNO = @CLNO 
group by CLNO
UNION
SELECT '5 Days',
(select COUNT( APNO ) from appl with (nolock) 
where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO  and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 5 
group by CLNO),
CAST( 100. * (select COUNT( APNO ) from appl with (nolock) 
   where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO  and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 5 
   group by CLNO) /
  (select count( APNO ) from appl with (nolock) 
   where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO
   group by CLNO) AS NUMERIC( 5, 2 ) ),
CAST( 100. * (select COUNT( APNO ) from appl with (nolock) 
   where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO  and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) <= 5 
   group by CLNO) /
  (select count( APNO ) from appl with (nolock) 
   where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO
   group by CLNO) AS NUMERIC( 5, 2 ) )
from appl a with (nolock) 
where Apdate >= @from_date and Apdate < @to_date  AND CLNO = @CLNO 
group by CLNO
UNION
SELECT '6+ Days',
(select COUNT( APNO ) from appl with (nolock) 
where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO  and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) >= 6 
group by CLNO),
CAST( 100. * (select COUNT( APNO ) from appl with (nolock) 
   where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO  and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) >= 6 
   group by CLNO) /
  (select count( APNO ) from appl with (nolock) 
   where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO
   group by CLNO) AS NUMERIC( 5, 2 ) ),
CAST( 100. * (select COUNT( APNO ) from appl with (nolock) 
   where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO  and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) >= 0
   group by CLNO) /
  (select count( APNO ) from appl with (nolock) 
   where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO
   group by CLNO) AS NUMERIC( 5, 2 ) )
from appl a with (nolock) 
where Apdate >= @from_date and Apdate < @to_date  AND CLNO = @CLNO 
group by CLNO
UNION
SELECT 'Total',
(select COUNT( APNO ) from appl with (nolock) 
where Apdate >= @from_date and Apdate < @to_date and CLNO = @CLNO 
group by CLNO), 100, 100
from appl a with (nolock) 
where Apdate >= @from_date and Apdate < @to_date  AND CLNO = @CLNO 
group by CLNO

*/

SET TRANSACTION ISOLATION LEVEL READ COMMITTED














CREATE PROCEDURE [dbo].[ReportApplClientAverageTurnaroundReport_HarrisCountyHospitalDistrict] @CLNO INT, @from_date datetime, @to_date datetime AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT '0 Day' AS 'Turnaround Time',
(select COUNT( * ) from appl
where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) ) = 0 
group by CLNO) as 'Count',
CAST( 100. * (select count( * ) from appl
   where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) ) = 0 
   group by CLNO) /
  (select count( A.APNO ) from appl
   where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO
   group by CLNO) AS NUMERIC( 5, 2 ) ) AS 'Percentage',
CAST( 100. * (select count( * ) from appl
   where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) = 0 
   group by CLNO) /
  (select count( A.APNO ) from appl
   where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO
   group by CLNO) AS NUMERIC( 5, 2 ) ) as 'Cumulative %'
from appl a
where Origcompdate >= @from_date and Origcompdate < @to_date and apstatus in ('W','F') AND CLNO = @CLNO 
group by CLNO
UNION
SELECT '1 Day',
(select COUNT( * ) from appl
where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) = 1 
group by CLNO),
CAST( 100. * (select count( * ) from appl
   where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) = 1 
   group by CLNO) /
  (select count( A.APNO ) from appl
   where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO
   group by CLNO) AS NUMERIC( 5, 2 ) ),
CAST( 100. * (select count( * ) from appl
   where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) <= 1 
   group by CLNO) /
  (select count( A.APNO ) from appl
   where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO
   group by CLNO) AS NUMERIC( 5, 2 ) )
from appl a
where Origcompdate >= @from_date and Origcompdate < @to_date and apstatus in ('W','F') AND CLNO = @CLNO 
group by CLNO
UNION
SELECT '2 Days',
(select COUNT( * ) from appl
where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) = 2 
group by CLNO),
CAST( 100. * (select count( * ) from appl
   where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) = 2 
   group by CLNO) /
  (select count( A.APNO ) from appl
   where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO
   group by CLNO) AS NUMERIC( 5, 2 ) ),
CAST( 100. * (select count( * ) from appl
   where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) <= 2 
   group by CLNO) /
  (select count( A.APNO ) from appl
   where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO
   group by CLNO) AS NUMERIC( 5, 2 ) )
from appl a
where Origcompdate >= @from_date and Origcompdate < @to_date and apstatus in ('W','F') AND CLNO = @CLNO 
group by CLNO
UNION
SELECT '3 Days',
(select COUNT( * ) from appl
where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) = 3 
group by CLNO),
CAST( 100. * (select count( * ) from appl
   where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) = 3 
   group by CLNO) /
  (select count( A.APNO ) from appl
   where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO
   group by CLNO) AS NUMERIC( 5, 2 ) ),
CAST( 100. * (select count( * ) from appl
   where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) <= 3 
   group by CLNO) /
  (select count( A.APNO ) from appl
   where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO
   group by CLNO) AS NUMERIC( 5, 2 ) )
from appl a
where Origcompdate >= @from_date and Origcompdate < @to_date and apstatus in ('W','F') AND CLNO = @CLNO 
group by CLNO
UNION
SELECT '4 Days',
(select COUNT( * ) from appl
where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) = 4 
group by CLNO),
CAST( 100. * (select count( * ) from appl
   where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) = 4 
   group by CLNO) /
  (select count( A.APNO ) from appl
   where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO
   group by CLNO) AS NUMERIC( 5, 2 ) ),
CAST( 100. * (select count( * ) from appl
   where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) ) <= 4 
   group by CLNO) /
  (select count( A.APNO ) from appl
   where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO
   group by CLNO) AS NUMERIC( 5, 2 ) )
from appl a
where Origcompdate >= @from_date and Origcompdate < @to_date and apstatus in ('W','F') AND CLNO = @CLNO 
group by CLNO
UNION
SELECT '5 Days',
(select COUNT( * ) from appl
where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) = 5 
group by CLNO),
CAST( 100. * (select count( * ) from appl
   where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) = 5 
   group by CLNO) /
  (select count( A.APNO ) from appl
   where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO
   group by CLNO) AS NUMERIC( 5, 2 ) ),
CAST( 100. * (select count( * ) from appl
   where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) ) <= 5 
   group by CLNO) /
  (select count( A.APNO ) from appl
   where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO
   group by CLNO) AS NUMERIC( 5, 2 ) )
from appl a
where Origcompdate >= @from_date and Origcompdate < @to_date and apstatus in ('W','F') AND CLNO = @CLNO 
group by CLNO
UNION
SELECT '6+ Days',
(select COUNT( * ) from appl
where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) >= 6 
group by CLNO),
CAST( 100. * (select count( * ) from appl
   where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) >= 6 
   group by CLNO) /
  (select count( A.APNO ) from appl
   where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO
   group by CLNO) AS NUMERIC( 5, 2 ) ),
CAST( 100. * (select count( * ) from appl
   where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) >= 0 and CLNO not in (2167,1934,2178,1939,1972,1937,1935,1932,1940,1938,1936)
   group by CLNO) /
  (select count( A.APNO ) from appl
   where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO
   group by CLNO) AS NUMERIC( 5, 2 ) )
from appl a
where Origcompdate >= @from_date and Origcompdate < @to_date and apstatus in ('W','F') AND CLNO = @CLNO 
group by CLNO
UNION
SELECT 'Total',
(select COUNT( A.APNO ) from appl
where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO 
group by CLNO), 100, 100
from appl a
where Origcompdate >= @from_date and Origcompdate < @to_date and apstatus in ('W','F') AND CLNO = @CLNO 
group by CLNO


SET TRANSACTION ISOLATION LEVEL READ COMMITTED



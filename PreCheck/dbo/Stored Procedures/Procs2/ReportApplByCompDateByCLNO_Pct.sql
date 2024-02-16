
CREATE PROCEDURE [dbo].[ReportApplByCompDateByCLNO_Pct] @from_date datetime, @to_date datetime AS


SET TRANSACTION ISOLATION LEVEL
    READ UNCOMMITTED
    
    
select A.CLNO, C.NAME,
  (select count( A.APNO ) from appl
   where compdate >= @from_date and compdate < @to_date and CLNO=a.CLNO and CLNO not in (2167,1934,2178,1939,1972,1937,1935,1932,1940,1938,1936)
   group by CLNO) as Count,
CAST( 100. * (select count( * ) from appl
   where compdate >= @from_date and compdate < @to_date and CLNO=a.CLNO and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 0 and CLNO not in (2167,1934,2178,1939,1972,1937,1935,1932,1940,1938,1936)
   group by CLNO) /
  (select count( A.APNO ) from appl
   where compdate >= @from_date and compdate < @to_date and CLNO=a.CLNO
   group by CLNO) AS NUMERIC( 5, 2 ) ) as 'Same Day',
CAST( 100. * (select count( * ) from appl
   where compdate >= @from_date and compdate < @to_date and CLNO=a.CLNO and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 1 and CLNO not in (2167,1934,2178,1939,1972,1937,1935,1932,1940,1938,1936)
   group by CLNO) /
  (select count( A.APNO ) from appl
   where compdate >= @from_date and compdate < @to_date and CLNO=a.CLNO
   group by CLNO) AS NUMERIC( 5, 2 ) ) as 'One Day',
CAST( 100. * (select count( * ) from appl
   where compdate >= @from_date and compdate < @to_date and CLNO=a.CLNO and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 2 and CLNO not in (2167,1934,2178,1939,1972,1937,1935,1932,1940,1938,1936)
   group by CLNO) /
  (select count( A.APNO ) from appl
   where compdate >= @from_date and compdate < @to_date and CLNO=a.CLNO
   group by CLNO) AS NUMERIC( 5, 2 ) ) as 'Two Days',
CAST( 100. * (select count( * ) from appl
   where compdate >= @from_date and compdate < @to_date and CLNO=a.CLNO and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 3 and CLNO not in (2167,1934,2178,1939,1972,1937,1935,1932,1940,1938,1936)
   group by CLNO) /
  (select count( A.APNO ) from appl
   where compdate >= @from_date and compdate < @to_date and CLNO=a.CLNO
   group by CLNO) AS NUMERIC( 5, 2 ) ) as 'Three Days',
CAST( 100. * (select count( * ) from appl
   where compdate >= @from_date and compdate < @to_date and CLNO=a.CLNO and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 4 and CLNO not in (2167,1934,2178,1939,1972,1937,1935,1932,1940,1938,1936)
   group by CLNO) /
  (select count( A.APNO ) from appl
   where compdate >= @from_date and compdate < @to_date and CLNO=a.CLNO
   group by CLNO) AS NUMERIC( 5, 2 ) ) as 'Four Days',
CAST( 100. * (select count( * ) from appl
   where compdate >= @from_date and compdate < @to_date and CLNO=a.CLNO and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) >= 5 and CLNO not in (2167,1934,2178,1939,1972,1937,1935,1932,1940,1938,1936)
   group by CLNO) /
  (select count( A.APNO ) from appl
   where compdate >= @from_date and compdate < @to_date and CLNO=a.CLNO
   group by CLNO) AS NUMERIC( 5, 2 ) ) as 'Five Days Plus'
from appl a INNER JOIN CLIENT C ON A.CLNO = C.CLNO
where compdate >= @from_date and compdate < @to_date and apstatus in ('W','F') -- and A.CLNO not in (2167,1934,2178,1939,1972,1937,1935,1932,1940,1938,1936)   --removed 2/11/2006 by RSK per Kelly
group by A.CLNO, C.NAME
having  (select count(a.apno) from appl
   where compdate >= @from_date and compdate < @to_date and CLNO=a.CLNO
   group by CLNO) >= 0
order by A.CLNO


SET TRANSACTION ISOLATION LEVEL
    READ COMMITTED
    
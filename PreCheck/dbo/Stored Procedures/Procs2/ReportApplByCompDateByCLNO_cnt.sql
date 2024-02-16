
CREATE PROCEDURE [dbo].[ReportApplByCompDateByCLNO_cnt] @from_date datetime, @to_date datetime AS


SET TRANSACTION ISOLATION LEVEL
    READ UNCOMMITTED
    
    
SELECT A.CLNO, C.NAME,
 (select COUNT( * ) from appl
   where compdate >= @from_date and compdate < @to_date and CLNO=a.CLNO and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 0 and CLNO not in (2167,1934,2178,1939,1972,1937,1935,1932,1940,1938,1936)
   group by CLNO) as 'Same Day',
 (select COUNT( * ) from appl
   where compdate >= @from_date and compdate < @to_date and CLNO=a.CLNO and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 1 and CLNO not in (2167,1934,2178,1939,1972,1937,1935,1932,1940,1938,1936)
   group by CLNO) as 'One Day',
 (select COUNT( * ) from appl
   where compdate >= @from_date and compdate < @to_date and CLNO=a.CLNO and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 2 and CLNO not in (2167,1934,2178,1939,1972,1937,1935,1932,1940,1938,1936)
   group by CLNO) as 'Two Days',
 (select COUNT( * ) from appl
   where compdate >= @from_date and compdate < @to_date and CLNO=a.CLNO and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 3 and CLNO not in (2167,1934,2178,1939,1972,1937,1935,1932,1940,1938,1936)
   group by CLNO) as 'Three Days',
 (select COUNT( * ) from appl
   where compdate >= @from_date and compdate < @to_date and CLNO=a.CLNO and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 4 and CLNO not in (2167,1934,2178,1939,1972,1937,1935,1932,1940,1938,1936)
   group by CLNO) as 'Four Days',
 (select COUNT( * ) from appl
   where compdate >= @from_date and compdate < @to_date and CLNO=a.CLNO and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) >= 5 and CLNO not in (2167,1934,2178,1939,1972,1937,1935,1932,1940,1938,1936)
   group by CLNO) as 'Five Days Plus'
from appl a INNER JOIN CLIENT C ON A.CLNO = C.CLNO
where compdate >= @from_date and compdate < @to_date and apstatus in ('W','F') --  AND A.CLNO not in (2167,1934,2178,1939,1972,1937,1935,1932,1940,1938,1936)  --removed 2/11/2006 by RSK per Kelly
group by A.CLNO, C.NAME
having ( select count( A.APNO ) from appl
where compdate >= @from_date and compdate < @to_date and CLNO=a.CLNO
group by CLNO) >= 0
order by A.CLNO

SET TRANSACTION ISOLATION LEVEL
    READ COMMITTED
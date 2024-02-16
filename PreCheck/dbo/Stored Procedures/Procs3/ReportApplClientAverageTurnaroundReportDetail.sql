

/**
Used Apdate instead of compdate to get the records recieved in the given time frame and also finalized
**/


CREATE PROCEDURE [dbo].[ReportApplClientAverageTurnaroundReportDetail] @CLNO INT, @from_date datetime, @to_date datetime AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT APNO AS 'Application Number',
(select ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) )
from appl
where Apdate >= @from_date and Apdate < Dateadd(day,1,@to_date) and CLNO = @CLNO  AND APNO = A.APNO
group by Apdate, Origcompdate, Reopendate, Compdate ) as 'Turnaround Time'
from appl a
where Apdate >= @from_date and Apdate < Dateadd(day,1,@to_date) and apstatus in ('W','F') AND CLNO = @CLNO 
group by APNO
ORDER BY APNO

SET TRANSACTION ISOLATION LEVEL READ COMMITTED



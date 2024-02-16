
CREATE PROCEDURE [dbo].[ReportApplClientAverageTurnaroundReportDetail_HarrisCountyHospitalDistrict] @CLNO INT, @from_date datetime, @to_date datetime AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT APNO AS 'Application Number',
(select ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))
from appl
where Origcompdate >= @from_date and Origcompdate < @to_date and CLNO = @CLNO  AND APNO = A.APNO
group by Apdate, Origcompdate, Reopendate, Compdate ) as 'Turnaround Time'
from appl a
where Origcompdate >= @from_date and Origcompdate < @to_date and apstatus in ('W','F') AND CLNO = @CLNO 
group by APNO
ORDER BY APNO


SET TRANSACTION ISOLATION LEVEL READ COMMITTED
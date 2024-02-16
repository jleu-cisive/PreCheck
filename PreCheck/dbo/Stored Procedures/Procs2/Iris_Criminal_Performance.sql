CREATE PROCEDURE Iris_Criminal_Performance @begdate varchar(10), @enddate varchar(10) AS


select * from dbo.CriminalPerformanceReport(@begdate,@enddate)
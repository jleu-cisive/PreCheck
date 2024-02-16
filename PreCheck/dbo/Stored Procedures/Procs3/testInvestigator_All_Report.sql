CREATE PROCEDURE testInvestigator_All_Report @begdate varchar(10),@enddate varchar(10) AS
-- defined function jsoto
select * from dbo.testInvestigatorAllReport(@begdate,@enddate)
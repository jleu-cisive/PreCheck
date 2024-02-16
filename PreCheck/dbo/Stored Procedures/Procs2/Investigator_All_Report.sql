CREATE PROCEDURE Investigator_All_Report @begdate varchar(10),@enddate varchar(10) AS
-- defined function jsoto
select * from dbo.InvestigatorAllReport(@begdate,@enddate)
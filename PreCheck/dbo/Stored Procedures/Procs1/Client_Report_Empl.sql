CREATE PROCEDURE Client_Report_Empl @apno int AS
select * from empl where apno = @apno order by  from_a

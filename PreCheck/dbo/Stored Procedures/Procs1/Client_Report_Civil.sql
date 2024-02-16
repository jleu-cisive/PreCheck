CREATE PROCEDURE Client_Report_Civil @apno int AS
select * from civil where apno = @apno

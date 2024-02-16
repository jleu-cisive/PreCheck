CREATE PROCEDURE Client_Report_License @apno int AS
select * from proflic where apno = @apno

CREATE PROCEDURE Client_Report_Medicare @apno int AS
select * from medinteg where apno = @apno and sectstat <> 0

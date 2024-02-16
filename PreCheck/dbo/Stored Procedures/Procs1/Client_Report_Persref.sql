CREATE PROCEDURE Client_Report_Persref @apno int  AS
select * from persref where apno = @apno

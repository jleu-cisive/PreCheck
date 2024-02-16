CREATE PROCEDURE Client_Report_Education @apno int  AS
select * from educat where apno = @apno 

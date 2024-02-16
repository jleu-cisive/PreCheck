CREATE PROCEDURE Client_Report_Social  @apno int  AS
select * from credit where apno = @apno
and sectstat <> 4

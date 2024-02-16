CREATE PROCEDURE Client_Report_Crim  @apno int as
select * from crim c 
join crimsectstat s on c.clear = s.crimsect
where c.apno = @apno

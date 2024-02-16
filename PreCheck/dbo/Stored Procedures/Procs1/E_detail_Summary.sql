CREATE PROCEDURE E_detail_Summary  @apno int AS
select * from dbo.e_process_details(@apno) order by category,name asc

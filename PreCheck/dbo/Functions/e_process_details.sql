CREATE FUNCTION dbo.e_process_details(@apno int)
returns @etable table (id int, category varchar(100),Name varchar(100),source varchar(100))
as
begin
-- Educat
Insert into @etable
select educatid as id,'Education' as category,School as name,'Educat' as source
from educat where apno = @apno
--Employment
Insert into @etable
select emplid as id,'Employment' as category,Employer as name,'Empl' as source
from empl where apno = @apno
--Professional License
Insert into @etable
select proflicid as id,'License' as category, Lic_type as name, 'Proflic' as source
from proflic where apno = @apno
insert into @etable
 select crimid as id, 'Criminal' as category, County as name, 'Crim' as source
from crim where apno = @apno
return
end

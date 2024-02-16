CREATE PROCEDURE M_Crimordering @county varchar(100) AS
select a.last,c.crimid,a.first,convert(varchar,a.dob,101) as dob,
c.ordered,a.dl_number,a.ssn,a.middle,a.alias,a.alias2,
a.alias3,a.alias4,a.apno,c.county,
c.ordered from crim c join appl a on c.apno = a.apno 
--join countydefaultvendor dv on c.county = dv.johndo 
where c.clear is null and (A.ApStatus IN ('P','W')) 
and c.county = @county 
-- and c.ordered is null

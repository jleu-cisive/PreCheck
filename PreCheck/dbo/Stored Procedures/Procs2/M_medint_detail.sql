CREATE PROCEDURE M_medint_detail  @apno int as 
select   m.apno,m.sectstat,a.alias,a.alias2,a.alias3,a.alias4,m.report,
  a.apdate, a.enteredby,a.first, a.middle, a.last, a.dob, a.ssn,
  c.name
from medinteg m
  join appl a on m.apno = a.apno
  join client c on a.clno = c.clno
where  a.apno = @apno and m.apno = @apno
order by a.investigator, a.last

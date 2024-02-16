------------------BEGIN OF ALTERING OF DL STORED PROCEDURES------------------------

CREATE PROCEDURE [dbo].[M_Mvr_detail]  @apno int as 
select   m.apno,m.sectstat,a.alias,a.alias2,a.alias3,a.alias4,m.report,
  a.apdate, a.enteredby,a.first, a.middle, a.last, a.dob, a.ssn,
  c.name,a.DL_Number as dlnumber,a.DL_State as dlstate,d.Last_Updated as lastupdated
from dl m
  join appl a on m.apno = a.apno
  join client c on a.clno = c.clno
  join dl d on a.apno = d.apno and m.apno = d.apno
where  a.apno = @apno and m.apno = @apno


CREATE PROCEDURE [dbo].[M_Crim_Detail] @crimid int AS
select
c.crimid,c.apno,c.county,c.apno,a.first,a.last,a.middle,c.ordered,a.ssn,a.dob,c.clear,a.alias,a.alias2,a.alias3,a.alias4,c.priv_notes,c.pub_notes
,z.name,a.pos_sought,c.caseno,c.date_filed,c.degree,c.offense,c.disposition,c.dob as crimdob,c.ssn as crimssn,c.sentence,c.fine,c.disp_date,c.pub_notes,c.priv_notes,
c.name as nameonrec,a.ssn as assn,a.dob as adob, a.dl_state + '  ' + a.dl_number as adl,a.enteredby,a.userid,a.inuse,

isnull(a.alias1_last,'')+ ', ' + isnull(a.alias1_first,'') + '  ' + isnull(a.alias1_middle,'') as firstalias,
isnull(a.alias2_last,'')+ ', ' + isnull(a.alias2_first,'') + '  ' + isnull(a.alias2_middle,'') as secondalias,
isnull(a.alias3_last,'')+ ', ' + isnull(a.alias3_first,'') + '  ' + isnull(a.alias3_middle,'') as thirdalias,
isnull(a.alias4_last,'')+ ', ' + isnull(a.alias4_first,'') + '  ' + isnull(a.alias4_middle,'') as fourthalias

from crim c
join appl a on c.apno = a.apno
join client z on a.clno = z.clno
where c.crimid = @crimid

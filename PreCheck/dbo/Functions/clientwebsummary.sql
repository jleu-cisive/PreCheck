CREATE function dbo.clientwebsummary(@apno int)
returns @websummary table(apno int,service varchar(40),indstate varchar(60),indstatus varchar(30))
as
Begin
Insert into @websummary 
  select apno,'' as service,'Criminal Search' + ' (' + county + '):' as indstate,
  
      case clear
      when 'T' then  'CLEAR' 
       when 'O' then 'PENDING' 
       when 'F' then  'ALERT/SEE ATTACHED' 
       when 'P' then  'POSSIBLE' 
      else ' '
      end as indstatus 
 from  crim
  join crimsectstat on crim.clear = crimsectstat.crimsect
 where crim.apno = @apno
Insert into @websummary 
  select apno,'' as service ,'Civil'+' (' + county + '):' as indstate,
  indstatus = 
      case clear
      when 'T' then 'CLEAR'
       when 'O' then 'PENDING'
       when 'F' then 'ALERT/SEE ATTACHED'
       when 'P' then 'POSSIBLE'
      else ' '
      end
 from  civil
  join crimsectstat on civil.clear = crimsectstat.crimsect
  where civil.apno = @apno
insert into @websummary
 select apno,'' as service,'Medicare Integrity Check:' as indstate
 ,sectstat.description as indstatus
from medinteg 
 join  sectstat on medinteg.sectstat = sectstat.code
 where medinteg.apno = @apno
insert into @websummary
   select apno,'' as service, 'Prior Employment'  + ' ('  + employer + ') :' as indstate,
 sectstat.description as indstatus from  empl
  join sectstat on empl.sectstat = sectstat.code
   where empl.apno = @apno
insert into @websummary
   select apno, '' as service , 'Education' + ' (' +  school + '):'  as indstate
, sectstat.description as indstatus from educat
  join sectstat on educat.sectstat = sectstat.code
  where educat.apno = @apno
insert into @websummary
  select apno,'' as service, 'Professional License Verification:'  as indstate,
   sectstat.description as indstatus from proflic
   join sectstat on proflic.sectstat = sectstat.code
   where proflic.apno = @apno
insert into @websummary
   select apno,'' as service ,'Personal Reference' + ' (' + name + '):' as indstate,
   sectstat.description as indstatus from persref
   join sectstat on persref.sectstat = sectstat.code
   where persref.apno = @apno
insert into @websummary
   select apno,'' as service ,'National Identification Verfication:'  as indstate,
   sectstat.description as indstatus from credit
   join sectstat on credit.sectstat = sectstat.code
   where credit.apno = @apno
-- select * from dbo.nhdborgsearch(@morgname)
RETURN
END

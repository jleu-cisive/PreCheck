
CREATE PROCEDURE [dbo].[PersrefAutoSchedule] AS





--cchaupin 4-17-09
Update p
Set p.emplid = e.emplid
from persref p
INNER JOIN
appl a on  a.apno = p.apno
inner join
empl e on  e.Supervisor like '%' +  p.Name + '%' AND e.Apno = p.APNO
where a.inuse = 'Pers_S' and p.emplid is null
and a.ApStatus = 'p'

--
--
--Update Persref
--Set emplid = thematch
--from persref
--INNER JOIN
--(SELECT     PersRef.APNO, PersRef.PersRefID, PersRef.Name, Empl.Supervisor, Appl.ApStatus, PersRef.SectStat, 
--                      Empl.EmplID AS thematch
--FROM         Appl INNER JOIN
--                      Empl ON Appl.APNO = Empl.Apno INNER JOIN
--                      PersRef ON Empl.Supervisor like '%' +  PersRef.Name + '%' AND Empl.Apno = PersRef.APNO
--WHERE    (Appl.InUse='Pers_S')  and (Persref.emplid is null)) subquery
---- (Appl.ApStatus = 'p' OR Appl.ApStatus = 'w') AND (Persref.emplid is null)) subquery
--on persref.persrefid = subquery.persrefid




Update Appl
set inuse = 'Pers_E'
where inuse = 'Pers_S'

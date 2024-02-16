CREATE PROCEDURE M_edu_list  @t_sortby varchar(13) as
-- online education module JS
DECLARE @SearchSQL varchar(5000)
If (select @t_sortby) = 'no'
begin
    select
   e.apno, e.EducatID, e.school, e.state, e.phone,e.web_updated, e.time_in,e.createddate,

'SI' = 
      CASE 
         WHEN a.special_instructions IS NULL THEN 'No'
           ELSE 'Yes'
      END,




   a.apstatus,e.web_status,
    a.apdate, a.first, a.middle, a.last
   ,e.sectstat,  c.name
   from educat e
    join appl a on e.apno = a.apno
    join client c on a.clno = c.clno
   where a.apstatus in ('p','w') and (e.sectstat = '9')
 order by  a.apdate asc
  end
If (select @t_sortby) <> 'no'
begin
select @searchsql = 'select e.apno, e.EducatID, e.school, e.state, e.phone,  e.time_in,e.createddate,a.apstatus,e.web_status,  a.apdate, a.first, e.web_updated,
''SI'' = 
      CASE 
         WHEN a.special_instructions IS NULL THEN ''No''
           ELSE ''Yes''
      END,
a.middle, a.last  ,e.sectstat,  c.name  from educat e join appl a on e.apno = a.apno  join client c on a.clno = c.clno  where a.apstatus in (''p'',''w'') and ( e.sectstat = "9")  order by ' + @t_sortby
exec(@SearchSQL)
end
--GO
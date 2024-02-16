CREATE PROCEDURE [M_Proflic_list_JS_10_5]  @t_sortby varchar(12)  AS
DECLARE @SearchSQL varchar(5000)
If (select @t_sortby) = 'no'
begin
   select
   p.apno, p.proflicid, p.lic_type, p.state,  a.apstatus,p.web_status,
'SI' = 
      CASE 
         WHEN a.special_instructions IS NULL THEN 'No'
           ELSE 'Yes'
      END,
    a.apdate, a.first, a.middle, a.last,p.web_updated
   ,p.sectstat,  c.name, p.time_in
   from proflic p
    join appl a on p.apno = a.apno
    join client c on a.clno = c.clno
   where a.apstatus in ('p','w') and (p.sectstat = '9') and (a.inuse is null)
 order by  a.apdate DESC
end
If (select @t_sortby) <> 'no'
begin
select @searchsql = 'select p.apno,p.web_updated,p.time_in, p.proflicID,p.web_status, p.lic_type, p.state,  
''SI'' = 
      CASE 
         WHEN a.special_instructions IS NULL THEN ''No''
           ELSE ''Yes''
      END,
 a.apstatus,p.web_status,  a.apdate, a.first, a.middle, a.last  ,p.sectstat,  c.name  from proflic p join appl a on p.apno = a.apno  join client c on a.clno = c.clno  where a.apstatus in (''p'',''w'') and ( p.sectstat = "9" ) and (a.inuse is null) order by ' + @t_sortby
exec(@SearchSQL)
end
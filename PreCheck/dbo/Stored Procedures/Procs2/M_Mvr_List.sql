CREATE PROCEDURE [dbo].[M_Mvr_List]  @t_sortby varchar(12)  AS
DECLARE @SearchSQL varchar(5000)
If (select @t_sortby) = 'no'
begin
   select
   p.apno, p.web_status,p.time_in, a.apdate,a.dl_number,a.dl_state, a.first, a.middle, a.last
   ,p.sectstat,  c.name   from dl p
    join appl a on p.apno = a.apno
    join client c on a.clno = c.clno
   where a.apstatus in ('p','w') and p.sectstat = '9' and a.clno not in (2135,3468)
 order by  a.apdate DESC
end
If (select @t_sortby) <> 'no'
begin
select @searchsql = 'select p.apno,p.time_in,p.web_status, a.apstatus,  a.dl_number,a.dl_state,a.apdate, a.first, a.middle, a.last  ,p.sectstat,  c.name  from dl p join appl a on p.apno = a.apno  join client c on a.clno = c.clno  where a.apstatus in (''p'',''w'') and p.sectstat = ''9'' and a.clno not in (2135,3468) order by ' + @t_sortby
exec(@SearchSQL)
end
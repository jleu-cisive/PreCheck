CREATE PROCEDURE [dbo].[M_Mvr_List_Review]  @t_sortby varchar(20) = 'no',@WaitingForResults bit = 0  AS
DECLARE @SearchSQL varchar(5000)
If (select @t_sortby) = 'no'
begin
   select
   p.apno, p.web_status,p.time_in, a.apdate,a.dl_number,a.dl_state, a.first, a.middle, a.last
   ,p.sectstat,  c.name,
   (case when s.IsReleaseNeeded = 1 and p.IsReleaseNeeded = 1 then '<font color=red>Release to be Faxed</font>' 
        when s.IsReleaseNeeded = 1 and p.IsReleaseNeeded = 0 then 'Release Sent on ' + cast(changeDate as varchar(12)) 
        else '' end) IsReleaseNeeded,
   datediff(dd,dateordered,current_timestamp) Order_TimeLapse,datediff(dd,p.CreatedDate,current_timestamp) Record_TimeLapse  from dbo.dl p
    inner join dbo.appl a on p.apno = a.apno
    inner join dbo.client c on a.clno = c.clno
    inner join dbo.[state] s on a.dl_state = s.[state]
    left join (Select apno, ChangeDate From dbo.[DLActivityLog] where Releasesent = 1) Activity on p.apno = Activity.apno
   where a.apstatus in ('p','w') and p.sectstat = '9' and a.clno not in (2135,3468) and
   ((isnull(Web_status,0) = 44 and @WaitingForResults = 0) or (@WaitingForResults =1 and DateOrdered is not null and isnull(Web_status,0) <> 44))
 order by  a.apdate DESC
end
If (select @t_sortby) <> 'no'
begin
select @searchsql = 'select p.apno,p.time_in,p.web_status, a.apstatus,  a.dl_number,a.dl_state,a.apdate, a.first, a.middle, a.last  ,p.sectstat, 
					 c.name,
					 (case when s.IsReleaseNeeded = 1 and p.IsReleaseNeeded = 1 then ''<font color=red>Release to be Faxed</font>'' 
					 when s.IsReleaseNeeded = 1 and p.IsReleaseNeeded = 0 then (''Release Sent on '' + cast(changeDate as varchar(12)) )
					 else '''' end) IsReleaseNeeded,
					 datediff(dd,dateordered,current_timestamp) Order_TimeLapse,datediff(dd,p.CreatedDate,current_timestamp) Record_TimeLapse  
					from dbo.dl p 
					inner join dbo.appl a on p.apno = a.apno 
					inner join dbo.client c on a.clno = c.clno 
					inner join dbo.[state] s on a.dl_state = s.[state] 
					left join (Select apno, ChangeDate From dbo.[DLActivityLog] where Releasesent = 1) Activity on p.apno = Activity.apno
					where a.apstatus in (''p'',''w'') and p.sectstat = ''9'' and a.clno not in (2135,3468) and
					((isnull(Web_status,0) = 44 and ' + cast(@WaitingForResults as varchar) + ' = 0) or (' + cast(@WaitingForResults as varchar) + ' =1 and DateOrdered is not null and isnull(Web_status,0) = 44))
					order by ' + @t_sortby
					
exec(@SearchSQL)
end

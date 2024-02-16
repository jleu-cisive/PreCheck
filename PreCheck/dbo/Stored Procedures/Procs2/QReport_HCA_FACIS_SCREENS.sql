/*---------------------------------------------------------------------------------     
This is old single line Query prepared by unknown developer.  
Converted into stored procedure on 03/16/2023 by Shashank Bhoi for #84621 change  
    
ModifiedBy  ModifiedDate TicketNo Description    
Shashank Bhoi 03/16/2023  84621  #84621  include both affiliate 4 (HCA) & 294 (HCA Velocity).     
           EXEC dbo.QReport_HCA_FACIS_SCREENS   
*/---------------------------------------------------------------------------------     
CREATE PROCEDURE dbo.QReport_HCA_FACIS_SCREENS   
AS   
BEGIN
SET NOCOUNT ON;
 select a.apno,a.first,a.middle,a.last,REPLACE(a.ssn,'-','') as ssn,CONVERT(Char, a.dob, 101) as dob,'' AS Alias     
 from (  
   select a.apno,m.report    
   from medinteg m with (nolock) inner join appl a with (nolock)  on m.apno = a.apno     
   where clno in (  
     select clno from clienthierarchybyservice   
     where refhierarchyserviceid = 3 and parentclno in (7122,7123,7124)) and a.apstatus = 'P'     
     and (    
      (select count(*) from proflic where ishidden = 0 and isonreport = 1 and apno = a.apno) > 0    
      OR  (select count(*) from educat where ishidden = 0 and isonreport = 1 and apno = a.apno) > 0    
      OR  (select count(*) from dl where ishidden = 0  and apno = a.apno) > 0    
      OR  (select count(*) from credit where reptype = 'C' and ishidden = 0  and apno = a.apno) > 0    
      OR  (select count(*) from crim where cnty_no in (2738,229) and ishidden = 0 and apno = a.apno) > 0    
      )    
 ) z   
 inner join appl a on z.apno = a.apno    
 INNER JOIN Client AS c with (nolock) ON a.CLNO = c.CLNO   --Code Added by Shashank for ticket id -#84621  
 where isnull(z.report,'') not like '%FACIS%'    
 AND C.AffiliateID IN (4, 294)        --Code Added by Shashank for ticket id -#84621  
  
UNION    
  select a.apno,a.alias1_first,a.alias1_Middle,a.alias1_Last,null,null,'Alias1' AS Alias     
  from (  
    select a.apno,m.report  from medinteg m with (nolock)   
    inner join appl a with (nolock)  on m.apno = a.apno     
    where clno in (  
        select clno from clienthierarchybyservice   
        where refhierarchyserviceid = 3 and parentclno in (7122,7123,7124)) and a.apstatus = 'P'     
        and   (    
          (select count(*) from proflic where ishidden = 0 and isonreport = 1 and apno = a.apno) > 0    
          OR  (select count(*) from educat where ishidden = 0 and isonreport = 1 and apno = a.apno) > 0    
          OR  (select count(*) from dl where ishidden = 0  and apno = a.apno) > 0    
          OR  (select count(*) from credit where reptype = 'C' and ishidden = 0  and apno = a.apno) > 0    
          OR  (select count(*) from crim where cnty_no in (2738,229) and ishidden = 0 and apno = a.apno) > 0  )    
  ) z   
  inner join appl a on z.apno = a.apno  
  INNER JOIN Client AS c with (nolock) ON a.CLNO = c.CLNO   --Code Added by Shashank for ticket id -#84621  
  where isnull(z.report,'') not like '%FACIS%'    
  AND C.AffiliateID IN (4, 294)          --Code Added by Shashank for ticket id -#84621  
  AND (a.alias1_first is not null or a.alias1_Middle is not null or a.alias1_Last is not null)    
  
UNION    
  select a.apno,a.alias2_first,a.alias2_Middle,a.alias2_Last,null,null,'Alias2' AS Alias     
  from (  
    select a.apno,m.report  from medinteg m with (nolock) inner join appl a with (nolock)  on m.apno = a.apno     
    where clno in (  
      select clno   
      from clienthierarchybyservice   
      where refhierarchyserviceid = 3 and parentclno in (7122,7123,7124)) and a.apstatus = 'P'    
      and   (    
        (select count(*) from proflic where ishidden = 0 and isonreport = 1 and apno = a.apno) > 0    
        OR  (select count(*) from educat where ishidden = 0 and isonreport = 1 and apno = a.apno) > 0   
        OR  (select count(*) from dl where ishidden = 0  and apno = a.apno) > 0    
        OR  (select count(*) from credit where reptype = 'C' and ishidden = 0  and apno = a.apno) > 0    
        OR  (select count(*) from crim where cnty_no in (2738,229) and ishidden = 0 and apno = a.apno) > 0  )    
  ) z inner join appl a on z.apno = a.apno    
  INNER JOIN Client AS c with (nolock) ON a.CLNO = c.CLNO   --Code Added by Shashank for ticket id -#84621  
  where isnull(z.report,'') not like '%FACIS%'    
  AND C.AffiliateID IN (4, 294)          --Code Added by Shashank for ticket id -#84621  
  AND (a.alias2_first is not null or a.alias2_Middle is not null or a.alias2_Last is not null)    
  
UNION    
  select a.apno,a.alias3_first,a.alias3_Middle,a.alias3_Last,null,null,'Alias3' AS Alias     
  from (  
   select a.apno,m.report  from medinteg m with (nolock)   
   inner join appl a with (nolock)  on m.apno = a.apno     
   where clno in (  
      select clno from clienthierarchybyservice where refhierarchyserviceid = 3 and parentclno in (7122,7123,7124)) and a.apstatus = 'P'   
      and   (    
        (select count(*) from proflic where ishidden = 0 and isonreport = 1 and apno = a.apno) > 0    
        OR  (select count(*) from educat where ishidden = 0 and isonreport = 1 and apno = a.apno) > 0   
        OR  (select count(*) from dl where ishidden = 0  and apno = a.apno) > 0    
        OR  (select count(*) from credit where reptype = 'C' and ishidden = 0  and apno = a.apno) > 0    
        OR  (select count(*) from crim where cnty_no in (2738,229) and ishidden = 0 and apno = a.apno) > 0  )    
  ) z inner join appl a on z.apno = a.apno    
  INNER JOIN Client AS c with (nolock) ON a.CLNO = c.CLNO   --Code Added by Shashank for ticket id -#84621  
  where isnull(z.report,'') not like '%FACIS%'    
  AND C.AffiliateID IN (4, 294)          --Code Added by Shashank for ticket id -#84621  
  and (a.alias3_first is not null or a.alias3_Middle is not null or a.alias3_Last is not null)    
UNION    
  select a.apno,a.alias4_first,a.alias4_Middle,a.alias4_Last,null,null,'Alias4' AS Alias     
  from (  
   select a.apno,m.report  from medinteg m with (nolock)   
   inner join appl a with (nolock)  on m.apno = a.apno     
   where clno in (  
      select clno from clienthierarchybyservice   
      where refhierarchyserviceid = 3 and parentclno in (7122,7123,7124)) and a.apstatus = 'P'     
      and   (    
        (select count(*) from proflic where ishidden = 0 and isonreport = 1 and apno = a.apno) > 0    
        OR  (select count(*) from educat where ishidden = 0 and isonreport = 1 and apno = a.apno) > 0    
        OR  (select count(*) from dl where ishidden = 0  and apno = a.apno) > 0    
        OR  (select count(*) from credit where reptype = 'C' and ishidden = 0  and apno = a.apno) > 0    
        OR  (select count(*) from crim where cnty_no in (2738,229) and ishidden = 0 and apno = a.apno) > 0  )    
  ) z inner join appl a on z.apno = a.apno    
  INNER JOIN Client AS c with (nolock) ON a.CLNO = c.CLNO   --Code Added by Shashank for ticket id -#84621  
  where isnull(z.report,'') not like '%FACIS%'    
  AND C.AffiliateID IN (4, 294)          --Code Added by Shashank for ticket id -#84621  
  and (a.alias4_first is not null or a.alias4_Middle is not null or a.alias4_Last is not null)    
  --order by a.apno,a.ssn desc,alias         --Code commented by Shashank as order by clause can't be used in UNION   
END

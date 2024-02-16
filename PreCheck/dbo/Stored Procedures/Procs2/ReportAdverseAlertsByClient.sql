





CREATE PROCEDURE [dbo].[ReportAdverseAlertsByClient] @Clno int, @StartDate datetime, @EndDate datetime AS

select distinct a.apno
     , a.apdate
     , c.clno
     , a.last
     , a.first
     , a.middle
     , a.ssn
     , a.dob
     , c.name
     , (case when (select distinct ah.statusid from AdverseActionHistory ah join AdverseAction ad on ah.AdverseActionID = ad.AdverseActionID 
        where ad.apno=a.apno and ah.statusid=1)is null then 0 else 1 end) as preadverse
     , (case when (select distinct ah.statusid from AdverseActionHistory ah join AdverseAction ad on ah.AdverseActionID = ad.AdverseActionID 
        where ad.apno=a.apno and ah.statusid=16)is null then 0 else 1 end) as adverse
     , (case when (select sectstat from medinteg m where m.apno=a.apno and m.sectstat=7) is null then 0 else 1 end) as alerts
from appl a (NOLOCK) 
join client c (NOLOCK) on a.clno=c.clno
where a.apstatus='F' 
  and a.apdate >@StartDate 
  and a.apdate <@EndDate
  and c.clno=@Clno



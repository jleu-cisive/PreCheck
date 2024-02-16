CREATE FUNCTION [dbo].[testInvestigatorAllReport] (@begdate varchar(10),@enddate varchar(10))
RETURNS @Idata TABLE ( apno int,investigator varchar(8),category varchar (20),Daysold int,verified int,unverified_attached int,alert_attached int,see_attached int)
AS
BEGIN
----------------------------------------------------------------------------------------------------------------------
--License
 insert into @Idata
SELECT  distinct a.apno,l.Investigator,'License' as category, 
           (select count(*) from proflic
      where (proflic.apno = a.apno) AND proflic.IsOnReport = 1 and (proflic.investigator = l.investigator)and (CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate, proflic.pendingupdated))  between 1 and 3)) as Daysold,
       (SELECT COUNT(*) FROM proflic
	WHERE (proflic.Apno = A.Apno)  AND proflic.IsOnReport = 1
	  AND (proflic.SectStat = 5))  AS Verified,
       (SELECT COUNT(*) FROM proflic 
	WHERE (proflic.Apno = A.Apno) AND proflic.IsOnReport = 1
	  AND (proflic.SectStat = 6))  AS Unverified_Attached,
        (SELECT COUNT(*) FROM proflic
            WHERE (proflic.Apno = A.Apno) AND proflic.IsOnReport = 1
	  AND (proflic.SectStat = 7))  AS Alert_attached,
   (SELECT COUNT(*) FROM proflic
            WHERE (proflic.Apno = A.Apno) AND proflic.IsOnReport = 1
	  AND (proflic.SectStat = 8))  AS See_attached
FROM Appl A with (nolock)
JOIN proflic l  ON A.apno = l.apno
where (l.pendingupdated  BETWEEN  @begdate AND @enddate) and (l.sectstat <> 9 and l.sectstat <> 0) and l.IsOnReport = 1
and (l.investigator is not null)  order by l.investigator,a.apno,category,daysold,verified,unverified_attached,alert_attached,see_attached


insert into @Idata
SELECT  distinct a.apno,l.Investigator,'Education' as category,
      (select count(*) from Educat
      where (educat.apno = a.apno) and educat.IsOnReport = 1 and (educat.investigator = l.investigator) and (CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate, educat.pendingupdated))between 1 and 3)) as Daysold,
       (SELECT COUNT(*) FROM educat
	WHERE (educat.Apno = A.Apno) and educat.IsOnReport = 1
	  AND (educat.SectStat = 5)) AS Verified,
       (SELECT COUNT(*) FROM educat
	WHERE (educat.Apno = A.Apno) and educat.IsOnReport = 1
	  AND (educat.SectStat = 6))  AS Unverified_Attached,
        (SELECT COUNT(*) FROM educat
            WHERE (educat.Apno = A.Apno) and educat.IsOnReport = 1
	  AND (educat.SectStat = 7))  AS Alert_attached,
   (SELECT COUNT(*) FROM educat
            WHERE (educat.Apno = A.Apno) and educat.IsOnReport = 1
	  AND (educat.SectStat = 8))  AS See_attached
FROM Appl A with (nolock)
JOIN educat l  ON A.apno = l.apno
where (l.pendingupdated  BETWEEN  @begdate AND @enddate) and (l.sectstat <> 9 and l.sectstat <> 0) and l.IsOnReport = 1
and (l.investigator is not null) order by l.investigator,a.apno,category,daysold,verified,unverified_attached,alert_attached,see_attached





--insert into @Idata
--select l.persrefid,a.apdate,l.apno,l.sectstat,a.investigator ,'Reference' as category,
--case sectstat
--   when '5' then '1'
--   else '0'
-- end as verified ,

--case sectstat
--   when '6' then '1'
--   else '0'
-- end as unverified_attached ,

--case sectstat
--   when  '7' then '1'
--   else '0'
-- end as alert_attached ,
--case sectstat
--   when '8' then '1'
--   else '0'
-- end as see_attached 
--from Persref  l with (Nolock)
--join appl a on l.apno = a.apno
--where (a.apdate between @begdate and @enddate) and (a.investigator is not null)


insert into @Idata
SELECT  distinct a.apno,e.Investigator,'Employment' as category,
      (select count(*) from empl
      where (empl.apno = a.apno)  and empl.IsOnReport = 1 and (empl.sectstat <> 9 and empl.sectstat <> 0) and (CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate, empl.pendingupdated)) between 1 and 3)) as Daysold,    
   (SELECT COUNT(*) FROM Empl
	WHERE (Empl.Apno = A.Apno) and empl.IsOnReport = 1
	  AND (Empl.SectStat = 5)) AS Verified,
       (SELECT COUNT(*) FROM Empl
	WHERE (Empl.Apno = A.Apno) and empl.IsOnReport = 1
	  AND (Empl.SectStat = 6))  AS Unverified_Attached,
        (SELECT COUNT(*) FROM Empl
            WHERE (Empl.Apno = A.Apno) and empl.IsOnReport = 1
	  AND (Empl.SectStat = 7))  AS Alert_attached,
   (SELECT COUNT(*) FROM Empl
            WHERE (Empl.Apno = A.Apno) and empl.IsOnReport = 1
	  AND (Empl.SectStat = 8))  AS See_attached
FROM Appl A
JOIN empl e  ON A.apno = e.apno
where (e.pendingupdated  BETWEEN  @begdate AND @enddate) and (e.sectstat <> 9 and e.sectstat <> 0) and e.IsOnReport = 1
order by e.investigator,a.apno,category,daysold,verified,unverified_attached,alert_attached,see_attached

RETURN
END


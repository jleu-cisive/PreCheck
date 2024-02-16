CREATE FUNCTION dbo.CriminalPerformanceReport (@begdate varchar(10), @enddate varchar(10))
returns @cprtable table (category varchar(100),CTvalue varchar(100))
as
begin

-- Count of Applications
Insert into @cprtable
SELECT 'Count of Applications' as category,count(distinct c.apno) as crims
FROM   crim c
WHERE     (c.crimenteredtime between @begdate and @enddate)


/*SELECT 'Count of Applications' as category,count(a.apno) as crims
FROM         dbo.Appl a left outer JOIN
             dbo.Crim c ON A.APNO = c.APNO
WHERE     (c.crimenteredtime between @begdate and @enddate)
group by a.apno*/


Insert into @cprtable
SELECT 'Criminals Ordered' as category, count(crimid) as crims
FROM   Crim
where (ordered is not null) and 
(dbo.Fix_Crim_Ordered_Date(ordered) between @begdate and @enddate)



Insert into @cprtable
SELECT 'Average Turnaround' as category, avg(CONVERT(numeric(7,2), dbo.ElapsedBusinessDays(c.ordered,c.last_updated)))
FROM    Crim c 
where (dbo.Fix_Crim_Ordered_Date(ordered) between @begdate and @enddate)



-- Crim Returned before 3 days
Insert into @cprtable
SELECT 'Criminals returned within 3 days (Ordered Date)' as category,count(c.crimid) as crims
FROM   Crim c 
where (dbo.Fix_Crim_Ordered_Date(ordered) between @begdate and @enddate)
and (CONVERT(numeric(7,2), dbo.ElapsedBusinessDays(c.ordered,c.last_updated) - 1) <= 3)


-- Crim Returned After 3 days
Insert into @cprtable
SELECT 'Criminals returned over 3 days (Ordered Date)' as category,count(c.crimid) as crims
FROM  Crim c 
where (dbo.Fix_Crim_Ordered_Date(ordered) between @begdate and @enddate)
and (CONVERT(numeric(7,2), dbo.ElapsedBusinessDays(c.ordered,c.last_updated) - 1) > 3)


------------------------------------------------- APPLICATION DATE

Insert into @cprtable
SELECT 'Count of Applications(Application Date)' as category,count(a.apno) as crims
FROM         Appl a 
WHERE     (a.apdate between @begdate and @enddate)

Insert into @cprtable
SELECT 'Criminals Ordered(Application Date)' as category, count(crimid) as crims
FROM    dbo.Appl  a INNER JOIN
             dbo.Crim c ON a.APNO = c.APNO
where (a.apdate between @begdate and @enddate)


Insert into @cprtable
SELECT 'Average Turnaround(Application Date)' as category, avg(CONVERT(numeric(7,2), dbo.ElapsedBusinessDays(a.apdate,c.last_updated)))
FROM    dbo.Appl  a INNER JOIN
             dbo.Crim c ON a.APNO = c.APNO
where (a.apdate between @begdate and @enddate)


Insert into @cprtable
SELECT  'Criminals returned within 3 days(Application Date)' as category,count(c.crimid)
FROM         dbo.Appl  INNER JOIN
             dbo.Crim c ON Appl.APNO = c.APNO
where (appl.apdate between @begdate and @enddate)
and (CONVERT(numeric(7,2), dbo.ElapsedBusinessDays(appl.apdate,c.last_updated) - 1) <= 3)

-- Crim Returned After 3 days
Insert into @cprtable
SELECT  'Criminals returned over 3 days(Application Date)' as category,count(c.crimid)
FROM         dbo.Appl INNER JOIN
             dbo.Crim c ON Appl.APNO = c.APNO
where (appl.apdate between @begdate and @enddate)
and (CONVERT(numeric(7,2), dbo.ElapsedBusinessDays(appl.apdate,c.last_updated) - 1)  > 3)

------------------------------End Of Application Date
return
end


























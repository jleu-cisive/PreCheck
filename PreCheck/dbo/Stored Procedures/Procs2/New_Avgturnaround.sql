CREATE PROCEDURE New_Avgturnaround 
	@Clients varchar(5000),
	@strStartDate varchar(10),
	@strEndDate varchar(10)
AS
SET NOCOUNT ON
SELECT c.Clno, C.Name, a.Apno, a.UserID,a.apdate,a.origcompdate,a.reopendate,a.compdate,a.last,a.first,a.middle,dbo.turnarounddate(a.apdate) as fixdate,
-- 1 as ApplCount,dbo.turnarounddate(a.apdate) as fixdate, 

--CONVERT(numeric(7,2), dbo.ElapsedBusinessDays(a.ApDate, a.compdate)) as OrigOpened,
--CONVERT(numeric(7,2), dbo.ElapsedBusinessDays(a.Reopendate, a.CompDate)) as Reopened

CONVERT(numeric(7,2), dbo.ElapsedBusinessDays(a.ApDate, a.Origcompdate)) as OrigOpened,
CONVERT(numeric(7,2), dbo.ElapsedBusinessDays(a.Reopendate, a.CompDate)) as Reopened


FROM Client c
LEFT JOIN Appl a on (c.CLNO = a.CLNO) and (a.ApStatus = 'F')

--where c.clno in ('1934','1938','1939','1972','1937','1935','1932','1957','1940','1938','1936')
WHERE c.clno = @clients 
 and (a.CompDate BETWEEN @strstartdate AND @strenddate) --AND (a.ApDate is not null)
ORDER BY C.Name

--fixdate desc
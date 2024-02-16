
CREATE   PROCEDURE InsertPrecheckCost
@startdate datetime,
@enddate datetime,
@month int,
@year int
as
DECLARE
  @empcost money,
  @refcost money,
  @educost money,
  @liccost money,
  @crimcost money,
  @fixedcost money,
  @ssn money,
  @medicare money,
  @credit money
  set nocount on

--set Medicare, SSN, and Credit costs
SELECT @ssn = ssn, @medicare = medicare, @credit = credit
		FROM precheckcost
		where ((Year + Month) IN (SELECT MAX(year + month)
						FROM precheckCost))

--set Reference cost
SELECT @refcost = (refwages + refclayton)/(SELECT     COUNT(PersRef.Apno) AS Expr1
		FROM         Appl INNER JOIN
                     	persref ON Appl.APNO = persref.Apno
		WHERE     (Appl.ApDate BETWEEN @startdate AND @enddate))
from salesaccounting
where month = @month and year = @year

--set Employment cost
SELECT @empcost = (refwages + refclayton + reffees)/(SELECT     COUNT(Empl.Apno) AS Expr1
		FROM         Appl INNER JOIN
                     	Empl ON Appl.APNO = Empl.Apno
		WHERE     (Appl.ApDate BETWEEN @startdate AND @enddate))
from salesaccounting
where month = @month and year = @year

--set Education cost
SELECT @educost = (credwages*.75 + educatfees*.75)/(SELECT     COUNT(educat.Apno) AS Expr1
		FROM         Appl INNER JOIN
                     	educat ON Appl.APNO = educat.Apno
		WHERE     (Appl.ApDate BETWEEN @startdate AND @enddate))
from salesaccounting
where month = @month and year = @year

--set License cost
SELECT @liccost = (credwages*.25 + credfees*.25)/(SELECT     COUNT(proflic.Apno) AS Expr1
		FROM         Appl INNER JOIN
                     	proflic ON Appl.APNO = proflic.Apno
		WHERE     (Appl.ApDate BETWEEN @startdate AND @enddate))
from salesaccounting
where month = @month and year = @year

--set Criminal cost
SELECT @crimcost = (crimwages + crimsupplies)/(SELECT     COUNT(crim.Apno) AS Expr1
		FROM         Appl INNER JOIN
                     	crim ON Appl.APNO = crim.Apno
		WHERE     (Appl.ApDate BETWEEN @startdate AND @enddate))
from salesaccounting
where month = @month and year = @year

--set FixedCost cost
SELECT @fixedcost = (cswages + prtwages + cssupplies + csclayton)/(SELECT     COUNT(appl.Apno) AS Expr1
		FROM         Appl
		WHERE     (Appl.ApDate BETWEEN @startdate AND @enddate))
from salesaccounting
where month = @month and year = @year

DECLARE @count1 int
select @count1=count(month)
	from precheckcost
	where month=@month and year=@year


if @count1 = 1
update precheckcost
  set employment=@empcost, personal= 0, education=@educost, license=@liccost, criminal=@crimcost, fixedcost=@fixedcost
  where month=@month and year=@year
else
if @month < 10
insert into precheckcost
  (employment, personal, education, license, month, year, criminal, fixedcost, ssn, medicare, credit)
values
  (@empcost,  0, @educost, @liccost, "0" + convert(varchar, @month), @year, @crimcost, @fixedcost, @ssn, @medicare, @credit)
else
insert into precheckcost
  (employment, personal, education, license, month, year, criminal, fixedcost, ssn, medicare, credit)
values
  (@empcost,  0, @educost, @liccost, convert(varchar, @month), @year, @crimcost, @fixedcost, @ssn, @medicare, @credit)
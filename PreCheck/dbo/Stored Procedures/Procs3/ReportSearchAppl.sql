
CREATE PROCEDURE dbo.ReportSearchAppl 
@educat varchar(6),
@empl varchar(4),
@proflic varchar(7),
@persref varchar(7),
@credit varchar(6),
@crim varchar(4),
@medinteg varchar(8),
@StartDate datetime,
@EndDate datetime 

AS

delete from dbo.searchappl

INSERT into dbo.SearchAppl
(APNO, [Last], [First], Middle, SSN, ApDate, ApStatus)

SELECT     APNO, [Last], [First], Middle, SSN, ApDate, ApStatus

FROM         dbo.Appl
WHERE     (ApDate > @StartDate) AND (ApDate < @EndDate)

--=======delete the un wanted rows
if(@educat='true')
begin
DELETE Searchappl 
from Searchappl INNER JOIN educat
ON Searchappl.apno = educat.apno
end

if(@empl ='true')
begin
DELETE Searchappl 
from Searchappl INNER JOIN Empl
ON Searchappl.apno = Empl.apno
end

if(@proflic='true')
begin
DELETE Searchappl 
from Searchappl INNER JOIN ProfLic
ON Searchappl.apno = ProfLic.apno
end

if(@persref ='true')
begin
DELETE Searchappl 
from Searchappl INNER JOIN PersRef
ON Searchappl.apno = PersRef.apno
end

if(@credit ='true')
begin
DELETE Searchappl 
from Searchappl INNER JOIN Credit
ON Searchappl.apno = Credit.apno
end

if(@crim='true')
begin
DELETE Searchappl 
from Searchappl INNER JOIN Crim
ON Searchappl.apno = Crim.apno
end

if(@medinteg ='true')
begin
DELETE Searchappl 
from Searchappl INNER JOIN MedInteg
ON Searchappl.apno = MedInteg.apno
end

select * from Searchappl

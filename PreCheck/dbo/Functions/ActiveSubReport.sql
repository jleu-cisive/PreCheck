CREATE FUNCTION [dbo].[ActiveSubReport] (@begdate varchar(10),@enddate varchar(10),@clno int)
RETURNS @activesub TABLE ( ssn varchar(60), appno varchar(50),Display varchar(50))
AS
BEGIN

----------------------------------------------------------------------------------------------------------------------
--Criminal

insert into @activesub
SELECT    
Case 
 when a.ssn is null then 'N/A'
else
a.ssn
end
as tssn,a.apno,'A-Criminal' as display
FROM         Appl A INNER JOIN
                      Client C ON A.CLNO = C.CLNO INNER JOIN
                      Crim ON A.APNO = dbo.Crim.APNO
WHERE     (A.ApStatus = 'F') AND (A.ApDate BETWEEN @begdate AND @enddate)  AND (C.CLNO = @clno) and
(Crim.Clear = 'p' or crim.clear = 'f')
-----------------------------------------------------------------------------------------------------------------------
--Employment

insert into @activesub
SELECT
Case
 when   a.ssn is null then 'N/A'
else
a.ssn
end
as tssn,a.apno,'B-Employment' as display
FROM         Appl A INNER JOIN
                      Client C ON A.CLNO = C.CLNO INNER JOIN
                      empl ON A.APNO = dbo.empl.APNO
WHERE     (A.ApStatus = 'F') AND (A.ApDate BETWEEN @begdate AND @enddate)  AND (C.CLNO = @clno) and
(Empl.SectStat = '6' or empl.sectstat = '7')AND empl.IsOnReport = 1
 


-----------------------------------------------------------------------------------------------------------------------
-- Education

insert into @activesub
SELECT  

Case 
 when a.ssn is null then 'N/A'
else
a.ssn
end
as tssn,a.apno,'C-Education' as display
FROM         Appl A INNER JOIN
                      Client C ON A.CLNO = C.CLNO INNER JOIN
                      educat ON A.APNO = dbo.educat.APNO
WHERE     (A.ApStatus = 'F') AND (A.ApDate BETWEEN @begdate AND @enddate)  AND (C.CLNO = @clno) and
(educat.SectStat = '6' or educat.sectstat = '7') AND educat.IsOnReport = 1



-------------------------------------------------------------------------------------------------------------------------
-- MVR
insert into @activesub
SELECT
Case 
 when a.ssn is null then 'N/A'
else
a.ssn
end
as tssn,a.apno,'D-Motor Vehicle Records' as display
FROM         Appl A INNER JOIN
                      Client C ON A.CLNO = C.CLNO INNER JOIN
                      dl ON A.APNO = dbo.dl.APNO
WHERE     (A.ApStatus = 'F') AND (A.ApDate BETWEEN @begdate AND @enddate)  AND (C.CLNO = @clno) and
(dl.SectStat = '6' or dl.sectstat = '7')


--------------------------------------------------------------------------------------------------------------------------
-- Prof license

insert into @activesub
SELECT 
Case 
 when a.ssn is null then 'N/A'
else
a.ssn
end
as tssn,a.apno,'E-Licensure' as display
FROM         Appl A INNER JOIN
                      Client C ON A.CLNO = C.CLNO INNER JOIN
                      proflic ON A.APNO = dbo.proflic.APNO
WHERE     (A.ApStatus = 'F') AND (A.ApDate BETWEEN @begdate AND @enddate)  AND (C.CLNO = @clno) and
(proflic.SectStat = '6' or proflic.sectstat = '7') and proflic.IsOnReport = 1



------------------------------------------------------------------------------------------------------------------------------- Medicare

insert into @activesub
SELECT
Case 
 when a.ssn is null then 'N/A'
else
a.ssn
end
as tssn,a.apno,'F-Medicaid/Medicare Integrity Check' as display
FROM         Appl A INNER JOIN
                      Client C ON A.CLNO = C.CLNO INNER JOIN
                      medinteg ON A.APNO = dbo.medinteg.APNO
WHERE     (A.ApStatus = 'F') AND (A.ApDate BETWEEN @begdate AND @enddate)  AND (C.CLNO = @clno) and
(medinteg.SectStat = '6' or medinteg.sectstat = '7')



-------------------------------------------------------------------------------------------------------------------------------
--Social

insert into @activesub
SELECT    
Case 
 when a.ssn is null then 'N/A'
else
a.ssn
end
as tssn,
a.apno,'F-SSN Verification' as display
FROM         Appl A INNER JOIN
                      Client C ON A.CLNO = C.CLNO INNER JOIN
                      credit ON A.APNO = dbo.credit.APNO
WHERE     (A.ApStatus = 'F') AND (A.ApDate BETWEEN @begdate AND @enddate)  AND (C.CLNO = @clno) and
(credit.SectStat = '6' or credit.sectstat = '7') and (credit.reptype = 'S')


RETURN
END

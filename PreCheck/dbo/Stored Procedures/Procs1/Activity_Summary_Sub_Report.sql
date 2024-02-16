CREATE PROCEDURE Activity_Summary_Sub_Report @tbegdate varchar(10), @tenddate varchar(10),@tclno int AS
SET NOCOUNT ON
--SELECT    a.ssn,c.clno,a.apno
--FROM         Appl A INNER JOIN
--                      Client C ON A.CLNO = C.CLNO INNER JOIN
--                      Crim ON A.APNO = dbo.Crim.APNO
--WHERE     (A.ApStatus = 'F') AND (A.ApDate BETWEEN @begdate AND @enddate)  AND (C.CLNO = @clno) and
--(Crim.Clear = 'p' or crim.clear = 'f')

select   * from dbo.activesubreport(@tbegdate,@tenddate,@tclno)
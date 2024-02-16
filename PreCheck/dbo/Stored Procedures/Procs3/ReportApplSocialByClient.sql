

CREATE PROCEDURE dbo.ReportApplSocialByClient 
@Clno int,
@StartDate datetime,
@EndDate datetime 

AS

SELECT     COUNT(*) AS MySocialCount
FROM         Appl INNER JOIN
                   Client ON .Appl.CLNO = .Client.CLNO INNER JOIN
                   Credit ON Appl.APNO = Credit.APNO
WHERE     (Client.CLNO = @Clno) AND (Credit.RepType = 's') AND (Credit.SectStat = '6') AND (dbo.Appl.ApDate BETWEEN @Startdate and @EndDate) 

--SectStat= 6 == unverified


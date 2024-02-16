
CREATE PROCEDURE [dbo].[ReportEductionInstitutionClosed] (@Clno int, @bDate datetime, @eDate 
datetime)

AS

 

 if @Clno=0

--Report on schools that may not be completed, because of holiday closures

SELECT a.APNO, CONVERT(varchar(10),ApDate,101) as ApDate, c.CLNO, c.Name, a.UserID, School, 
SectStat, Description, e.Pub_Notes FROM Appl a (NOLOCK) 

JOIN Educat e (NOLOCK) ON e.APNO=a.APNO

JOIN SectStat s (NOLOCK) ON s.Code=e.SectStat

JOIN Client c (NOLOCK) ON c.CLNO = a.CLNO

WHERE ApDate >= @bDate AND ApDate < @eDate AND e.IsonReport = 1 AND sectstat in ('8', 'A') 
--Description in ('EDUC INSTITUTION CLOSED','SEE ATTACHED')

ORDER BY ApDate

else if @Clno>0

--Report on schools that may not be completed, because of holiday closures

SELECT a.APNO, CONVERT(varchar(10),ApDate,101) as ApDate, c.CLNO, c.Name, a.UserID, School, 
SectStat, Description, e.Pub_Notes FROM Appl a (NOLOCK) 

JOIN Educat e (NOLOCK) ON e.APNO=a.APNO

JOIN SectStat s (NOLOCK) ON s.Code=e.SectStat

JOIN Client c (NOLOCK) ON c.CLNO = a.CLNO

WHERE ApDate >= @bDate AND ApDate < @eDate AND e.IsonReport = 1 AND sectstat in ('8', 'A') and 
c.CLNO=@Clno--Description in ('EDUC INSTITUTION CLOSED','SEE ATTACHED')

ORDER BY ApDate



set ANSI_NULLS ON
set QUOTED_IDENTIFIER OFF


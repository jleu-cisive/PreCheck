






CREATE PROCEDURE [dbo].[ReportEmplUnVerified] (@Clno int, @bDate datetime, @eDate datetime)
AS


if @Clno=0 
   SELECT a.APNO
     , CONVERT(varchar(10),ApDate,101) as ApDate
     , c.CLNO
     , c.Name
     , Employer
	 , a.UserID
     , e.Investigator
     , SectStat
     , Description
     , e.Pub_Notes 
FROM Appl a (NOLOCK) 
     JOIN Empl e (NOLOCK) ON e.APNO=a.APNO
     JOIN SectStat s (NOLOCK) ON s.Code=e.SectStat
     JOIN Client c (NOLOCK) ON c.CLNO = a.CLNO
WHERE ApDate >= @bDate AND ApDate < @eDate AND Description in ('UNVERIFIED/SEE ATTACHED') and e.IsOnReport = 1
ORDER BY ApDate





--Report on schools that may not be completed, because of holiday closures
else if @Clno >0 
SELECT a.APNO
     , CONVERT(varchar(10),ApDate,101) as ApDate
     , c.CLNO
     , c.Name
     , Employer
	 , a.UserID
     , e.Investigator
     , SectStat
     , Description
     , e.Pub_Notes 
FROM Appl a (NOLOCK) 
     JOIN Empl e (NOLOCK) ON e.APNO=a.APNO
     JOIN SectStat s (NOLOCK) ON s.Code=e.SectStat
     JOIN Client c (NOLOCK) ON c.CLNO = a.CLNO
WHERE ApDate >= @bDate AND ApDate < @eDate and c.CLNO=@Clno AND Description in ('UNVERIFIED/SEE ATTACHED') and e.IsOnReport = 1
ORDER BY ApDate



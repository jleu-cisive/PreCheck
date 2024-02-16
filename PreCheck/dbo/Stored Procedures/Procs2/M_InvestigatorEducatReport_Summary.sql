









CREATE PROCEDURE [dbo].[M_InvestigatorEducatReport_Summary]   @startdate datetime, @enddate datetime  as 

---------- PERSONAL REFERENCE REPORT
if( DateDiff(m,@startDate,@enddate) <= 4)
BEGIN
SELECT e.Investigator as investigator , 'Education' as tablename,
                          (SELECT     COUNT(*)
                            FROM          educat  with (nolock) 
                            WHERE    (educat.SectStat = '5') AND (educat.investigator = e.Investigator) and (educat.Last_Worked BETWEEN @startdate  AND @enddate +1)) AS Verified,
                          (SELECT     COUNT(*)
                            FROM         educat  with (nolock) 
                            WHERE     (educat.SectStat = '6') AND (educat.investigator = e.Investigator) and (educat.Last_Worked BETWEEN @startdate  AND @enddate + 1)) AS Unverified_Attached,
                          (SELECT     COUNT(*)
                            FROM          educat  with (nolock) 
                            WHERE    (educat.SectStat = '7') AND (educat.investigator = e.Investigator) and (educat.Last_Worked BETWEEN @startdate  AND @enddate +1)) AS Alert_attached,
                          (SELECT     COUNT(*)
                            FROM          educat  with (nolock) 
                            WHERE     (educat.SectStat ='8') AND (educat.investigator = e.Investigator) and (educat.Last_Worked BETWEEN @startdate  AND @enddate + 1)) AS See_attached,
                            (SELECT     COUNT(*)
                            FROM          educat  with (nolock) 
                            WHERE     (educat.SectStat ='9') AND (educat.investigator = e.Investigator) and (educat.Last_Worked BETWEEN @startdate  AND @enddate + 1)) AS Pending
                         
FROM         dbo.educat e   with (nolock) JOIN dbo.Appl A  with (nolock) 
                      ON A.APNO = e.Apno join users u on u.userid = e.investigator
where  (A.ApStatus <>'M') and (e.investigator is not null) and --(e.sectstat <> '9')and 
(e.Last_Worked BETWEEN @startdate  AND @enddate + 1) and u.educat = 1 
group by e.investigator 

END
ELSE
raiserror('Error, the date range provided is too large. Please limit date range to 4 months.',16,1)





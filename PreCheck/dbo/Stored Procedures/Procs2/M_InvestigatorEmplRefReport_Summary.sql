








CREATE PROCEDURE [dbo].[M_InvestigatorEmplRefReport_Summary]   @startdate datetime, @enddate datetime  as 

---------- PERSONAL REFERENCE REPORT
if( DateDiff(m,@startDate,@enddate) <= 4)
BEGIN
(SELECT p.Investigator as investigator , 'Reference' as tablename,
                          (SELECT     COUNT(*)
                            FROM          persref with (nolock)
                            WHERE    (persref.SectStat = '5') AND (persref.investigator = p.Investigator) and (persref.Last_Worked >= @startdate  AND persref.Last_Worked <= @enddate + 1) AND PersRef.IsOnReport = 1) AS Verified,
                          (SELECT     COUNT(*)
                            FROM          persref  with (nolock)
                            WHERE     (persref.SectStat = '6') AND (persref.investigator = p.Investigator) and (persref.Last_Worked >= @startdate  AND persref.Last_Worked <= @enddate + 1) AND PersRef.IsOnReport = 1 ) AS Unverified_Attached,
                          (SELECT     COUNT(*)
                            FROM          persref  with (nolock)
                            WHERE    (persref.SectStat = '7') AND (persref.investigator = p.Investigator) and (persref.Last_Worked >= @startdate  AND persref.Last_Worked <= @enddate + 1) AND PersRef.IsOnReport = 1) AS Alert_attached,
                          (SELECT     COUNT(*)
                            FROM          persref  with (nolock)
                            WHERE     (persref.SectStat ='8') AND (persref.investigator = p.Investigator) and (persref.Last_Worked >= @startdate  AND persref.Last_Worked <= @enddate + 1) AND PersRef.IsOnReport = 1) AS See_attached,
                            (SELECT     COUNT(*)
                            FROM          persref  with (nolock)
                            WHERE     (persref.SectStat ='9') AND (persref.investigator = p.Investigator) and (persref.Last_Worked >= @startdate  AND persref.Last_Worked <= @enddate + 1 ) AND PersRef.IsOnReport = 1) AS Pending
                         
FROM         dbo.persref p   with (nolock) JOIN dbo.Appl A  with (nolock) 
                      ON A.APNO = p.Apno join users u  with (nolock) on u.userid = p.investigator
where  (A.ApStatus IN ('P','W')) and (p.investigator is not null) AND p.IsOnReport = 1
--(p.sectstat <> '9')and 
--(p.PendingUpdated >= @startdate  AND p.PendingUpdated <= @enddate+1 )
 and 
u.persref = 1 
group by p.investigator
)
union
(SELECT e.Investigator as investigator, 'Employment' as tablename,
                          (SELECT     COUNT(*)
                            FROM          empl  with (nolock)
                            WHERE    (empl.SectStat = '5') AND (empl.investigator = e.Investigator) and (empl.Last_Worked >= @startdate AND empl.Last_Worked <= @enddate +1) AND empl.IsOnReport = 1) AS Verified,
                          (SELECT     COUNT(*)
                            FROM          empl  with (nolock)
                            WHERE     (empl.SectStat = '6') AND (empl.investigator = e.Investigator) and (empl.Last_Worked >= @startdate AND empl.Last_Worked <= @enddate+1 ) AND empl.IsOnReport = 1) AS Unverified_Attached,
                          (SELECT     COUNT(*)
                            FROM          empl  with (nolock)
                            WHERE    (empl.SectStat = '7') AND (empl.investigator = e.Investigator) and (empl.Last_Worked >= @startdate AND empl.Last_Worked <= @enddate+1 ) AND empl.IsOnReport = 1) AS Alert_attached,
                          (SELECT     COUNT(*)
                            FROM          empl  with (nolock)
                            WHERE     (empl.SectStat ='8') AND (empl.investigator = e.Investigator) and (empl.Last_Worked >= @startdate AND empl.Last_Worked <= @enddate+1 ) AND empl.IsOnReport = 1) AS See_attached,
                          (SELECT     COUNT(*)
                            FROM          empl  with (nolock)
                            WHERE     (empl.SectStat ='9') AND (empl.investigator = e.Investigator) and (empl.Last_Worked >= @startdate AND empl.Last_Worked <= @enddate+1 ) AND empl.IsOnReport = 1) AS Pending
                         
FROM         dbo.empl e   with (nolock) JOIN dbo.Appl A   with (nolock)
                      ON A.APNO = e.Apno join users u  with (nolock) on u.userid = e.investigator
where  (A.ApStatus IN ('P','W')) and (e.investigator is not null) AND e.IsOnReport = 1
--(e.sectstat <> '9')and 
--(e.PendingUpdated >= @startdate AND e.PendingUpdated <= @enddate+1 )
 and 
u.empl = 1 --(p.PendingUpdated BETWEEN @startdate AND @enddate)
group by e.investigator
)order by investigator, tablename
END
ELSE
raiserror('Error, the date range provided is too large. Please limit date range to 4 months.',16,1)



set ANSI_NULLS OFF
set QUOTED_IDENTIFIER OFF



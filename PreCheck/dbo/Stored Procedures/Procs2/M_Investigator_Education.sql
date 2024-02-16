







CREATE PROCEDURE [dbo].[M_Investigator_Education]  @startdate datetime, @enddate datetime AS

-- Report for Education within Precheck
if( DateDiff(m,@startDate,@enddate) <= 4)
BEGIN
SELECT  distinct e.Investigator,a.apno,
      
       (SELECT COUNT(*) FROM educat with (nolock) 
	WHERE (Educat.Apno = A.Apno)
	  AND (educat.SectStat = '5') and (educat.Last_Worked  BETWEEN  @startdate  AND  @enddate + 1) AND Educat.IsOnReport = 1) AS Verified,
       (SELECT COUNT(*) FROM educat with (nolock) 
	WHERE (educat.Apno = A.Apno)
	  AND (educat.SectStat = '6')and (educat.Last_Worked  BETWEEN  @startdate  AND  @enddate + 1) AND Educat.IsOnReport = 1)  AS Unverified_Attached,
        (SELECT COUNT(*) FROM educat with (nolock) 
            WHERE (educat.Apno = A.Apno)
	  AND (educat.SectStat = '7')and (educat.Last_Worked  BETWEEN  @startdate  AND  @enddate + 1) AND Educat.IsOnReport = 1)  AS Alert_attached,
   (SELECT COUNT(*) FROM educat with (nolock) 
            WHERE (educat.Apno = A.Apno)
	  AND (educat.SectStat = '8')and (educat.Last_Worked  BETWEEN  @startdate  AND  @enddate + 1) AND Educat.IsOnReport = 1)  AS See_attached,
 (SELECT COUNT(*) FROM educat with (nolock) 
	WHERE (educat.Apno = A.Apno)
	  AND (educat.SectStat = '9')and (educat.Last_Worked  BETWEEN  @startdate  AND  @enddate + 1) AND Educat.IsOnReport = 1) AS educat_Count,
        (SELECT COUNT(*) FROM PersRef with (nolock) 
	WHERE (PersRef.Apno = A.Apno)
	  AND (PersRef.SectStat = '9') AND PersRef.IsOnReport = 1) AS PersRef_Count
FROM Appl A with (nolock) 
JOIN educat e  with (nolock) ON A.apno = e.apno
-- WHERE (A.ApStatus IN ('P','W')) 
--  AND (A.Investigator = @name)  and   A.apdate BETWEEN CONVERT(DATETIME, @startdate, 102) AND CONVERT(DATETIME, 
--                      @enddate, 102)
where --e.Investigator in ('apickens','cbunn','cjessup','bcain','tford','NThanars','lwalker') and  ==> removed by RSK 6/24/2004
e.Last_Worked  BETWEEN  @startdate  AND  @enddate + 1  AND (A.APStatus <> 'M') AND e.IsOnReport = 1
END
ELSE
raiserror('Error, the date range provided is too large. Please limit date range to 4 months.',16,1)




set ANSI_NULLS OFF
set QUOTED_IDENTIFIER OFF


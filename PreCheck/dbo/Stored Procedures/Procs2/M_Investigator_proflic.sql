


CREATE PROCEDURE [dbo].[M_Investigator_proflic]  @startdate varchar(10), @enddate varchar(10) AS

-- Report for proflicion within Precheck
if( DateDiff(m,@startDate,@enddate) <= 4)
BEGIN
SELECT  distinct e.Investigator,a.apno,
      
       (SELECT COUNT(*) FROM proflic  with (nolock) 
	WHERE (proflic.Apno = A.Apno)
	  AND (proflic.SectStat = '5') AND proflic.IsOnReport = 1) AS Verified,
       (SELECT COUNT(*) FROM proflic  with (nolock) 
	WHERE (proflic.Apno = A.Apno)
	  AND (proflic.SectStat = '6') AND proflic.IsOnReport = 1)  AS Unverified_Attached,
        (SELECT COUNT(*) FROM proflic with (nolock) 
            WHERE (proflic.Apno = A.Apno)
	  AND (proflic.SectStat = '7') AND proflic.IsOnReport = 1)  AS Alert_attached,
   (SELECT COUNT(*) FROM proflic with (nolock) 
            WHERE (proflic.Apno = A.Apno)
	  AND (proflic.SectStat = '8') AND proflic.IsOnReport = 1)  AS See_attached,
 (SELECT COUNT(*) FROM proflic with (nolock) 
	WHERE (proflic.Apno = A.Apno)
	  AND (proflic.SectStat = '9') AND proflic.IsOnReport = 1) AS proflic_Count,
        (SELECT COUNT(*) FROM PersRef with (nolock) 
	WHERE (PersRef.Apno = A.Apno)
	  AND (PersRef.SectStat = '9') AND PersRef.IsOnReport = 1) AS PersRef_Count
FROM Appl A with (nolock) 
JOIN proflic e   with (nolock) ON A.apno = e.apno
-- WHERE (A.ApStatus IN ('P','W')) 
--  AND (A.Investigator = @name)  and   A.apdate BETWEEN CONVERT(DATETIME, @startdate, 102) AND CONVERT(DATETIME, 
--                      @enddate, 102)
--where --e.Investigator in ('apickens','cbunn','cjessup','bcain','tford','NThanars','lwalker') and  ==> removed by RSK 6/24/2004
--dbo.datepart(e.PendingUpdated)  BETWEEN  dbo.datepart(@startdate)  AND  dbo.datepart(@enddate) and (e.sectstat <> 9 and e.sectstat <> 0 ) AND (A.APStatus <> 'M')
where (e.PendingUpdated >= CAST(LEFT(@startdate, 11) AS DATETIME)  and e.PendingUpdated <= CAST(LEFT(@enddate, 11) AS DATETIME))
and (e.sectstat <> '9' and e.sectstat <> '0' ) AND (A.APStatus <> 'M') AND e.IsOnReport = 1
END
ELSE
raiserror('Error, the date range provided is too large. Please limit date range to 4 months.',16,1)








set ANSI_NULLS OFF
set QUOTED_IDENTIFIER OFF



CREATE PROCEDURE [dbo].[Test_Investigator_proflic]  @startdate varchar(10), @enddate varchar(10) AS

-- Report for proflicion within Precheck
SELECT  distinct e.Investigator,a.apno,e.Last_Worked,
      
       (SELECT COUNT(*) FROM proflic
	WHERE (proflic.Apno = A.Apno)
	  AND (proflic.SectStat = 5)) AS Verified,
       (SELECT COUNT(*) FROM proflic
	WHERE (proflic.Apno = A.Apno)
	  AND (proflic.SectStat = 6))  AS Unverified_Attached,
        (SELECT COUNT(*) FROM proflic
            WHERE (proflic.Apno = A.Apno)
	  AND (proflic.SectStat = 7))  AS Alert_attached,
   (SELECT COUNT(*) FROM proflic
            WHERE (proflic.Apno = A.Apno)
	  AND (proflic.SectStat = 8))  AS See_attached,
 (SELECT COUNT(*) FROM proflic
	WHERE (proflic.Apno = A.Apno)
	  AND (proflic.SectStat = 9)) AS proflic_Count,
        (SELECT COUNT(*) FROM PersRef
	WHERE (PersRef.Apno = A.Apno)
	  AND (PersRef.SectStat = 9)) AS PersRef_Count
FROM Appl A
JOIN proflic e  ON A.apno = e.apno
-- WHERE (A.ApStatus IN ('P','W')) 
--  AND (A.Investigator = @name)  and   A.apdate BETWEEN CONVERT(DATETIME, @startdate, 102) AND CONVERT(DATETIME, 
--                      @enddate, 102)

where (e.Last_Worked >= CAST(LEFT(@startdate, 11) AS DATETIME)  and e.Last_Worked <= CAST(LEFT(@enddate, 11) AS DATETIME))
--where --e.Investigator in ('apickens','cbunn','cjessup','bcain','tford','NThanars','lwalker') and  ==> removed by RSK 6/24/2004

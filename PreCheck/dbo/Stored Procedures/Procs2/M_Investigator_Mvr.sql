CREATE PROCEDURE M_Investigator_Mvr @startdate datetime, @enddate datetime AS


SELECT  distinct a.apno,
       (SELECT COUNT(*) FROM dl
	WHERE (dl.Apno = A.Apno)
	  AND (dl.SectStat = '9')) AS pending,
       (SELECT COUNT(*) FROM dl
	WHERE (dl.Apno = A.Apno)
	  AND (dl.SectStat = '8'))  AS See_attached,
        (SELECT COUNT(*) FROM dl
            WHERE (dl.Apno = A.Apno)
	  AND (dl.SectStat = '3'))  AS complete_seeattached,
   (SELECT COUNT(*) FROM dl
            WHERE (dl.Apno = A.Apno)
	  AND (dl.SectStat = '6'))  AS UnverifiedSee_attached
        
FROM Appl A
JOIN dl e  ON A.apno = e.apno

where dbo.datepart(e.ordered)  BETWEEN  dbo.datepart(@startdate)  AND  dbo.datepart(@enddate) 
--and e.sectstat <> 0
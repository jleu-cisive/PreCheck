









CREATE PROCEDURE [dbo].[AssignEmplInvestigatorByClient] AS

Update Empl

Set Empl.Investigator =

(CASE WHEN (c1.EmplInvestigatorByClient4 is not null and c1.EmplInvestigatorByClient4 <> '') then
          CASE WHEN (Appl.apno % 4) = 0
               THEN  c1.EmplInvestigatorByClient1 
               WHEN (Appl.apno % 4) = 1
               THEN  c1.EmplInvestigatorByClient2
               WHEN (Appl.apno % 4) = 2
               THEN  c1.EmplInvestigatorByClient3
               WHEN (Appl.apno % 4) = 3
               THEN  c1.EmplInvestigatorByClient4
          END
     
    WHEN (c1.EmplInvestigatorByClient3 is not null and c1.EmplInvestigatorByClient3 <> '') then
         CASE WHEN (Appl.apno % 3) = 0
              THEN  c1.EmplInvestigatorByClient1 
              WHEN (Appl.apno % 3) = 1
              THEN  c1.EmplInvestigatorByClient2
              WHEN (Appl.apno % 3) = 2
              THEN  c1.EmplInvestigatorByClient3
         END
    WHEN (c1.EmplInvestigatorByClient2 is not null and c1.EmplInvestigatorByClient2 <> '') then
         CASE WHEN (Appl.apno % 2) = 0
              THEN  c1.EmplInvestigatorByClient1 
              WHEN (Appl.apno % 2) = 1
              THEN  c1.EmplInvestigatorByClient2
         END
    WHEN (c1.EmplInvestigatorByClient1 is not null and c1.EmplInvestigatorByClient1 <> '') then
         c1.EmplInvestigatorByClient1 
END),
InvestigatorAssigned = GETDATE()

from Empl INNER JOIN Appl (NOLOCK) ON Appl.apno = Empl.Apno
	   INNER JOIN Client c1 (NOLOCK) ON c1.clno = Appl.clno 
left join Client c2 (NOLOCK) on c2.clno = empl.employerid
WHERE  (Empl.SectStat = '9') --and Client.clno=1023)
 and (Empl.Investigator is null or empl.investigator = '') and Appl.InUse is null and appl.apstatus = 'P'
and ((c2.EmplInvestigatorByEmployer1 is null or c2.EmplInvestigatorByEmployer1 = '') and (c2.EmplInvestigatorByEmployer2 is null or c2.EmplInvestigatorByEmployer2 = '' ))
--and Appl.CLNO NOT IN (11404, 1932, 1937, 9044, 8317, 10107, 2167,3062, 1023, 2821, 1934, 2331)










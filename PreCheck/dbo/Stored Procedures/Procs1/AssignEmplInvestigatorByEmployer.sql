








CREATE PROCEDURE [dbo].[AssignEmplInvestigatorByEmployer] AS

Update Empl

Set Empl.Investigator =

(CASE WHEN ((Client.EmplInvestigatorByEmployer1 is not null and Client.EmplInvestigatorByEmployer1 <> '') and  (Client.EmplInvestigatorByEmployer2 is not null and Client.EmplInvestigatorByEmployer2 <> '')) and (Appl.apno & 1) = 1  --odd
          THEN  Client.EmplInvestigatorByEmployer1 
          WHEN  ((Client.EmplInvestigatorByEmployer1 is not null and Client.EmplInvestigatorByEmployer1 <> '')  and  (Client.EmplInvestigatorByEmployer2 is null or Client.EmplInvestigatorByEmployer2 = '')) 
          THEN    Client.EmplInvestigatorByEmployer1 
          WHEN ((Client.EmplInvestigatorByEmployer1 is not null and Client.EmplInvestigatorByEmployer1 <> '')  and  (Client.EmplInvestigatorByEmployer2 is not null and Client.EmplInvestigatorByEmployer2 <> '')) and (Appl.apno & 1) = 0  --even
          THEN Client.EmplInvestigatorByEmployer2
          WHEN ((Client.EmplInvestigatorByEmployer1 is  null or Client.EmplInvestigatorByEmployer1 = '')  and  (Client.EmplInvestigatorByEmployer2 is not null and Client.EmplInvestigatorByEmployer2 <> '')) 
          THEN Client.EmplInvestigatorByEmployer2
          END ),
InvestigatorAssigned = GETDATE()
from Empl INNER JOIN Appl (NOLOCK) ON Appl.apno = Empl.Apno
	   INNER JOIN Client (NOLOCK) ON Client.clno = Empl.EmployerID
WHERE  (Empl.SectStat = '9') and 
(Empl.EmployerID = Client.clno) and (Empl.Investigator is null or Empl.Investigator = '' )
and Appl.InUse is null and appl.apstatus = 'P'
--AND Client.CLNO IN (11404, 1932, 1937, 9044, 8317, 10107, 2167)






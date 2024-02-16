




CREATE PROCEDURE [dbo].[AssignPersRefInvestigator] AS
Update PersRef                
Set Investigator =

CASE WHEN (Client.PersRefInvestigator1 is not null and (Appl.apno & 1) = 1)
          THEN  Client.PersRefInvestigator1 
          WHEN  (Client.PersRefInvestigator2 is not null and (Appl.apno & 1) = 0) 
          THEN    Client.PersRefInvestigator2
		  ELSE Client.PersRefInvestigator1
          END 
from PersRef with (nolock) INNER JOIN Appl with (NOLOCK) ON Appl.apno = PersRef.Apno
	   INNER JOIN Client with (NOLOCK) ON Client.clno = Appl.clno
WHERE  (PersRef.SectStat = '9' or   PersRef.SectStat = '0') and ISNULL(PersRef.Investigator,'') = '' and Appl.InUse is null
and appl.apstatus = 'P' and appl.apdate > DATEADD(hh,-4,getdate())





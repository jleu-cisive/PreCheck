






CREATE  PROCEDURE [dbo].[AssignEduInvestigator] AS

Update Educat

Set Educat.Investigator =

(CASE WHEN (Client.EduInvestigator1 is not null and (Appl.apno & 1) = 1)
          THEN  Client.EduInvestigator1 
          WHEN  (Client.EduInvestigator2 is not null and (Appl.apno & 1) = 0) 
          THEN    Client.EduInvestigator2
		  ELSE Client.EduInvestigator1
          END )
from Educat with (nolock) INNER JOIN Appl with (nolock) ON Appl.apno = Educat.Apno
	   INNER JOIN Client with (nolock) ON Client.clno = Appl.clno
WHERE  (Educat.SectStat = '9' or   Educat.SectStat = '0') and ISNULL(Educat.Investigator,'') = ''  
		and Appl.InUse is null and appl.apstatus = 'P'  and appl.apdate > DATEADD(hh,-4,getdate())







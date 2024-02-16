CREATE PROCEDURE [dbo].[AssignEmplInvestigator] AS

Update Empl

Set Empl.Investigator =

--CASE WHEN (Client.EmplInvestigator1 is not null  and  Client.EmplInvestigator2 is not null) and (Appl.apno & 1) = 1  --odd
--          THEN  Client.EmplInvestigator1 
--          WHEN  (Client.EmplInvestigator1 is not null  and  Client.EmplInvestigator2 is null) 
--          THEN    Client.EmplInvestigator1 
--          WHEN (Client.EmplInvestigator1 is not null  and  Client.EmplInvestigator2 is not null) and (Appl.apno & 1) = 0  --even
--          THEN Client.EmplInvestigator2
--          WHEN (Client.EmplInvestigator1 is  null  and  Client.EmplInvestigator2 is not null) 
--          THEN Client.EmplInvestigator2
--          END 
		  (CASE WHEN (Client.Investigator1 is not null  and  Client.Investigator2 is not null) and (Appl.apno & 1) = 1  --odd
          THEN  Client.Investigator1 
          WHEN  (Client.Investigator1 is not null  and  Client.Investigator2 is null) 
          THEN    Client.Investigator1 
          WHEN (Client.Investigator1 is not null  and  Client.Investigator2 is not null) and (Appl.apno & 1) = 0  --even
          THEN Client.Investigator2
          WHEN (Client.Investigator1 is  null  and  Client.Investigator2 is not null) 
          THEN Client.Investigator2
          END ),
		  InvestigatorAssigned = GETDATE()
from Empl INNER JOIN Appl ON Appl.apno = Empl.Apno
	   INNER JOIN Client ON Client.clno = Appl.clno
WHERE  (Empl.SectStat = '9' or   Empl.SectStat = '0') and Empl.Investigator is null and Appl.InUse is null
/*
Procedure Name : Clients_With_Investigators_Assigned
Requested By: Dana Sangerhausen
Developer: Deepak Vodethela
Execution : EXEC [Clients_With_Investigators_Assigned]
*/

CREATE PROC dbo.Clients_With_Investigators_Assigned
AS
BEGIN

/* -- OLD CODE
select clno, name, investigator1, investigator2 
from client(nolock) 
where dbo.Client.IsInactive = 0 AND (dbo.Client.Investigator1 is not null or dbo.Client.Investigator2 IS NOT NULL)
*/

SELECT c.clno, name, investigator1, investigator2, Investigators = STUFF((SELECT ', ' + Investigator
																		   FROM applinvestigators b WITH (NOLOCK)
																		   WHERE b.clno = c.clno and Effective_InActivationDate is null
																		  FOR XML PATH('')), 1, 2, '')
	  INTO #temp

FROM client AS c WITH (NOLOCK)
WHERE c.IsInactive = 0 
  AND (c.Investigator1 IS NOT NULL OR c.Investigator2 IS NOT NULL)

--select * from #temp

;WITH cte (Clno, Name, investigator1, investigator2,InvestigatorsList)
AS
(
SELECT 
    [Clno],
    [Name],
    [investigator1] AS Investigator1,
	[investigator2] AS Investigator2,
    CONVERT(XML,'<Investigators><Name>' 
        + REPLACE([investigators],',', '</Name><Name>') 
        + '</Name></Investigators>') AS InvestigatorsList
FROM #temp
)
SELECT 
    [Clno],
    [Name],
    [Investigator1],
	[Investigator2],
    InvestigatorsList.value('/Investigators[1]/Name[1]','varchar(25)') AS [Investigator3],
    InvestigatorsList.value('/Investigators[1]/Name[2]','varchar(25)') AS [Investigator4],
    InvestigatorsList.value('/Investigators[1]/Name[3]','varchar(25)') AS [Investigator5],
    InvestigatorsList.value('/Investigators[1]/Name[4]','varchar(25)') AS [Investigator6],
    InvestigatorsList.value('/Investigators[1]/Name[5]','varchar(25)') AS [Investigator7],
    InvestigatorsList.value('/Investigators[1]/Name[6]','varchar(25)') AS [Investigator8],
    InvestigatorsList.value('/Investigators[1]/Name[7]','varchar(25)') AS [Investigator9],
    InvestigatorsList.value('/Investigators[1]/Name[8]','varchar(25)') AS [Investigator10]
    --InvestigatorsList.value('/Investigators[1]/Name[9]','varchar(25)') AS [Investigator11],
    --InvestigatorsList.value('/Investigators[1]/Name[10]','varchar(25)') AS [Investigator12],
    --InvestigatorsList.value('/Investigators[1]/Name[11]','varchar(25)') AS [Investigator13]
FROM cte
ORDER BY [Clno]

drop table #temp
END

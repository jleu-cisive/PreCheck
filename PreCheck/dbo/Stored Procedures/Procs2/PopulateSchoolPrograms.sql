
CREATE  PROCEDURE PopulateSchoolPrograms 
	@ClientID varchar(10)
AS


SELECT ' Show All ' Name, null ClientProgramID
UNION ALL
SELECT  ClientProgram.Name AS cp, ClientProgram.ClientProgramID AS cpid
FROM ClientProgram INNER JOIN  Client ON ClientProgram.CLNO = Client.CLNO AND Client.CLNO = @clientID
ORDER BY ClientProgram.Name
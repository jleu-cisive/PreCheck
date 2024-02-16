CREATE PROCEDURE testthis AS


CREATE TABLE #Authors
(EmployerID varchar(200),month varchar(2),year varchar(5),run varchar(2),
licensecount int ,initialclient bit,startdate datetime,duedate datetime)
 
INSERT #Authors
EXEC rabbit.hevn.dbo.UpcomingCredentialingRuns

SELECT *
FROM #Authors

DROP TABLE #Authors
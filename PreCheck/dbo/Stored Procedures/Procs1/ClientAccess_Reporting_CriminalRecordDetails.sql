
-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 08/15/2016 filter the search by client privileges
-- Changed the Configuration Key from "Showtenet" to "ShowSecurityPrivileges" - Radhika Dereddy on 08/29/2018
-- =============================================
CREATE  PROCEDURE [dbo].[ClientAccess_Reporting_CriminalRecordDetails] 
@clno int,
@Username VARCHAR(50),
@StartDate DateTime = '01/12/2013', 
@EndDate DateTime = '01/12/2013'

as
BEGIN

DECLARE @CLIENTUSERID INT
DECLARE @ConfigKey varchar(10)

SELECT @CLIENTUSERID = CONTACTID FROM [dbo].[ClientContacts] WHERE CLNO = @CLNO AND USERNAME = @USERNAME	

SET @ConfigKey = (Select ISNULL((SELECT LOWER(VALUE) FROM clientconfiguration WHERE clno = @clno and configurationkey ='ShowSecurityPrivileges'),'false') )

IF(LOWER(@ConfigKey) = 'true')
	BEGIN
		SELECT  Appl.APNO as 'Report Number', Appl.ApDate as 'Report Date', c.CLNO as 'Client ID', 
		c.Name as 'Facility Name', Appl.First + ' ' + Appl.Last as 'Applicant Name',
		Crim.County as 'Jurisdiction', crim.Offense, crim.Disposition, crim.Degree, crim.Date_Filed as 'File Date', 
		crim.Disp_Date as 'Disposition Date', Crim.Name AS [Name On Record]
		FROM  dbo.Crim  WITH (NOLOCK) 
		INNER JOIN dbo.Appl  WITH (NOLOCK) ON Crim.APNO = Appl.APNO 
		INNER JOIN (SELECT clno, name FROM Client WHERE Clno = @clno or WebOrderParentCLNO = @clno) c on Appl.CLNO = c.CLNO 
		WHERE (Crim.Clear IN ('P', 'F')) 
		AND Appl.CLNO in (SELECT ClientId AS CLNO  FROM [Security].[GetAuthorizedClients] (@CLIENTUSERID))
		AND Crim.ishidden = 0
		AND Appl.APDATE >= @StartDate 
		AND Appl.APDATE < DATEADD(d,1,@EndDate)
		ORDER BY appl.apno	
	END
ELSE
	BEGIN
		SELECT   Appl.APNO as 'Report Number', Appl.ApDate as 'Report Date', c.CLNO as 'Client ID', 
		c.Name as 'Facility Name', Appl.First + ' ' + Appl.Last as 'Applicant Name',
		Crim.County as 'Jurisdiction', crim.Offense, crim.Disposition, crim.Degree, crim.Date_Filed as 'File Date', 
		crim.Disp_Date as 'Disposition Date', Crim.Name AS [Name On Record]
		FROM  dbo.Crim  WITH (NOLOCK) 
		INNER JOIN dbo.Appl  WITH (NOLOCK) ON Crim.APNO = Appl.APNO 
		INNER JOIN (SELECT clno,name FROM Client WHERE Clno = @clno or WebOrderParentCLNO = @clno) c on Appl.CLNO = c.CLNO 
		WHERE (Crim.Clear IN ('P', 'F')) 
		AND Appl.CLNO = @clno
		AND Crim.ishidden = 0
		AND Appl.APDATE >= @StartDate 
		AND Appl.APDATE < DATEADD(d,1,@EndDate)
		ORDER BY appl.apno
	END



END






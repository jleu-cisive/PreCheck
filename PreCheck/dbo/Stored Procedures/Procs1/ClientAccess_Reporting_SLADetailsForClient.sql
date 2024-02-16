
-- =============================================
-- Author:		<Radhika Dereddy>
-- Create date: <08/15/2016>
-- Description:	Filter the search by Client privileges 
-- Changed the Configuration Key from "Showtenet" to "ShowSecurityPrivileges" - Radhika Dereddy on 08/29/2018
-- =============================================

--EXEC [ClientAccess_Reporting_SLADetailsForClient] 12444, 'acastillo',  '07/01/2016','08/15/2016'
CREATE  PROCEDURE [dbo].[ClientAccess_Reporting_SLADetailsForClient] 
@clno int,
@Username VARCHAR(50),
@StartDate DateTime = '01/12/2013', 
@EndDate DateTime = '01/12/2013'

as
BEGIN

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @CLIENTUSERID INT
DECLARE @ConfigKey varchar(10)

SELECT @CLIENTUSERID = CONTACTID FROM [dbo].[ClientContacts] WHERE CLNO = @CLNO AND USERNAME = @USERNAME	

SET @ConfigKey = (Select ISNULL((SELECT LOWER(VALUE) FROM clientconfiguration WHERE clno = @clno and configurationkey ='ShowSecurityPrivileges'),'false') )

if(LOWER(@ConfigKey) = 'true')
	BEGIN
		SELECT c.CLNO as 'Client ID', c.Name as 'Name', a.apno as 'Report Number',a.Last as 'Last Name',
		a.First as 'First Name', PackageDesc as 'Package Ordered', a.apdate as 'Start Date', 
		a.OrigcompDate as 'Initial Concluded Date', (case when a.OrigcompDate = a.CompDate then null else a.CompDate end) as 'Subsequent Concluded Date'
		FROM dbo.appl a  
		INNER JOIN Client c on a.CLNO = c.CLNO 
		LEFT JOIN packagemain p  on a.PackageID = P.PackageID
		where (a.apdate between @StartDate and DateAdd(d,1,@EndDate)) and --(c.Clno = @clno or c.WebOrderParentCLNO = @clno)
		c.Clno in (select ClientId AS CLNO  from [Security].[GetAuthorizedClients] (@CLIENTUSERID))

	END
ELSE
	BEGIN
		SELECT c.CLNO as 'Client ID', c.Name as 'Name', a.apno as 'Report Number',a.Last as 'Last Name',
		a.First as 'First Name', PackageDesc as 'Package Ordered', a.apdate as 'Start Date', 
		a.OrigcompDate as 'Initial Concluded Date', (case when a.OrigcompDate = a.CompDate then null else a.CompDate end) as 'Subsequent Concluded Date'
		FROM dbo.appl a 
		INNER JOIN Client c on a.CLNO = c.CLNO 
		LEFT JOIN packagemain p  on a.PackageID = P.PackageID
		where apdate between @StartDate and DateAdd(d,1,@EndDate) and (c.Clno = @clno or c.WebOrderParentCLNO = @clno) 
	END


SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET NOCOUNT OFF
END



	
	


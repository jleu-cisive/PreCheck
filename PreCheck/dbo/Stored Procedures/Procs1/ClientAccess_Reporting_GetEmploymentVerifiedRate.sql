
-- =============================================
-- Author:		Radhika Dereddy 
-- Create date: 08/15/2016 filter the search by client privileges
-- Changed the Configuration Key from "Showtenet" to "ShowSecurityPrivileges" - Radhika Dereddy on 08/29/2018
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_Reporting_GetEmploymentVerifiedRate]
	-- Add the parameters for the stored procedure here
@clno int,
@Username VARCHAR(50),
@Startdate date ,
@Enddate date
AS
BEGIN

--[ClientAccess_GetEmploymentVerifiedRate] 1932,'8/1/2013','12/31/2013'
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
DECLARE @CLIENTUSERID INT
DECLARE @ConfigKey varchar(10)

SELECT @CLIENTUSERID = CONTACTID FROM [dbo].[ClientContacts] WHERE CLNO = @CLNO AND USERNAME = @USERNAME	

SET @ConfigKey = (Select ISNULL((SELECT LOWER(VALUE) FROM clientconfiguration WHERE clno = @clno and configurationkey ='ShowSecurityPrivileges'),'false') )

		Declare @sects table
		(
		 status varchar(1)
		)

		declare @results table
		(
			StatusType varchar(100),
			[Count] int,
			Percentage decimal(12,2)
		)

		declare @totalcount int

if(LOWER(@ConfigKey) = 'true')
	BEGIN
		INSERT INTO @sects 
		SELECT E.[SectStat]
		FROM dbo.[Appl] A WITH (NOLOCK) INNER JOIN  dbo.[Empl] E WITH (NOLOCK) ON A.APNO = E.APNO
		WHERE A.[CLNO] in (SELECT ClientId AS CLNO  FROM [Security].[GetAuthorizedClients] (@CLIENTUSERID))
		AND (CONVERT(date,E.[Last_Worked]) >= @Startdate) AND (CONVERT(date,E.[Last_Worked]) <= @Enddate)  AND ( (E.IsOnReport = 1)) 
		AND ( (E.[IsHidden] = 0))
		AND (CONVERT(date,E.[CreatedDate]) >= @Startdate) AND (CONVERT(date,E.[CreatedDate]) <= @Enddate)
	END
ELSE
	BEGIN
		INSERT INTO @sects 
		SELECT E.[SectStat]
		FROM dbo.[Appl] A WITH (NOLOCK)  INNER JOIN  dbo.[Empl] E WITH (NOLOCK) ON A.APNO = E.APNO
		WHERE (A.[CLNO] = @clno)
		AND (CONVERT(date,E.[Last_Worked]) >= @Startdate) AND (CONVERT(date,E.[Last_Worked]) <= @Enddate)  AND ( (E.IsOnReport = 1)) 
		AND ( (E.[IsHidden] = 0))
		AND (CONVERT(date,E.[CreatedDate]) >= @Startdate) AND (CONVERT(date,E.[CreatedDate]) <= @Enddate)
	END

	
		SET @totalcount = (SELECT COUNT(1) FROM @sects)

		INSERT INTO @results (statustype, [COUNT], percentage)
		SELECT s.onlinedescription, COUNT(1),  (CONVERT(decimal, COUNT(*))/ CONVERT(decimal, @totalcount)) * 100
		FROM dbo.SectStat s WITH (NOLOCK) 
		JOIN @sects x ON x.status = s.code
		GROUP BY s.onlinedescription

		INSERT INTO @results (statustype, [COUNT], percentage) SELECT 'Total', @totalcount, 100
		SELECT * FROM @results

END


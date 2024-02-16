
-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 08/15/2016 filter the search by client privileges
-- Changed the Configuration Key from "Showtenet" to "ShowSecurityPrivileges" - Radhika Dereddy on 08/29/2018
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_Reporting_GetLicenseVerifiedRate]
	-- Add the parameters for the stored procedure here
@clno int,
@Username VARCHAR(50),
@Startdate date ,
@Enddate date
AS
BEGIN
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
			Count int,
			Percentage decimal(12,2)
		)

		declare @totalcount int

IF(LOWER(@ConfigKey) = 'true')
	BEGIN
		insert into @sects 
		SELECT E.[SectStat]
		FROM dbo.[Appl] A WITH (NOLOCK) inner join  dbo.ProfLic E WITH (NOLOCK) ON A.APNO = E.APNO
		WHERE A.[CLNO] in (SELECT ClientId AS CLNO  FROM [Security].[GetAuthorizedClients] (@CLIENTUSERID))
		AND (convert(date,E.[Last_Worked]) >= @Startdate) AND (convert(date,E.[Last_Worked]) <= @Enddate)  AND ( (E.IsOnReport = 1)) 
		AND ( (E.[IsHidden] = 0))
		AND (convert(date,E.[CreatedDate]) >= @Startdate) AND (convert(date,E.[CreatedDate]) <= @Enddate)
	END
ELSE
	BEGIN
		insert into @sects 
		SELECT E.[SectStat]
		FROM dbo.[Appl] A WITH (NOLOCK) inner join  dbo.ProfLic E WITH (NOLOCK) ON A.APNO = E.APNO
		WHERE (A.[CLNO] = @clno) 
		AND (convert(date,E.[Last_Worked]) >= @Startdate) AND (convert(date,E.[Last_Worked]) <= @Enddate)  AND ( (E.IsOnReport = 1)) 
		AND ( (E.[IsHidden] = 0))
		AND (convert(date,E.[CreatedDate]) >= @Startdate) AND (convert(date,E.[CreatedDate]) <= @Enddate)
	END
		
	
		set @totalcount = (select count(1) from @sects)

		insert into @results (statustype, [count], percentage)
		select s.onlinedescription, count(1),  (convert(decimal, count(*))/ convert(decimal, @totalcount)) * 100
		from dbo.SectStat s WITH (NOLOCK) 
		join @sects x on x.status = s.code
		group by s.onlinedescription

		insert into @results (statustype, [count], percentage) select 'Total', @totalcount, 100
		select * from @results

END



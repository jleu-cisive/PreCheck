
-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 08/15/2016 filter the search by client privileges
-- Changed the Configuration Key from "Showtenet" to "ShowSecurityPrivileges" - Radhika Dereddy on 08/29/2018
-- =============================================


CREATE PROCEDURE [dbo].[ClientAccess_Reporting_CriminalPercentages]
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

		declare @totalcount int
		declare @crimcount int;
		declare @recordsfound int;
		declare @perc decimal (4,2);
		Declare @apnos table
		(
		 ap int
		)
		Declare @crimids table
		(
		 cid int
		)
		
IF(LOWER(@ConfigKey) = 'true')
	BEGIN
		INSERT INTO @apnos 
		SELECT DISTINCT a.apno 		
		FROM dbo.appl a (NOLOCK) 
		INNER JOIN (SELECT clno,name FROM dbo.Client (NOLOCK) WHERE Clno = @clno or WebOrderParentCLNO = @clno) c on a.CLNO = c.CLNO 
		WHERE (convert(date,a.apdate) >= @Startdate 
		AND convert(date,a.apdate) <= @EndDate) 
		AND a.clno in (SELECT ClientId AS CLNO  FROM [Security].[GetAuthorizedClients] (@CLIENTUSERID))
	END
ELSE
	BEGIN
		insert into @apnos 
		select distinct a.apno 		
		from dbo.appl a (NOLOCK) inner join 
		(select clno,name from dbo.Client (NOLOCK) where Clno = @clno or WebOrderParentCLNO = @clno) c on a.CLNO = c.CLNO 
		where (convert(date,a.apdate) >= @Startdate AND convert(date,a.apdate) <= @EndDate) and 
		a.clno = @clno
	END
		
		set @totalcount = (select count(1) from @apnos);

		insert into @crimids
		select c.Apno from dbo.crim c with (nolock)
		join @apnos a on c.apno = a.ap and c.clear IN ('P', 'F')
	

		set @crimcount = (select count(distinct cid) from @crimids); --only count once
		set @recordsfound = (select count(*) from @crimids); -- count all
		set @perc = (select convert(decimal(4,2), ((convert(decimal, @crimcount)/ convert(decimal, @totalcount)) * 100)));

		select @totalcount as 'Number of Reports', @crimcount as 'Number with Criminal Records', 
		convert(varchar(10), @perc) + '%'as 'Percentage', @recordsfound as 'Total Number of Records Found'
		
END



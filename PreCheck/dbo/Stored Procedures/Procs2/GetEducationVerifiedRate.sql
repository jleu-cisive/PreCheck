-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
/*
 Execution : EXEC [dbo].[GetEducationVerifiedRate] NULL,'08/01/2016','11/11/2016','Tenet Healthcare'
			 EXEC [dbo].[GetEducationVerifiedRate] 10966,'08/01/2016','11/11/2016','Tenet Healthcare'
			 EXEC [dbo].[GetEducationVerifiedRate] 10966,'08/01/2016','11/11/2016',NULL
*/
-- =============================================
CREATE PROCEDURE [dbo].[GetEducationVerifiedRate]
	-- Add the parameters for the stored procedure here
 @clno INT = NULL,
 @Startdate DATE,
 @Enddate DATE,
 @AffiliateName varchar(max) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
			DECLARE @sects TABLE
		(
		 status varchar(1)
		)

		DECLARE @results TABLE
		(
			StatusType varchar(100),
			Count int,
			Percentage decimal(12,2)
		)

		DECLARE @totalcount int



		INSERT INTO @sects 
		SELECT [t1].[SectStat]
		FROM [Appl] AS [t0]
		INNER JOIN [dbo].[Educat] AS [t1] ON ([t1].[Apno] = [t0].[APNO]) AND ( ([t1].IsOnReport = 1)) 
		INNER JOIN [dbo].[Client] AS C WITH(NOLOCK) ON [t0].CLNO = C.CLNO
		INNER JOIN [dbo].[refAffiliate] AS R WITH(NOLOCK) ON C.AffiliateID = R.AffiliateID
		WHERE (@clno IS NULL OR [t0].[CLNO] = @clno) 
		  AND (convert(date,[t1].[Last_Worked]) >= @Startdate) AND (convert(date,[t1].[Last_Worked]) <= @Enddate) 
		  AND ([t1].[IsHidden] = 0)
		  AND (@AffiliateName IS NULL OR R.Affiliate LIKE '%' + @AffiliateName + '%')
		  AND (convert(date,[t1].[CreatedDate]) >= @Startdate) AND (convert(date,[t1].[CreatedDate]) <= @Enddate)
		--ORDER BY [t1].SectStat

		SET @totalcount = (SELECT count(*) FROM @sects)

		INSERT INTO @results (statustype, count, percentage)
		SELECT s.Description, count(*),  (convert(decimal, count(*))/ convert(decimal, @totalcount)) * 100
		FROM SectStat s
		JOIN @sects x on x.status = s.code
		GROUP BY s.Description

		INSERT INTO @results (statustype, count, percentage) SELECT 'Total', @totalcount, 0

		SELECT * FROM @results


	
	/* -- Original
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



		insert into @sects 
		SELECT [t1].[SectStat]
		FROM [Appl] AS [t0], [Educat] AS [t1]
		WHERE ([t0].[CLNO] = @clno) AND (convert(date,[t1].[Last_Worked]) >= @Startdate) AND (convert(date,[t1].[Last_Worked]) <= @Enddate) AND ([t1].[Apno] = [t0].[APNO]) AND ( ([t1].IsOnReport = 1)) 
		AND ( ([t1].[IsHidden] = 0))
		AND (convert(date,[t1].[CreatedDate]) >= @Startdate) AND (convert(date,[t1].[CreatedDate]) <= @Enddate)
		--order by [t1].SectStat
		set @totalcount = (select count(*) from @sects)

		insert into @results (statustype, count, percentage)
		select s.Description, count(*),  (convert(decimal, count(*))/ convert(decimal, @totalcount)) * 100
		from SectStat s
		join @sects x on x.status = s.code
		group by s.Description

		insert into @results (statustype, count, percentage) select 'Total', @totalcount, 0

		select * from @results
		*/
END

-- ===============================================================================================
-- Author:		Suchitra Yellapantula
-- Create date: 09/07/2016
-- Description:	Get the Client Verified Rate - Employment Verifications with Affiliate Information
-- ===============================================================================================
CREATE PROCEDURE [dbo].[GetEmploymentVerifiedRateWithAffiliate]
	-- Add the parameters for the stored procedure here 
 @Startdate date ,
 @Enddate date,
 @Affiliate varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
		Declare @sects table
		(
		 status varchar(1),
		 Affiliate varchar(50)
		)

		declare @results table
		(
			StatusType varchar(100),
			Affiliate varchar(50),
			Count int,
			Percentage decimal(12,2)
		)

		declare @totalcount int

		insert into @sects 
		SELECT [t1].[SectStat], [t3].Affiliate
		FROM [Appl] AS [t0]
		     INNER JOIN [Empl] AS [t1] ON [t0].[Apno] = [t1].[Apno]
			 INNER JOIN [Client] AS [t2] ON [t0].[Clno] = [t2].[clno]
			 INNER JOIN [refAffiliate] AS [t3] ON [t3].AffiliateID = [t2].AffiliateID
		WHERE (convert(date,[t1].[Last_Worked]) >= @Startdate) AND (convert(date,[t1].[Last_Worked]) <= @Enddate) AND ( ([t1].IsOnReport = 1)) 
		AND ( ([t1].[IsHidden] = 0))
		AND (convert(date,[t1].[CreatedDate]) >= @Startdate) AND (convert(date,[t1].[CreatedDate]) <= @Enddate)
		AND [t3].Affiliate = LTRIM(RTRIM(@Affiliate))
		--order by [t1].SectStat

		set @totalcount = (select count(*) from @sects)

		insert into @results (statustype, Affiliate, count, percentage)
		select s.Description, x.Affiliate, count(*),  (convert(decimal, count(*))/ convert(decimal, @totalcount)) * 100
		from SectStat s
		join @sects x on x.status = s.code
		group by s.Description, x.Affiliate

		insert into @results (statustype, Affiliate, count, percentage) select 'Total','', @totalcount, 0

		select * from @results

END
